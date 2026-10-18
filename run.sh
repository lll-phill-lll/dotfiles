#!/bin/bash
set -Eeuo pipefail

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
trap 'printf "Error on line %s: %s\n" "$LINENO" "$BASH_COMMAND" >&2' ERR

usage() {
    cat <<'EOF'
Usage: ./run.sh [options]
  --dry-run         Print commands without installing or changing anything
  --force           Reinstall packages, rebuild tmux, restow and reinstall plugins
  --skip-packages   Use already installed dependencies
  --skip-plugins    Only install packages and link configs (no network clones)
  --change-shell    Set zsh as the login shell
  --macos-defaults  Show the app switcher on all displays and restart Dock
  -h, --help        Show this help

Environment:
  TMUX_VERSION      tmux release to install from GitHub (default: 3.8)

Conflicting configs are moved to ~/old_configs/<unique-run>/ before linking.
EOF
}

dry_run=false
force=false
skip_packages=false
skip_plugins=false
change_shell=false
macos_defaults=false
for arg in "$@"; do
    case "$arg" in
        --dry-run) dry_run=true ;;
        --force) force=true ;;
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
    if "$dry_run"; then return; fi
    local command_status=0
    "$@" || command_status=$?
    if [ "$command_status" -ne 0 ]; then
        printf 'Command failed (exit %s):' "$command_status" >&2
        printf ' %q' "$@" >&2
        printf '\n' >&2
        exit "$command_status"
    fi
}

require() { command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"; }

install_brew_packages() {
    local kind=$1 package
    shift
    if ! "$force"; then
        run brew install "$kind" "$@"
        return
    fi
    for package in "$@"; do
        if "$dry_run"; then
            printf '+ brew reinstall %q %q (install if absent)\n' "$kind" "$package"
        elif brew list "$kind" --versions "$package" >/dev/null 2>&1; then
            run env HOMEBREW_NO_ASK=1 brew reinstall "$kind" "$package"
        else
            run brew install "$kind" "$package"
        fi
    done
}

repo_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
# Catch incomplete checkouts before installing packages or moving old configs.
for config in .config/nvim/lua/lll-phill-lll/treesitter.lua .config/atuin/config.toml; do
    [ -f "$repo_dir/$config" ] || die "Required config is missing from the repository: $config. Transfer all new files before running the installer."
done
os=$(uname -s)
case "$os" in
    Darwin) ;;
    Linux)
        if ! "$skip_packages"; then
            require apt-get
            require sudo
            case "$(uname -m)" in
                x86_64) nvim_arch=x86_64; treesitter_arch=x64; atuin_arch=x86_64 ;;
                aarch64|arm64) nvim_arch=arm64; treesitter_arch=arm64; atuin_arch=aarch64 ;;
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
    # Treat the repository itself as package ".". Using its parent as the
    # Stow directory would equal the target for ~/dotfiles and skip all files.
    stow_args=(--no-folding --verbose --dir="$repo_dir" --target="$HOME" "$@" .)
    if "$force"; then stow_args=(--restow "${stow_args[@]}"); fi
    printf '+ stow'
    printf ' %q' "${stow_args[@]}"
    printf '\n'
    LC_ALL=C stow "${stow_args[@]}"
)

# Let Stow identify conflicts so its ignore rules and existing links are
# respected. Accept known Stow 2.3/2.4 messages; other errors abort unchanged.
backup_dir=
ensure_backup_dir() {
    if [ -n "$backup_dir" ]; then return; fi
    if [ -L "$HOME/old_configs" ] || { [ -e "$HOME/old_configs" ] && [ ! -d "$HOME/old_configs" ]; }; then
        die "$HOME/old_configs must be a regular directory"
    fi
    run mkdir -p "$HOME/old_configs"
    backup_dir=$(mktemp -d "$HOME/old_configs/$(date +%Y%m%d-%H%M%S).XXXXXX")
    printf 'Backing up previous files to %s\n' "$backup_dir"
}

# Call only with the fixed installer paths below or validated Stow conflicts.
backup_existing() {
    local relative=$1 destination
    if [ ! -e "$HOME/$relative" ] && [ ! -L "$HOME/$relative" ]; then return; fi
    if "$dry_run"; then
        printf 'Will back up: %s -> %s/old_configs/<unique-run>/%s\n' "$HOME/$relative" "$HOME" "$relative"
        return
    fi
    ensure_backup_dir
    destination="$backup_dir/$relative"
    if [ -e "$destination" ] || [ -L "$destination" ]; then
        die "Backup already exists: $destination"
    fi
    run mkdir -p "$(dirname -- "$destination")"
    run mv -- "$HOME/$relative" "$destination"
}

