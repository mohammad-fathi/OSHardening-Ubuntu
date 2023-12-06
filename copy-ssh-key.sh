#!/bin/bash

# Generate SSH key pair if it doesn't exist
if [ ! -f ~/.ssh/id_rsa ]; then
  ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa -N ""
  echo "SSH key pair generated."
fi
# Copy the public key to the remote server
read -p "Enter the remote server's hostname or IP address: " remote_server
read -p "Enter the remote user's username: " remote_user
read -p "Enter the remote user's password: " -s remote_password

sshpass -p "$remote_password" ssh-copy-id -i ~/.ssh/id_rsa.pub "$remote_user@$remote_server"

if [ $? -eq 0 ]; then
  echo "Passwordless SSH authentication set up successfully."
else
  echo "Failed to set up passwordless SSH authentication."
fi
