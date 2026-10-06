#!/usr/bin/env bash
# Shared settings and helpers for setup.sh, deploy.sh and teardown.sh.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_DIR="$SCRIPT_DIR/../portfolio"
REGION="${AWS_REGION:-ap-south-1}"   # Mumbai by default; override with AWS_REGION

usage_bucket() {
  echo "Usage: $0 <bucket-name>" >&2
  echo "  Bucket names are global across all AWS accounts, e.g. mantasha-portfolio-2026" >&2
  exit 1
}

require_aws() {
  if ! command -v aws >/dev/null 2>&1; then
    echo "ERROR: AWS CLI not found. Install it first (see README, 'Install the AWS CLI')." >&2
    exit 1
  fi
  if ! aws sts get-caller-identity --query Arn --output text >/dev/null 2>&1; then
    echo "ERROR: AWS CLI has no working credentials. Run 'aws configure' first." >&2
    exit 1
  fi
}

# S3 website endpoints use "s3-website-<region>" in older regions and
# "s3-website.<region>" in newer ones (ap-south-1 is a newer one).
website_url() {
  local bucket="$1"
  case "$REGION" in
    us-east-1|us-west-1|us-west-2|eu-west-1|ap-southeast-1|ap-southeast-2|ap-northeast-1|sa-east-1)
      echo "http://${bucket}.s3-website-${REGION}.amazonaws.com" ;;
    *)
      echo "http://${bucket}.s3-website.${REGION}.amazonaws.com" ;;
  esac
}
