# Submission Checklist — screenshots to capture & what to zip

## Screenshots to take (name them exactly, drop into a `screenshots/` folder)

**Task 1 — EC2**
- [ ] `01-ec2-dashboard.png` — EC2 console showing your instance "running"
- [ ] `02-security-group.png` — Security Group inbound rules (ports 22 & 80)
- [ ] `03-ssh-login.png` — terminal after successful SSH login (shows `ubuntu@ip-...`)

**Task 2 — Linux Basics**
- [ ] `04-nginx-status.png` — output of `sudo systemctl status nginx` (active/running)
- [ ] `05-disk-mem-proc.png` — output of `df -h`, `free -h`, `ps aux | head`

**Task 3 — Website**
- [ ] `06-website-browser.png` — browser at `http://<PUBLIC_IP>` showing your page (URL bar visible)

**Bonus (pick one)**
- [ ] `07-bonus.png` — Elastic IP attached / `docker run hello-world` / `./restart-nginx.sh` output

## Before submitting, fill in the remaining placeholders
- [ ] `DOCUMENTATION.md` → repo link, public IP, total time taken
- [ ] `README.md` → replace `<EC2_PUBLIC_IP>` with your real IP
- (Name / College / Branch / Email are already filled in.)

## Final ZIP contents
```
submission.zip
├── screenshots/           (7 images above)
├── DOCUMENTATION.pdf      (export DOCUMENTATION.md to PDF)
└── links.txt              (GitHub repo URL + EC2 public IP)
```

## GitHub steps (Task 4)
```bash
cd aws-devops-assignment
git init
git add index.html README.md restart-nginx.sh DOCUMENTATION.md
git commit -m "AWS DevOps assignment: static site on EC2 + Nginx"
git branch -M main
git remote add origin https://github.com/<you>/aws-devops-assignment.git
git push -u origin main
```