prepare_stow() {
    local move_conflicts=$1 output line relative
    local -a conflicts
    while true; do
        if output=$(stow_configs --simulate 2>&1); then
            printf '%s\n' "$output"
            return 0
        fi
        printf '%s\n' "$output"
        conflicts=()
        while IFS= read -r line; do
            case "$line" in
                '  * existing target is neither a link nor a directory: '*|'  * existing target is not owned by stow: '*)
                    relative=${line#*: }
                    ;;
                '  * existing target is stowed to a different package: '*)
                    relative=${line#*: }
                    relative=${relative%% => *}
                    ;;
                '  * cannot stow non-directory '*' over existing directory target '*|'  * cannot stow directory '*' over existing non-directory target '*)
                    relative=${line##* target }
                    ;;
                '  * cannot stow '*' over existing target '*' since neither a link nor a directory and --adopt not specified')
                    relative=${line#* over existing target }
                    relative=${relative% since neither a link nor a directory and --adopt not specified}
                    ;;
                '  * '*) die "Cannot automatically resolve Stow conflict: $line" ;;
                *) continue ;;
            esac
            case "$relative" in
                ''|.|..|/*|../*|*/../*|*/..|./*|*/./*|*/.)
                    die "Invalid Stow conflict path: $relative"
                    ;;
            esac
            if { [ ! -e "$HOME/$relative" ] && [ ! -L "$HOME/$relative" ]; } ||
               { [ ! -e "$repo_dir/$relative" ] && [ ! -L "$repo_dir/$relative" ]; } ||
               [ "$HOME/$relative" -ef "$repo_dir/$relative" ]; then
                die "Cannot safely back up Stow conflict: $relative"
            fi
            conflicts+=("$relative")
        done <<< "$output"
        [ "${#conflicts[@]}" -gt 0 ] || die 'Stow failed without a recognized target conflict'

        if ! "$move_conflicts"; then
            for relative in "${conflicts[@]}"; do
                printf 'Will back up: %s -> %s/old_configs/<unique-run>/%s\n' "$HOME/$relative" "$HOME" "$relative"
            done
            return 0
        fi

        for relative in "${conflicts[@]}"; do
            backup_existing "$relative"
        done
        # Removing a conflicting parent can reveal new paths on the next pass.
    done
}

# Preview backups before packages; move files only immediately before linking.
if command -v stow >/dev/null 2>&1; then
    prepare_stow false
elif "$skip_packages"; then
    die 'Stow is required with --skip-packages'
fi

