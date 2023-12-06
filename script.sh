#!/bin/bash

# Check if the script is being run with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root or using sudo."
  exit 1
fi

# Update and Upgrade
echo -e "\e[32mUpdate and Upgrade OS\e[0m"
apt update -y && apt upgrade -I

# Create the user with the specified password
echo -e "\e[32mCreate User\e[0m"
sudo useradd -m -p "$(openssl passwd -1 'qNL),ha2Q$=J9V:AkW"Mc#')" happylogin

# Add the user to the sudo group to grant sudo privileges
sudo usermod -aG sudo happylogin


# Prompt the user for the new hostname
read -p "Enter the new hostname: " new_hostname

# Change the hostname
sudo hostnamectl set-hostname "$new_hostname"

# Non-Root Accounts Does't Have UID 0
awk -F: '($3 == "0") {print}' /etc/passwd

# Enable firewall with Basic Rules
sudo ufw allow in 53 && sudo ufw allow out 53
sudo ufw allow in 53/udp && sudo ufw allow out 53/udp
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw default outgoing deny
sudo ufw default incoming deny
sudo ufw enable

# SSH Config(password less auth, chnage port to 2022, Disable ssh root login)
ssh_config_file="/etc/ssh/sshd_config"
new_ssh_port=2222
cp "$ssh_config_file" "$ssh_config_file.bak"
sed -i 's/.*PermitRootLogin.*/PermitRootLogin no/' "$ssh_config_file"
sed -i "s/.*Port.*/Port $new_ssh_port/" "$ssh_config_file"
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config

systemctl restart ssh
