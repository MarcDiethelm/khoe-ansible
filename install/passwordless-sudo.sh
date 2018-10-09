sudo cp /etc/sudoers /etc/sudoers~
echo "\n$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
