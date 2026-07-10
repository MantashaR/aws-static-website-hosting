# AWS DevOps Engineer Intern Assignment — Static Site on EC2 + Nginx

Deploys a simple static website on an **Ubuntu EC2 instance** served by **Nginx**.

**Live URL:** `http://<EC2_PUBLIC_IP>`  ← replace with your instance's public IP

---

## Architecture

```
Browser ──HTTP:80──> [ AWS EC2 (Ubuntu 22.04) ]
                          │
                          └── Nginx ──serves──> /var/www/html/index.html
SSH:22 ──> EC2 (admin access)
```

**AWS services used:** EC2, Security Groups, Elastic IP (bonus).

---

## 1. Launch the EC2 instance

1. AWS Console → **EC2** → **Launch instance**.
2. Name: `devops-assignment`. AMI: **Ubuntu Server 22.04 LTS**. Type: **t2.micro** (free tier).
3. Create a key pair (`.pem`), download it.
4. **Security Group** — allow inbound:
   | Type  | Port | Source     |
   |-------|------|------------|
   | SSH   | 22   | My IP      |
   | HTTP  | 80   | 0.0.0.0/0  |
5. Launch, then copy the **Public IPv4 address**.

## 2. Connect via SSH

```bash
chmod 400 devops-assignment.pem
ssh -i devops-assignment.pem ubuntu@<EC2_PUBLIC_IP>
```

## 3. Install & configure Nginx (run on the EC2 instance)

```bash
sudo apt update && sudo apt upgrade -y      # update packages
sudo apt install nginx -y                   # install Nginx
sudo systemctl status nginx                 # check status (should be "active (running)")
sudo systemctl restart nginx                # restart Nginx

# Linux basics checks
df -h                                        # disk usage
free -h                                      # memory usage
ps aux --sort=-%mem | head                   # running processes
```

## 4. Deploy the website

```bash
# From your local machine, copy index.html to the instance:
scp -i devops-assignment.pem index.html ubuntu@<EC2_PUBLIC_IP>:/tmp/

# On the instance, replace the default Nginx page:
sudo cp /tmp/index.html /var/www/html/index.html
sudo systemctl restart nginx
```

Open `http://<EC2_PUBLIC_IP>` in a browser — the custom page should load.

## 5. Bonus — restart script

`restart-nginx.sh` restarts Nginx and reports status:

```bash
chmod +x restart-nginx.sh
./restart-nginx.sh
```

---

## Files in this repo

| File               | Purpose                                    |
|--------------------|--------------------------------------------|
| `index.html`       | The website served by Nginx                |
| `README.md`        | This file — setup steps & commands         |
| `restart-nginx.sh` | Bonus: shell script to restart Nginx       |
| `DOCUMENTATION.md` | Full report (convert to PDF for submission)|

## Author

**Mantasha** · Galgotias University · CSE · mantashafroze@gmail.com
