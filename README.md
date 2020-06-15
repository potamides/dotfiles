# Dotfiles

> Ohne Fleiß kein Rice.
> - DrCracket

A repository for more sophisticated configurations of applications I use on a
daily basis. I use the
[gruvbox](https://github.com/morhetz/gruvbox) colorscheme for everything.

![](.rice.png)

## Installation

First clone the repository with all submodules.

```sh
git clone --recurse-submodules https://github.com/DrCracket/dotfiles
```

Files in the root folder should be symlinked to `$HOME` and everything in the
config folder should be symlinked to `$HOME/.config/`. I assume that the
following applications are already installed. I just explain how to get my
particular configurations running.
Also make sure that the fonts [DejaVu Sans](https://dejavu-fonts.github.io/)
and [Sauce Code Pro Nerd
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

### Bash
If available, the bash configuration sources
[bash-completions](https://github.com/scop/bash-completion) to get command line
completions and
[git-completion](https://github.com/git/git/blob/master/contrib/completion/git-completion.bash)
to integrate git into the prompt. The former is available as a package in
Archlinux and the latter should already be installed along with git. It also
makes use of neofetch. Stylistically the prompt is inspired by the
[grml-zsh-config](https://github.com/grml/grml-etc-core/tree/master/usr_share_grml/zsh).

### Neofetch
Neofetch is configured to be used as a terminal greeter. It displays [fortune
cookies](https://www.shlomifish.org/open-source/projects/fortune-mod/), so make
sure the package is installed (available with pacman).
[Boxes](https://boxes.thomasjensen.com/) is also required for the terminal
greeter (an AUR package exists).

### Awesome
Awesome needs [socat](http://www.dest-unreach.org/socat/) and
[mpv](https://mpv.io/) internally to play remote mpd streams.
Other integrated applications are only used in some keybindings and are
thus more or less optional or easily replaced. Take a look at the
[rc.lua](config/awesome/rc.lua) config file, it should be rather obvious. To
match GTK applications to the gruvbox colorscheme install
[gruvbox-gtk](https://github.com/3ximus/gruvbox-gtk) and
[gruvbox-dark-icons-gtk](https://github.com/jmattheis/gruvbox-dark-icons-gtk).
To understand how to control my awesome configuration take a look at
[modalawesome](https://github.com/DrCracket/modalawesome).

### Conky, Alacritty, Ranger, Tmux
Some of these applications don't have additional dependencies and if they have,
they are integrated as git submodules or git subtrees so no additional steps
are required.
