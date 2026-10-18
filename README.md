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

Stow checks for conflicts before linking and, when already available, before
installing packages. Existing files are never adopted into this repository.
Stow creates symbolic links in your home directory, for example
`~/.bashrc -> /path/to/dotfiles/.bashrc`; the original files stay in the repository.
The repository is passed as Stow package `.` with its own directory as `--dir`,
so placing the checkout directly at `~/dotfiles` is supported. The installer
verifies the Bash, Zsh, tmux, and Neovim config links before reporting success.
The installer prints the Stow commands and link operations. Actual linking runs
after package installation and tmux building, so an error in those steps stops
the installer before new links are created. To link configs independently of
package installation and plugins, use `./run.sh --skip-packages --skip-plugins`.
If Stow reports a conflict, move the conflicting file to a backup location,
compare it with the config here, and rerun. A failed run stops immediately;
packages and configs installed by earlier steps are not rolled back.

Options:

- `--dry-run`: print the installation plan and check Stow conflicts without changes.
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

Ctags and language servers such as clangd, pyright, and rust-analyzer are installed
separately. Telescope's search uses ripgrep, which the installer includes.
Vim and tmux shortcuts are described in comments in their config files.

Run the installer regression tests with Python 3 and GNU Stow installed:

```sh
python3 -m unittest discover -s tests -v
```

Tests use temporary home directories and mock package managers and network
commands; they do not install packages or modify your home directory.

