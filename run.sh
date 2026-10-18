#!/bin/bash
set -Eeuo pipefail

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
trap 'printf "Error on line %s: %s\n" "$LINENO" "$BASH_COMMAND" >&2' ERR

usage() {
    cat <<'EOF'
Usage: ./run.sh [options]
  --dry-run         Print commands without installing or changing anything
  --skip-packages   Use already installed dependencies
  --skip-plugins    Only install packages and link configs (no network clones)
  --change-shell    Set zsh as the login shell
  --macos-defaults  Show the app switcher on all displays and restart Dock
  -h, --help        Show this help

Environment:
  TMUX_VERSION      tmux release to install from GitHub (default: 3.8)
EOF
}

dry_run=false
skip_packages=false
skip_plugins=false
change_shell=false
macos_defaults=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) dry_run=true ;;
        --skip-packages) skip_packages=true ;;
        --skip-plugins) skip_plugins=true ;;
        --change-shell) change_shell=true ;;
        --macos-defaults) macos_defaults=true ;;
        -h|--help) usage; exit 0 ;;
        *) die "Unknown option: $arg (see --help)" ;;
    esac
done

tmux_version=${TMUX_VERSION:-3.8}
[[ $tmux_version =~ ^[0-9]+\.[0-9]+[a-z]?$ ]] || die "Invalid TMUX_VERSION: $tmux_version"
tmux_prefix="$HOME/.local"
export PATH="$tmux_prefix/bin:$PATH"

run() {
    printf '+'
    printf ' %q' "$@"
    printf '\n'
    if ! "$dry_run"; then "$@"; fi
}

require() { command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"; }

repo_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
os=$(uname -s)
case "$os" in
    Darwin) ;;
    Linux)
        if ! "$skip_packages"; then
            require apt-get
            require sudo
            case "$(uname -m)" in
                x86_64) nvim_arch=x86_64 ;;
                aarch64|arm64) nvim_arch=arm64 ;;
                *) die "Unsupported Linux architecture: $(uname -m)" ;;
            esac
        fi
        ;;
    *) die "Unsupported operating system: $os" ;;
esac
if "$macos_defaults" && [ "$os" != Darwin ]; then
    die '--macos-defaults is only available on macOS'
fi
if [ "$os" = Darwin ] && ! "$skip_packages"; then
    require brew
fi

stow_configs() (
    cd "$repo_dir"
    stow_args=(--no-folding --verbose --dir="$repo_dir/.." --target="$HOME" "$@" "${repo_dir##*/}")
    printf '+ stow'
    printf ' %q' "${stow_args[@]}"
    printf '\n'
    stow "${stow_args[@]}"
)

# Check conflicts before package installation when Stow is already available.
if command -v stow >/dev/null 2>&1; then
    stow_configs --simulate
elif "$skip_packages"; then
    die 'Stow is required with --skip-packages'
fi

temp_dir=
cleanup() {
    if [ -n "$temp_dir" ] && ! "$dry_run"; then
        if [ -S "$temp_dir/tmux.sock" ]; then
            tmux -S "$temp_dir/tmux.sock" kill-server || true
        fi
        rm -rf -- "$temp_dir"
    fi
}
trap cleanup EXIT
if "$dry_run"; then
    temp_dir=/tmp/dotfiles-preview
else
    temp_dir=$(mktemp -d /tmp/dotfiles.XXXXXX)
fi

