#!/usr/bin/env bash

git clone git@github.com:aslak01/dotfiles.git "$HOME"/dotfiles

cd "$HOME"/dotfiles || exit

stow .

