# AWS Static Website Hosting — EC2 + Nginx and Amazon S3

Two ways to host a static website on AWS, side by side:

| | Method 1: EC2 + Nginx | Method 2: Amazon S3 |
|---|---|---|
| **What's hosted** | `index.html` (assignment page) | [`portfolio/`](portfolio/) — Mantasha's interactive portfolio |
| **You manage** | A Linux server: OS updates, Nginx, firewall | Nothing — AWS runs the web serving |
| **Scaling** | One instance (add a load balancer to scale) | Automatic |
| **Cost** | Pay per hour the instance runs (free tier: t3.micro) | Pay per GB stored + requests (pennies for a small site) |
| **Best for** | Sites that later need server-side code | Pure static sites (HTML/CSS/JS) |

---

## Method 1 — Static site on EC2 + Nginx

```
Browser ──HTTP:80──> [ AWS EC2 (Ubuntu 24.04) ]
                          │
                          └── Nginx ──serves──> /var/www/html/index.html
SSH:22 ──> EC2 (admin access)
```

**AWS services used:** EC2, Security Groups, Key Pair. **Bonus:** Nginx restart shell script.

> The EC2 instance has been shut down to avoid charges, so the old public IP no
> longer serves this site. Follow the steps below to bring it up again.

### 1. Launch the EC2 instance

1. AWS Console → **EC2** → **Launch instance**.
2. Name: `devops-assignment`. AMI: **Ubuntu Server 24.04 LTS**. Type: **t3.micro** (free tier).
3. Create a key pair (`.pem`), download it.
4. **Security Group** — allow inbound:
   | Type  | Port | Source     |
   |-------|------|------------|
   | SSH   | 22   | My IP      |
   | HTTP  | 80   | 0.0.0.0/0  |
5. Launch, then copy the **Public IPv4 address**.

### 2. Connect via SSH

```bash
chmod 400 devops-key.pem
ssh -i devops-key.pem ubuntu@<EC2_PUBLIC_IP>
```

### 3. Install & configure Nginx (run on the EC2 instance)

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

### 4. Deploy the website

```bash
# From your local machine, copy index.html to the instance:
scp -i devops-key.pem index.html ubuntu@<EC2_PUBLIC_IP>:/tmp/

# On the instance, replace the default Nginx page:
sudo cp /tmp/index.html /var/www/html/index.html
sudo systemctl restart nginx
```

Open `http://<EC2_PUBLIC_IP>` in a browser — the custom page should load.

### 5. Bonus — restart script

`restart-nginx.sh` restarts Nginx and reports status:

```bash
chmod +x restart-nginx.sh
./restart-nginx.sh
```

---

---

## Method 2 — Portfolio on Amazon S3 static website hosting

```
Browser ──HTTP──> S3 website endpoint ──> bucket: index.html, error.html, Mantasha_Resume.pdf
                         ▲
Laptop ── deploy.sh (aws s3 sync) ──┘     IAM user limited to this one bucket
```

**AWS services used:** S3 (static website hosting, bucket policy, Block Public Access), IAM.

### Security design

- **Bucket policy** ([`s3/bucket-policy.json`](s3/bucket-policy.json)) allows the public to
  *read* objects (`s3:GetObject`) and nothing else — no listing, no uploads.
- **Block Public Access** stays on for ACLs; only the bucket policy may grant public read.
- **Least-privilege deploy user** ([`s3/iam-deploy-policy.json`](s3/iam-deploy-policy.json)) can
  list, upload and delete files in **this one bucket only** — it can't touch any other AWS resource.

### 0. Install the AWS CLI (one time)

Windows (PowerShell):

```powershell
winget install Amazon.AWSCLI
```

Then close and reopen the terminal and check: `aws --version`.
Run the scripts below from **Git Bash** (installed with Git for Windows).

### 1. Credentials

1. AWS Console → **IAM** → **Users** → **Create user** (e.g. `portfolio-admin`) with
   `AmazonS3FullAccess` for the one-time setup.
2. Open the user → **Security credentials** → **Create access key** → *Command Line Interface*.
3. On the laptop:
   ```bash
   aws configure        # paste the key + secret, region: ap-south-1, output: json
   ```

> Never commit access keys. They live only in `~/.aws/credentials`.

### 2. Create the website bucket

Bucket names are global across all of AWS, so pick something unique:

```bash
cd s3
./setup.sh mantasha-portfolio-2026
```

This creates the bucket in `ap-south-1` (Mumbai), enables static website hosting with
`index.html` / `error.html`, and applies the public-read bucket policy.

### 3. Deploy the portfolio

```bash
./deploy.sh mantasha-portfolio-2026
```

It uploads `portfolio/` with `aws s3 sync --delete` (HTML is sent with `no-cache` so
updates appear immediately) and prints the live URL:

```
http://mantasha-portfolio-2026.s3-website.ap-south-1.amazonaws.com
```

Edit anything in `portfolio/` and run `./deploy.sh` again to update the live site.

### 4. (Recommended) Switch to the least-privilege deploy user

1. IAM → **Policies** → **Create policy** → JSON → paste
   [`s3/iam-deploy-policy.json`](s3/iam-deploy-policy.json), replacing `BUCKET_NAME` with your bucket.
2. Create a user `portfolio-deployer`, attach only that policy, create an access key.
3. `aws configure --profile deployer`, then deploy with
   `AWS_PROFILE=deployer ./deploy.sh mantasha-portfolio-2026`.

### 5. Tear down

```bash
./teardown.sh mantasha-portfolio-2026
```

Asks you to type the bucket name, then deletes all files and the bucket.

### Troubleshooting

| Symptom | Fix |
|---|---|
| `AccessDenied` on `put-bucket-policy` | Account-level Block Public Access is on: S3 console → **Block Public Access settings for this account** → uncheck *block public bucket policies*, then re-run `setup.sh`. |
| `BucketAlreadyExists` | Someone else owns that name — choose another. |
| `403 Forbidden` in the browser | The bucket policy isn't applied — re-run `setup.sh`. |
| `404` for the homepage | Nothing deployed yet — run `deploy.sh`. |

### Next step: HTTPS

S3 website endpoints are HTTP only. Putting **CloudFront** in front (with an ACM
certificate) adds HTTPS, caching at edge locations and a custom domain.

---

## Files in this repo

| File | Purpose |
|---|---|
| `index.html` | Method 1 — the page served by Nginx on EC2 |
| `restart-nginx.sh` | Method 1 — validate config and restart Nginx |
| `portfolio/` | Method 2 — the portfolio site (`index.html`, `error.html`, resume PDF) |
| `s3/setup.sh` | Method 2 — create the bucket and enable website hosting |
| `s3/deploy.sh` | Method 2 — upload the portfolio (`aws s3 sync`) |
| `s3/teardown.sh` | Method 2 — delete the bucket |
| `s3/bucket-policy.json` | Public read of website files only |
| `s3/iam-deploy-policy.json` | Least-privilege policy for the deploy user |
| `DOCUMENTATION.md` | Full report for the original EC2 assignment |