printf 'Installing configs for %s from %s\n' "$os" "$repo_dir"
if ! "$skip_packages"; then
    if [ "$os" = Darwin ]; then
        run brew install neovim vim stow git curl zsh ripgrep clang-format atuin libevent ncurses utf8proc jemalloc pkgconf bison
        run brew install --cask alacritty font-hack-nerd-font
    else
        run sudo apt-get update
        run sudo apt-get install -y vim stow git curl wget zsh ripgrep clang-format build-essential ca-certificates libevent-dev libncurses-dev bison pkg-config
        run curl -fL --retry 3 -o "$temp_dir/nvim.tar.gz" \
            "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${nvim_arch}.tar.gz"
        # Keep the location already used by .zshrc, regardless of archive layout.
        run sudo mkdir -p /opt/nvim-linux64
        run sudo tar -C /opt/nvim-linux64 --strip-components=1 -xzf "$temp_dir/nvim.tar.gz"
        export PATH="/opt/nvim-linux64/bin:$PATH"
    fi

    if [ -x "$tmux_prefix/bin/tmux" ] && [ "$("$tmux_prefix/bin/tmux" -V)" = "tmux $tmux_version" ]; then
        printf 'tmux %s is already installed in %s\n' "$tmux_version" "$tmux_prefix"
    else
        # Release tarballs include configure, so autoconf/automake are not needed.
        (
            if ! "$dry_run"; then
                for dependency in cc make pkg-config tar; do require "$dependency"; done
            fi
            run curl -fL --retry 3 -o "$temp_dir/tmux.tar.gz" \
                "https://github.com/tmux/tmux/releases/download/${tmux_version}/tmux-${tmux_version}.tar.gz"
            run tar -C "$temp_dir" -xzf "$temp_dir/tmux.tar.gz"
            printf '+ cd %q\n' "$temp_dir/tmux-$tmux_version"
            if ! "$dry_run"; then cd "$temp_dir/tmux-$tmux_version"; fi

            configure_args=("--prefix=$tmux_prefix")
            if [ "$os" = Darwin ]; then
                # Homebrew's ncurses and utf8proc may be keg-only.
                if "$dry_run"; then
                    printf '+ use Homebrew libevent, ncurses, utf8proc and jemalloc via PKG_CONFIG_PATH\n'
                else
                    event_prefix=$(brew --prefix libevent)
                    curses_prefix=$(brew --prefix ncurses)
                    utf8_prefix=$(brew --prefix utf8proc)
                    jemalloc_prefix=$(brew --prefix jemalloc)
                    export PKG_CONFIG_PATH="$event_prefix/lib/pkgconfig:$curses_prefix/lib/pkgconfig:$utf8_prefix/lib/pkgconfig:$jemalloc_prefix/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
                fi
                configure_args+=(--enable-utf8proc --enable-jemalloc)
            fi
            run ./configure "${configure_args[@]}"
            run make
            run make install
        )
        if ! "$dry_run"; then
            [ "$("$tmux_prefix/bin/tmux" -V)" = "tmux $tmux_version" ] || die "Installed tmux does not match $tmux_version"
        fi
    fi
fi

if ! "$dry_run"; then
    require stow
    if ! "$skip_plugins"; then
        for dependency in curl git zsh tmux vim nvim; do require "$dependency"; done
    fi
fi

# Stow refuses conflicts instead of adopting files into the repository.
if "$dry_run"; then
    printf '+ stow configs into %s (simulation)\n' "$HOME"
else
    stow_configs --simulate
    stow_configs
    printf 'Config symlinks are ready in %s\n' "$HOME"
fi

if ! "$skip_plugins"; then
    if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
        run git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    fi
    if [ ! -f "$HOME/.tmux/plugins/tpm/tpm" ]; then
        run git clone --depth=1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi

    run curl -fL --retry 3 -o "$temp_dir/plug.vim" \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    for autoload_dir in "$HOME/.vim/autoload" "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload"; do
        run mkdir -p "$autoload_dir"
        run cp "$temp_dir/plug.vim" "$autoload_dir/plug.vim"
    done

    # Load only plugin declarations: colorschemes and after/plugin modules are
    # unavailable on a fresh install. Wait for installation before exiting.
    if ! "$dry_run"; then
        awk '{ print } /call plug#end\(\)/ { exit }' "$repo_dir/.vimrc" > "$temp_dir/vimrc"
        printf 'lua dofile(vim.env.DOTFILES_DIR .. "/.config/nvim/lua/lll-phill-lll/vimplug.lua")\n' > "$temp_dir/init.vim"
    fi
    export DOTFILES_DIR="$repo_dir"
    # vim-plug reports clone and hook errors in its buffer without a failing
    # process status. Propagate those errors to the installer as well.
    plug_check='if search("^x ", "nw") | %print | cquit | endif'
    run vim -N -u "$temp_dir/vimrc" -i NONE -n -es -c 'PlugInstall --sync' -c "$plug_check" -c 'qall'
    run nvim --headless -u "$temp_dir/init.vim" -i NONE -n -c 'PlugInstall --sync' -c "$plug_check" -c 'qall'

    # Use a private server so installing TPM plugins works without a running
    # session and does not reload or change the user's existing tmux sessions.
    run tmux -S "$temp_dir/tmux.sock" -f "$repo_dir/.tmux.conf" new-session -d -s dotfiles 'sleep 300'
    run env TMUX="$temp_dir/tmux.sock,0,0" "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi

if "$macos_defaults"; then
    run defaults write com.apple.Dock appswitcher-all-displays -bool true
    run killall Dock
fi
if "$change_shell"; then
    if "$dry_run"; then
        printf '+ chsh -s <installed zsh listed in /etc/shells>\n'
    else
        zsh_path=$(command -v zsh) || die 'zsh is not installed'
        if [ "${SHELL:-}" != "$zsh_path" ]; then
            if ! grep -Fxq "$zsh_path" /etc/shells; then
                die "$zsh_path must be listed in /etc/shells before using chsh"
            fi
            run chsh -s "$zsh_path"
        fi
    fi
fi
printf 'Done.\n'
