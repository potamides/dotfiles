# Dotfiles

> Ohne Fleiß kein Rice.
> - DrCracket

A repository for more sophisticated configurations of applications I use on a
daily basis. For a pleasant and integrated appearance I use the
[gruvbox](https://github.com/morhetz/gruvbox) colorscheme for everything.

![](.rice.png)

## Installation

First clone the repository with all submodules.

```sh
git clone --recurse-submodules https://github.com/DrCracket/dotfiles
```

Files in the root folder should be symlinked to `$HOME` and everything in the
config folder should be symlinked to `$HOME/.config/`. It is assumed that the
following applications are already installed. I just explain how to get my
particular configurations running.

### Prerequesites

Make sure that the fonts [DejaVu Sans](https://dejavu-fonts.github.io/) and
[Sauce Code Pro Nerd
Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/SourceCodePro)
are installed.

### Neovim

To set up my neovim configuration the
[vim-plug](https://github.com/junegunn/vim-plug) plugin manager is required. To
install it simply run the following command.

```sh
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

After setting it up launch neovim and run the command `:PlugInstall` to install
all other plugins. Now restart neovim and everything should be working.

### Zsh

I based my zsh configuration on the
[grml-zsh-config](https://github.com/grml/grml-etc-core/tree/master/usr_share_grml/zsh).
Additionally I use the plugins
[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting),
[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) and
[zsh-completions](https://github.com/zsh-users/zsh-completions). On Archlinux
all mentioned packages can be installed with pacman.

### Awesome, Conky, Termite, Ranger, Tmux

Some of these applications don't have dependencies and if they have, they are
integrated as git submodules or git subtrees so no additional steps are
required. To understand how to control my awesome configuration take a look at
[modalawesome](https://github.com/DrCracket/modalawesome).
