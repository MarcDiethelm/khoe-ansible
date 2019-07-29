#!/usr/bin/env bash

comment="# Passwordless sudo for user $1"
directive="$1 ALL=(ALL) NOPASSWD: ALL"

if sudo grep -Fxq "$directive" /etc/sudoers
then
    printf "%s\n" "Passwordless sudo is already set up for: $1."
else
    printf "%s\n" "Setting up passwordless sudo for user: $1."
    sudo cp /etc/sudoers /etc/sudoers~
    printf "\n%s\n%s\n" "$comment" "$directive" | sudo tee -a /etc/sudoers  > /dev/null
    printf "%s\n" "Done"
fi
