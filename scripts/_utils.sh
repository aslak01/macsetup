#!/usr/bin/env bash

color_reset=$(tput sgr0)
color_red=$(tput setaf 1)
color_green=$(tput setaf 2)
color_yellow=$(tput setaf 3)
color_magenta=$(tput setaf 5)

bold=$(tput bold)
normal=$(tput sgr0)

e_anykey() {
  e_pending "$1"
  read -rsn1 -p " ";
  printf "\n"
}


e_pending() {
  printf "${color_yellow}⚡️ %s...${color_reset}" "$@"
  printf "\n"
}

e_failure() {
  printf "${color_red}✕  %s${color_reset}" "$@"
  printf "\n"
}

e_success() {
  printf "${color_green}✔  %s${color_reset}" "$@"
  printf "\n"
}

e_settled() {
  printf "${color_yellow}✨ %s!${color_reset}" "$@"
  printf "\n"
}

e_magenta() {
  printf "${color_magenta}%s${color_reset}" "$@"
  printf "\n"
}
e_bold() {
  printf "${bold}%s${normal}" "$@"
}

copy() {
  echo -n "$(pwd)" | pbcopy
}

has_command() {
  if [ $(type -p $1) ]; then
    return 0
  fi
  return 1
}

test_command() {
  if has_command $1; then
    e_success "$1"
  else
    e_failure "$1"
  fi
}

has_nvm() {
  if [ -e "~/.nvm/nvm.sh" ]; then
    return 1
  fi
  return 0
}

test_nvm() {
  if has_nvm; then
    e_success "nvm"
  else
    e_failure "nvm"
  fi
}

has_brew() {
  if $(brew ls --versions $1 > /dev/null); then
    return 0
  fi
  return 1
}

test_brew() {
  if has_brew $1; then
    e_success "$1"
  else
    e_failure "$1"
  fi
}

has_cask() {
  if $(brew list --cask $1 > /dev/null); then
    return 0
  fi
  return 1
}

test_cask() {
  if has_cask $1; then
    e_success "$1"
  else
    e_failure "$1"
  fi
}

has_path() {
  local path="$@"
  if [ -e "$HOME/$path" ]; then
    return 0
  fi
  return 1
}

test_path() {
  # local path=$(echo "$@" | sed 's:.*/::')
  if has_path $1; then
    # e_success "$path"
    e_success "$1"
  else
    # e_failure "$path"
    e_failure "$1"
  fi
}

has_app() {
  local name="$@"
  if [ -e "/Applications/$name.app" ]; then
    return 0
  fi
  return 1
}

test_app() {
  if has_app $1; then
    e_success "$1"
  else
    e_failure "$1"
  fi
}

has_consent() {
  if [[ "$REPLY" =~ ^[Yy]$ ]]; then
    return 0
  fi
  return 1
}

get_consent() {
  printf "❔ %s [y/n]:" "$@"
  read -p " " -n 1
  printf "\n"
}

if ! [[ "${OSTYPE}" == "darwin"* ]]; then
  e_failure "Unsupported operating system (macOS only)"
  exit 1
fi

INTRO="
███    ███  █████   ██████     ███████ ███████ ████████ ██    ██ ██████  
████  ████ ██   ██ ██          ██      ██         ██    ██    ██ ██   ██ 
██ ████ ██ ███████ ██          ███████ █████      ██    ██    ██ ██████  
██  ██  ██ ██   ██ ██               ██ ██         ██    ██    ██ ██      
██      ██ ██   ██  ██████     ███████ ███████    ██     ██████  ██"

SEP="========================================================================"

refresh_header() {
  clear
  printf "%s" "$INTRO"
  printf "\n"
  printf "%s" "$SEP"
  printf "\n\n\n"
}
