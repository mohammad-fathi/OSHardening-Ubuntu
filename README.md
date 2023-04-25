
# Check List OS Hardening (Ubuntu)

 ## Always be Update

```
sudo apt update
```
---
 ## Create User with "sudo" Privilage

Create Template User for all Servers

```
sudo adduser easybuntu -p YOUR_PASSWORD
sudo usermod -aG sudo easybuntu
```
---
## Non-Root Accounts Does't Have UID 0

```
awk -F: '($3 == "0") {print}' /etc/passwd
```

---
 ## Disable User root
 ```
sudo passwd -l root
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
3. Copy Public Key to SSH Remote Server 

```
ssh-copy-id -i ~/.ssh/id_rsa.pub USER_NAME@IP_SERVER
```
5. Disable Password Authentication in SSH Config file

```
sed -i 's/.*PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl restart ssh
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
