#!/usr/bin/env bash
set -euo pipefail

cd "${HOME}"

ln -sfn dotfiles/git/.gitconfig .gitconfig
ln -sfn dotfiles/git/.gitconfig_personal .gitconfig_personal
ln -sfn dotfiles/git/.gitignore_global .gitignore

ln -sfn dotfiles/tmux/.tmux .tmux
ln -sfn dotfiles/tmux/.tmux.conf .tmux.conf

ln -sfn dotfiles/vim/.vim .vim
ln -sfn dotfiles/vim/.vimrc .vimrc

ln -sfn dotfiles/zsh/.zshenv .zshenv
ln -sfn dotfiles/zsh/.zshrc .zshrc
ln -sfn dotfiles/zsh/.zshrc .zshrc.pre-oh-my-zsh

ln -sfn dotfiles/bash/.bashrc .bashrc
ln -sfn dotfiles/csh/.cshrc.local .cshrc.local
ln -sfn dotfiles/mtools/.mtoolsrc .mtoolsrc
