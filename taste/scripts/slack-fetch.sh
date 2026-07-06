#!/bin/bash
# Download a Slack file by ID into taste/images/. Used by /taste-pull to save
# real image files (the Slack MCP can view images but not write them to disk).
#
# Setup once: copy taste/.env.example to taste/.env and paste your Slack token.
# Usage: taste/scripts/slack-fetch.sh <file_id> <dest_path>
set -euo pipefail

FILE_ID="${1:?usage: slack-fetch.sh <file_id> <dest_path>}"
DEST="${2:?usage: slack-fetch.sh <file_id> <dest_path>}"

HERE="$(cd "$(dirname "$0")/.." && pwd)"
[ -f "$HERE/.env" ] && set -a && . "$HERE/.env" && set +a

if [ -z "${SLACK_TOKEN:-}" ]; then
  echo "no-token" >&2
  exit 3
fi

# Ask Slack for the private download URL, then fetch the bytes with the token.
INFO="$(curl -s -H "Authorization: Bearer $SLACK_TOKEN" \
  "https://slack.com/api/files.info?file=$FILE_ID")"

URL="$(printf '%s' "$INFO" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d["file"]["url_private_download"] if d.get("ok") else "")')"

if [ -z "$URL" ]; then
  echo "fetch-failed: $(printf '%s' "$INFO" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("error","unknown"))' 2>/dev/null || echo parse-error)" >&2
  exit 4
fi

mkdir -p "$(dirname "$DEST")"
curl -s -H "Authorization: Bearer $SLACK_TOKEN" -o "$DEST" "$URL"
echo "$DEST"
