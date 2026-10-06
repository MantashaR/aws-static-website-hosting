#!/usr/bin/env bash
# One-time setup: create the S3 bucket and turn it into a public static website.
# Usage: ./setup.sh <bucket-name>

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

BUCKET="${1:-}"
[ -n "$BUCKET" ] || usage_bucket
require_aws

echo "==> Account: $(aws sts get-caller-identity --query Arn --output text)"
echo "==> Region:  $REGION"

echo "==> [1/4] Creating bucket s3://$BUCKET"
if aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
  echo "    Bucket already exists in this account, reusing it."
elif [ "$REGION" = "us-east-1" ]; then
  aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" >/dev/null
else
  aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION" >/dev/null
fi

# New buckets block all public access. Keep ACLs blocked (we never use them)
# and only allow the bucket policy below to grant public read.
echo "==> [2/4] Allowing a public-read bucket policy (ACLs stay blocked)"
aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=false,RestrictPublicBuckets=false

echo "==> [3/4] Enabling static website hosting (index.html / error.html)"
aws s3 website "s3://$BUCKET" --index-document index.html --error-document error.html

echo "==> [4/4] Applying bucket policy (public read of website files only)"
POLICY="$(sed "s/BUCKET_NAME/$BUCKET/g" "$SCRIPT_DIR/bucket-policy.json")"
aws s3api put-bucket-policy --bucket "$BUCKET" --policy "$POLICY"

echo
echo "Done. Next: ./deploy.sh $BUCKET"
echo "Website URL (after deploy): $(website_url "$BUCKET")"
