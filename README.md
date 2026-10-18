# dotfiles

Configs for Bash, Zsh, Vim, Neovim, tmux, and terminals. The installer supports
macOS with an existing Homebrew installation and Debian/Ubuntu with `apt-get`
and `sudo`. Linux Neovim downloads support x86_64 and ARM64.

Clone this repository and run:

```sh
./run.sh --dry-run
./run.sh
```

You can invoke the script from any directory. It installs dependencies, links
configs into `$HOME`, and installs Oh My Zsh, vim-plug, editor plugins, and TPM
plugins. Existing Oh My Zsh and TPM installations are reused. Temporary downloads
are cleaned up on exit. Neovim on Linux is installed into `/opt/nvim-linux64`,
the path used by `.zshrc`, using the architecture-specific
[official release archives](https://github.com/neovim/neovim/blob/master/INSTALL.md).
Bash and Zsh add `/opt/nvim-linux64/bin` to `PATH` when it exists. Neovim's config
is `~/.config/nvim` (there is no `~/.nvim` directory); tmux uses `~/.tmux.conf`.

The Neovim configuration uses native `vim.lsp.config`/`vim.lsp.enable` (Nvim
0.11.3+). For Treesitter it selects `main` on Nvim 0.12+ and the compatible
`master` branch on Nvim 0.11, with matching textobjects branches. See the
[Treesitter migration instructions](https://github.com/nvim-treesitter/nvim-treesitter/blob/main/README.md)
and [LSP migration instructions](https://github.com/neovim/nvim-lspconfig#readme).
Homebrew installs `tree-sitter-cli`; Linux installs the official CLI 0.26.12
binary into `~/.local/bin`. The installer updates the three affected plugins,
waits for parser installation, and checks normal Neovim startup before proceeding
to tmux plugins. Lua startup errors stop installation even when Neovim returns 0.
Plugin installation runs separately from user `after/plugin` configuration.

tmux is pinned to **3.8**, the latest stable release checked on 2026-10-18.
The installer downloads the release tarball from
[tmux's GitHub releases](https://github.com/tmux/tmux/releases/tag/3.8), builds it
according to the [upstream instructions](https://github.com/tmux/tmux/wiki/Installing),
and installs it into `$HOME/.local` without sudo. Bash and Zsh put
`$HOME/.local/bin` ahead of system packages. Start a new shell after installing.
Existing tmux sessions keep running their current server until they exit.
If the requested version is already installed in this location, rebuilding is skipped.
Homebrew/apt install the build dependencies; tmux itself is not installed through them.

To choose another release:

```sh
TMUX_VERSION=3.7c ./run.sh
```

`--skip-packages` also skips building tmux and uses the existing installation.

To reinstall everything managed by the installer:

```sh
./run.sh --force --dry-run
./run.sh --force
```

`--force` reinstalls the listed packages (Homebrew reinstall on macOS,
`apt-get install --reinstall` on Ubuntu), downloads the Linux binaries again,
rebuilds tmux even if the requested version is present, and runs Stow with
`--restow`. Existing Oh My Zsh, `~/.tmux/plugins`, `~/.vim/plugged`, and
`~/.config/nvim/plugged` are moved into `~/old_configs/<unique-run>/` before
fresh clones and plugin installation. Custom files in those directories are
kept in the backup. vim-plug is downloaded again as in a normal run.
Shell/Atuin history, saved tmux sessions, and editor undo data are preserved.
Package managers may reuse their download caches. See the
[Homebrew](https://docs.brew.sh/Manpage#reinstall-options-formulacask-)
and [apt-get](https://manpages.debian.org/bookworm/apt/apt-get.8.en.html) manuals.
The skip flags still take precedence: `--force --skip-packages` reinstalls only
configs and plugins; `--force --skip-plugins` leaves plugin directories in place.

Stow checks for conflicts before linking and, when already available, previews
them before installing packages. Conflicting files, directories, and symlinks
are automatically moved into `~/old_configs/<timestamp>.<unique-suffix>/`
immediately before linking. Their paths are preserved, for example
`~/.bashrc` becomes `~/old_configs/<run>/.bashrc`, and a conflicting
`~/.config/nvim/init.lua` becomes `~/old_configs/<run>/.config/nvim/init.lua`.
Each run uses a fresh backup directory so previous backups are never overwritten.
Unrelated configs and existing correct links stay in place. A dry run only
prints the planned backups and does not create `~/old_configs` or move files.
Existing files are never adopted into this repository.
Stow creates symbolic links in your home directory, for example
`~/.bashrc -> /path/to/dotfiles/.bashrc`; the original files stay in the repository.
The repository is passed as Stow package `.` with its own directory as `--dir`,
so placing the checkout directly at `~/dotfiles` is supported. The installer
verifies the Bash, Zsh, tmux, Neovim (including the Treesitter Lua module), and
Atuin config links before reporting success. It checks that the new Treesitter
and Atuin config files exist in the checkout before making changes. Include
new files when committing or copying the repository to another machine.
The installer prints the Stow commands and link operations. Actual linking runs
after package installation and tmux building, so an error in those steps stops
the installer before new links are created. To link configs independently of
package installation and plugins, use `./run.sh --skip-packages --skip-plugins`.
Unrecognized Stow errors stop the installer instead of moving guessed paths.
A failed run stops immediately; packages and configs installed by earlier steps
are not rolled back. Any backups already made remain in `~/old_configs`.

Options:

- `--dry-run`: print the installation plan and check Stow conflicts without changes.
- `--force`: reinstall packages, rebuild tmux, recreate config links and reinstall plugins.
- `--skip-packages`: use dependencies already installed on this machine.
- `--skip-plugins`: skip Oh My Zsh, TPM, vim-plug, and plugin installation.
- `--change-shell`: switch the login shell to zsh, if its path is in `/etc/shells`.
- `--macos-defaults`: show the app switcher on every display and restart Dock.

For example, to only link configs with an existing Stow installation:

```sh
./run.sh --skip-packages --skip-plugins
```

The login shell and Dock settings change only when the corresponding flags are
passed. Respect `XDG_DATA_HOME` for Neovim's vim-plug autoload file; the configs
themselves live in `$HOME/.config`.

When Bash starts interactively, `.bashrc` switches to zsh if it is installed,
regardless of the terminal type. This works without permission to use `chsh`
and preserves login-shell mode. Non-interactive Bash scripts are unaffected.
To stay in Bash for a session, run `NOZSH=1 bash`.

Atuin is installed through Homebrew on macOS and from the latest official
[prebuilt release](https://github.com/atuinsh/atuin/releases/latest) on Linux
(x86_64/ARM64, installed into `~/.local/bin`). Both shells initialize it after
fzf. The shared config is `~/.config/atuin/config.toml`, selected explicitly
with `ATUIN_CONFIG_DIR` so both old and new Atuin releases use it.
The up arrow opens history for the exact current directory; Ctrl+R opens all
recorded history. Workspace filtering is disabled so Git directories follow
the same rules. Both bindings use a compact inline window up to 10 lines high,
with command previews disabled. Adjust `inline_height` in the config to resize
it; see [Atuin's UI settings](https://docs.atuin.sh/latest/configuration/config/#inline_height)
and [key binding documentation](https://docs.atuin.sh/latest/configuration/key-binding/).
Open a new terminal after installation to enable recording and the bindings.
To bring existing shell history into Atuin, run `atuin import auto` once.
Imported Bash/Zsh history has no directory information; directory filtering
applies to commands recorded by Atuin after its shell integration is enabled.

Ctags and language servers such as clangd, pyright, and rust-analyzer are installed
separately. Telescope's search uses ripgrep, which the installer includes.
Vim and tmux shortcuts are described in comments in their config files.

Run the installer regression tests with Python 3 and GNU Stow installed:

```sh
python3 -m unittest discover -s tests -v
```

Tests use temporary home directories and mock package managers and network
commands; they do not install packages or modify your home directory.

