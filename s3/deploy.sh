#!/usr/bin/env bash
# Upload the portfolio to the bucket. Safe to re-run after every change.
# Usage: ./deploy.sh <bucket-name>

source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

BUCKET="${1:-}"
[ -n "$BUCKET" ] || usage_bucket
require_aws

[ -f "$SITE_DIR/index.html" ] || { echo "ERROR: $SITE_DIR/index.html not found" >&2; exit 1; }

# HTML is re-checked on every visit so updates show up immediately;
# everything else (the resume PDF) can be cached for a day.
echo "==> Uploading HTML (no-cache)"
aws s3 sync "$SITE_DIR" "s3://$BUCKET" --delete \
  --exclude "*" --include "*.html" \
  --cache-control "no-cache"

echo "==> Uploading other files (cached for 1 day)"
aws s3 sync "$SITE_DIR" "s3://$BUCKET" --delete \
  --exclude "*.html" --exclude ".*" \
  --cache-control "max-age=86400"

URL="$(website_url "$BUCKET")"
echo
echo "Deployed. Live at: $URL"

if command -v curl >/dev/null 2>&1; then
  code="$(curl -s -o /dev/null -w '%{http_code}' "$URL" || true)"
  echo "Health check: HTTP $code $([ "$code" = 200 ] && echo '(OK)' || echo '(give it a minute, then refresh)')"
fi
