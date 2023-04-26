
# Check List OS Hardening (Ubuntu)
The least you can do for os hardening

## Update Ubuntu

```
apt-get clean
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
```
## Set Hostname And Host file
```
hostnamectl set-hostname YOURHOSTNAME
sudo systemctl restart systemd-resolved
cat <<EOF >> /etc/hosts
127.0.0.1   $(hostname)
EOF
```
## Non-Root Accounts Does't Have UID 0

```
awk -F: '($3 == "0") {print}' /etc/passwd
```
---
 ## Create User with "sudo" Privilage

Create Template User for all Servers and set Strong Password

```
sudo adduser easybuntu -p YOUR_PASSWORD
sudo usermod -aG sudo easybuntu
```
---
 ## Disable User root
 ```
sudo passwd -l root
 ```
 
## Firewall
block most outgoing/incoming ports except for updates and SSH 

```
sudo ufw allow in 53 && sudo ufw allow out 53
sudo ufw allow in 53/udp && sudo ufw allow out 53/udp
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw default outgoing deny
sudo ufw default incoming deny
sudo ufw enable
```

---
 ## Disable SSH root login 

```
sudo sed -i 's/.*PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
sudo service ssh restart
```
---
 ## Change SSH Port

```
sudo sed -i 's/.*Port.*/Port 2220/g' /etc/ssh/sshd_config
sudo sed -i 's/.*MaxAuthTries.*/MaxAuthTries 5/g' /etc/ssh/sshd_config
sudo service ssh restart
```
---
 ## Passwordless authentication on SSH

enable public key authentication.

1. Generate SSH Key in Client

```
ssh-keygen -t rsa -b 4096
```
2. Copy Public Key to SSH Remote Server 

```
ssh-copy-id -i ~/.ssh/id_rsa.pub USER_NAME@IP_SERVER
```
3. Disable Password Authentication in SSH Config file

```
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl restart ssh
```

## IP Spoofing protection
```
cat <<EOF >> /etc/host.conf
order bind,hosts
nospoof on
EOF
cat <<EOF >> /etc/sysctl.conf
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.rp_filter = 1
EOF
sudo sysctl -p
```
## Ignore ICMP broadcast requests
```
cat <<EOF >> /etc/sysctl.conf
net.ipv4.icmp_echo_ignore_broadcasts = 1
EOF
sudo sysctl -p
```
## Secure Shared Memory
```
cat <<EOF >> /etc/fstab
tmpfs	/run/shm	tmpfs	ro,noexec,nosuid	0 0
EOF
sudo mount -a
```
---
 ## Fail2Ban
Fail2Ban is a Service for Securing SSH Authentication.If someone wants to ssh into the server and Enter worng Password for many times Fail2Ban Service, blocked client IP for several hours.
```
apt-get install fail2ban -y

cat <<EOF > /etc/fail2ban/jail.local
[DEFAULT]
 bantime = 8h
 ignoreip = 127.0.0.1/8 $(hostname -I | cut -d' ' -f1)
 ignoreself = true

 [sshd]
 enabled = true
 port = 22
 filter = sshd
 logpath = /var/log/auth.log
 maxretry = 3
 EOF
 
 sudo systemctl restart fail2ban
```