temp_dir=
editor_log=
cleanup() {
    local exit_status=$?
    if [ -n "$temp_dir" ] && ! "$dry_run"; then
        if [ "$exit_status" -ne 0 ] && [ -n "$editor_log" ] && [ -f "$editor_log" ]; then
            printf '\nLast editor messages (%s):\n' "$editor_log" >&2
            tail -n 100 "$editor_log" >&2 || true
        fi
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
        install_brew_packages --formula neovim vim stow git curl zsh ripgrep clang-format atuin libevent ncurses utf8proc jemalloc pkgconf bison tree-sitter-cli
        install_brew_packages --cask alacritty font-hack-nerd-font
    else
        run sudo apt-get update
        apt_install_args=(-y)
        if "$force"; then apt_install_args+=(--reinstall); fi
        run sudo apt-get install "${apt_install_args[@]}" vim stow git curl wget zsh ripgrep clang-format build-essential ca-certificates libevent-dev libncurses-dev bison pkg-config
        run curl -fL --retry 3 -o "$temp_dir/nvim.tar.gz" \
            "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${nvim_arch}.tar.gz"
        # Keep the location already used by .zshrc, regardless of archive layout.
        run sudo mkdir -p /opt/nvim-linux64
        run sudo tar -C /opt/nvim-linux64 --strip-components=1 -xzf "$temp_dir/nvim.tar.gz"
        export PATH="/opt/nvim-linux64/bin:$PATH"
        # Ubuntu's packaged CLI may be too old for current nvim-treesitter.
        run curl -fL --retry 3 -o "$temp_dir/tree-sitter.gz" \
            "https://github.com/tree-sitter/tree-sitter/releases/download/v0.26.12/tree-sitter-linux-${treesitter_arch}.gz"
        run gzip -d "$temp_dir/tree-sitter.gz"
        run mkdir -p "$HOME/.local/bin"
        run install -m 755 "$temp_dir/tree-sitter" "$HOME/.local/bin/tree-sitter"

        # Use the official prebuilt binary; Ubuntu does not always package Atuin.
        run curl -fL --retry 3 -o "$temp_dir/atuin.tar.gz" \
            "https://github.com/atuinsh/atuin/releases/latest/download/atuin-${atuin_arch}-unknown-linux-musl.tar.gz"
        run mkdir -p "$temp_dir/atuin"
        run tar -C "$temp_dir/atuin" --strip-components=1 -xzf "$temp_dir/atuin.tar.gz"
        run install -m 755 "$temp_dir/atuin/atuin" "$HOME/.local/bin/atuin"
    fi

    if ! "$force" && [ -x "$tmux_prefix/bin/tmux" ] && [ "$("$tmux_prefix/bin/tmux" -V)" = "tmux $tmux_version" ]; then
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

# Keep old configs outside the repository, then let Stow create the links.
if "$dry_run"; then
    printf '+ stow configs into %s (simulation)\n' "$HOME"
else
    prepare_stow true
    stow_configs
    # Stow can return success after skipping a target; verify the key links
    # before claiming that shell/editor configs are ready.
    for config in .bashrc .bash_profile .zshrc .tmux.conf .config/nvim/init.lua .config/nvim/lua/lll-phill-lll/treesitter.lua .config/atuin/config.toml; do
        if [ "$HOME/$config" -ef "$repo_dir/$config" ]; then
            printf 'Config linked: %s\n' "$HOME/$config"
        else
            die "Config was not linked: $HOME/$config"
        fi
    done
    printf 'Config symlinks are ready in %s\n' "$HOME"
fi

if ! "$skip_plugins"; then
    if "$force"; then
        for plugin_dir in .oh-my-zsh .tmux/plugins .vim/plugged .config/nvim/plugged; do
            backup_existing "$plugin_dir"
        done
    fi
    if "$force" || [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
        run git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    fi
    if "$force" || [ ! -f "$HOME/.tmux/plugins/tpm/tpm" ]; then
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
        cat > "$temp_dir/init.vim" <<'EOF'
lua vim.opt.rtp:remove(vim.fn.stdpath('config') .. '/after')
lua dofile(vim.env.DOTFILES_DIR .. '/.config/nvim/lua/lll-phill-lll/vimplug.lua')
EOF
    fi
    export DOTFILES_DIR="$repo_dir"
    # vim-plug marks clone/hook failures with "x " in its buffer. v:errmsg
    # also contains errors suppressed by its normal silent! unmap operations,
    # so it cannot indicate whether PlugInstall/PlugUpdate succeeded.
    plug_check='if search("^x ", "nw") | %print | cquit | endif'
    editor_check='if !empty(v:errmsg) | echo v:errmsg | cquit | endif'
    editor_log="$temp_dir/vim-install.log"
    run vim -N --noplugin -V1"$editor_log" -u "$temp_dir/vimrc" -i NONE -n -es \
        -c 'PlugInstall --sync' -c "$plug_check" -c 'qall'
    # Update the plugins whose API/branch changed, then install the remaining
    # plugins. Keep user after/plugin configs out of this bootstrap process.
    editor_log="$temp_dir/nvim-install.log"
    run nvim --headless --noplugin -V1"$editor_log" -u "$temp_dir/init.vim" -i NONE -n \
        -c 'PlugUpdate --sync nvim-treesitter nvim-treesitter-textobjects nvim-lspconfig' -c "$plug_check" \
        -c 'PlugInstall --sync' -c "$plug_check" -c 'qall'
    # Use a fresh process after switching branches so cached Lua modules from
    # the previous plugin version cannot leak into parser installation.
    editor_log="$temp_dir/nvim-parsers.log"
    run nvim --headless -V1"$editor_log" -u "$temp_dir/init.vim" -i NONE -n \
        -c 'let v:errmsg = ""' \
        -c "lua require('lll-phill-lll.treesitter').install()" -c "$editor_check" -c 'qall'
    # Lua startup errors may still return exit status 0: check v:errmsg too.
    editor_log="$temp_dir/nvim-startup.log"
    run nvim --headless -V1"$editor_log" -u "$HOME/.config/nvim/init.lua" -i NONE -n \
        -c "$editor_check" -c 'qall'
    editor_log=

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
