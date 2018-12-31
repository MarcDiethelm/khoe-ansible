sudo cp /etc/sudoers /etc/sudoers~
printf "\n%s\n%s\n" "# Passwordless sudo for khoe user" "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
