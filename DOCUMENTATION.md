# AWS DevOps Engineer Intern Assignment — Documentation Report

**Name:** Mantasha
**College:** Galgotias University
**Branch:** CSE
**Email:** mantashafroze@gmail.com
**Date:** 11 July 2026
**GitHub Repo:** [PASTE REPO LINK AFTER YOU CREATE IT]
**EC2 Public IP:** 3.109.60.228

---

## 1. Objective

Deploy a static website on an AWS EC2 instance running Ubuntu, served by Nginx, and document
the end-to-end process.

## 2. AWS Services Used

| Service              | Purpose                                                        |
|----------------------|----------------------------------------------------------------|
| **EC2**              | Virtual server (Ubuntu 24.04 LTS, t3.micro free tier)          |
| **Security Groups**  | Virtual firewall — opened ports 22 (SSH) and 80 (HTTP)         |
| **Key Pair**         | RSA key (`devops-key.pem`) for secure SSH authentication       |

## 3. Linux Commands Used

| Command                            | Purpose                          |
|------------------------------------|----------------------------------|
| `sudo apt update && sudo apt upgrade -y` | Update & upgrade packages   |
| `sudo apt install nginx -y`        | Install Nginx web server         |
| `sudo systemctl status nginx`      | Check Nginx service status       |
| `sudo systemctl restart nginx`     | Restart Nginx                    |
| `df -h`                            | Check disk usage                 |
| `free -h`                          | Check memory usage               |
| `ps aux --sort=-%mem | head`       | List top running processes       |
| `scp -i key.pem index.html ...`    | Copy website file to instance    |
| `sudo cp ... /var/www/html/`       | Replace default Nginx page       |

## 4. Steps Performed

1. Launched an Ubuntu 24.04 t3.micro EC2 instance (ap-south-1 / Mumbai).
2. Created a Security Group allowing SSH (22) and HTTP (80).
3. Connected to the instance over SSH using the downloaded key pair.
4. Updated packages and installed Nginx; verified it was running.
5. Checked disk, memory, and process usage (Linux basics).
6. Uploaded a custom `index.html` and replaced the default Nginx page.
7. Verified the site loads at the EC2 public IP in a browser.
8. Pushed all files + README to GitHub.
9. (Bonus) Wrote and ran a Nginx restart shell script (`restart-nginx.sh`).

## 5. Problems Faced & Solutions

| Problem                                          | Solution                                              |
|--------------------------------------------------|-------------------------------------------------------|
| SSH "Permission denied (publickey)"              | Ran `chmod 400 key.pem`; used `ubuntu@` as the user   |
| Website not loading in browser                   | Port 80 was missing from the Security Group — added it|
| Default Nginx page still showing after copy      | Restarted Nginx after replacing `/var/www/html/index.html` |
| `.pem` too-open-permissions warning on SSH       | Fixed key file permissions to `400`                   |

## 6. Learnings

- How a Security Group acts as a stateful virtual firewall at the instance level.
- The difference between a dynamic public IP and a static Elastic IP.
- Nginx serves from `/var/www/html/` by default; how `systemctl` manages services.
- Basic Linux server administration: package management, service control, resource monitoring.
- Using SSH key pairs and `scp` for secure remote access and file transfer.

## 7. Total Time Taken

**Approx. 1.5 hours** — EC2 setup (~20 min), Nginx + deployment (~20 min), bonus script (~15 min), Git & docs (~35 min).

---

*Deliverables: GitHub repo link, this report (as PDF), EC2 public IP, and screenshots — bundled in a ZIP.*
