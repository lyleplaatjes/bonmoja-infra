#!/usr/bin/env bash
set -euo pipefail

ALB_URL="$1"   # e.g. http://my-alb-123.eu-west-1.elb.amazonaws.com/
PATH_TO_CHECK="${2:-/}"   # default "/"
MAX_RETRIES="${3:-20}"
SLEEP_SECONDS="${4:-10}"

echo "Health check against: ${ALB_URL}${PATH_TO_CHECK}"

for i in $(seq 1 "$MAX_RETRIES"); do
  echo "Attempt $i/${MAX_RETRIES}..."
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${ALB_URL}${PATH_TO_CHECK}" || true)
  if [[ "$STATUS" =~ ^2|3[0-9]$ ]]; then
    echo "✅ Healthy (HTTP $STATUS)"
    exit 0
  fi
  echo "Got HTTP $STATUS. Retrying in ${SLEEP_SECONDS}s..."
  sleep "$SLEEP_SECONDS"
done

echo "❌ Health check failed after ${MAX_RETRIES} attempts."
exit 1
