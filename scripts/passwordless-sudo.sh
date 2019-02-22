#!/usr/bin/env bash

comment="# Passwordless sudo for khoe user"
directive="$USER ALL=(ALL) NOPASSWD: ALL"

if sudo grep -Fxq "$directive" /etc/sudoers
then
    printf "%s\n" "Passwordless sudo for khoe user is already set up."
else
    printf "%s\n" "Setting up passwordless sudo for khoe user."
    sudo cp /etc/sudoers /etc/sudoers~
    printf "\n%s\n%s\n" "$comment" "$directive" | sudo tee -a /etc/sudoers  > /dev/null
    printf "%s\n" "Done"
fi
