#!/usr/bin/bash

source scripts/_utils.sh

printf "Skriv noe\n"
read -r INPUT

copy "$INPUT"

anykey
