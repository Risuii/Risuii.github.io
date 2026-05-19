#!/usr/bin/env bash
# Deploy landing page ke https://risuii.github.io/
set -euo pipefail
cd "$(dirname "$0")"

OWNER="${GITHUB_OWNER:-Risuii}"
REPO="${GITHUB_REPO:-Risuii.github.io}"
REMOTE_URL="https://github.com/${OWNER}/${REPO}.git"

if ! command -v gh >/dev/null 2>&1; then
  echo "Install GitHub CLI: brew install gh"
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Login GitHub (HTTPS disarankan):"
  gh auth login
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "${REMOTE_URL}"
fi

if gh repo view "${OWNER}/${REPO}" >/dev/null 2>&1; then
  echo "Push ke origin (${OWNER}/${REPO})..."
  git push -u origin main
else
  echo "Buat repo ${OWNER}/${REPO} dan push..."
  gh repo create "${REPO}" --public \
    --description "Faris Fahmi — Tenaga Ahli IT freelance landing page" \
    --source=. --remote=origin --push
fi

echo "Aktifkan GitHub Pages (GitHub Actions)..."
if gh api "/repos/${OWNER}/${REPO}/pages" >/dev/null 2>&1; then
  gh api -X PUT "/repos/${OWNER}/${REPO}/pages" \
    -f build_type=workflow >/dev/null
else
  gh api -X POST "/repos/${OWNER}/${REPO}/pages" \
    -f build_type=workflow >/dev/null
fi

echo ""
echo "Deploy workflow: https://github.com/${OWNER}/${REPO}/actions"
echo "Situs (1–2 menit): https://risuii.github.io/"
