#!/usr/bin/env bash
# Delete the website: removes every file in the bucket, then the bucket itself.
# Usage: ./teardown.sh <bucket-name>

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

BUCKET="${1:-}"
[ -n "$BUCKET" ] || usage_bucket
require_aws

echo "This permanently deletes s3://$BUCKET and everything in it."
read -r -p "Type the bucket name to confirm: " answer
[ "$answer" = "$BUCKET" ] || { echo "Cancelled."; exit 1; }

echo "==> Deleting all files"
aws s3 rm "s3://$BUCKET" --recursive

echo "==> Deleting bucket"
aws s3api delete-bucket --bucket "$BUCKET" --region "$REGION"

echo "Done. The website is offline and nothing is left to bill."
