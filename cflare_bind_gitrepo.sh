#!/usr/bin/env bash
set -euo pipefail
pause() { [ -t 0 ] && [ -z "${NO_PAUSE:-}" ] || return 0; echo; read -t 10 -rp "Fecha em 10s (Enter fecha já)... " _ || true; echo; }
trap pause EXIT
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARS="$DIR/setups_1234.yml"; KEYS="$DIR/configs_1234.yml"
yget() { { grep -E "^$2:" "$1" || true; } | head -1 | sed -E "s/^$2:[[:space:]]*//; s/\r$//; s/^\"//; s/\"$//"; }
need() { command -v "$1" >/dev/null || { echo "falta: $1"; exit 1; }; }

N=$(yget "$VARS" user_num)
[[ "$N" =~ ^[0-9]+$ ]] && [ -n "$(yget "$KEYS" "git_user_$N")" ] || { echo "user_num inválido no yml: $N"; exit 1; }
GIT_USER=$(yget "$KEYS" "git_user_$N")
CF_ACCOUNT=$(yget "$KEYS" "cflare_user_$N"); CF_TOKEN=$(yget "$KEYS" "cflare_token_$N")
NAME="$(yget "$VARS" front_theme)-$(yget "$VARS" page_counter)"

# Liga um projeto Pages JÁ EXISTENTE ao repo <tema>-<contador> do GitHub (branch main).
# Uso: ./cflare_bind_gitrepo.sh
need curl
R=$(curl -sS --connect-timeout 10 --max-time 10 -X PATCH "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT/pages/projects/$NAME" \
  -H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json" --data "{
  \"production_branch\": \"main\",
  \"source\": {\"type\": \"github\", \"config\": {
    \"owner\": \"$GIT_USER\", \"repo_name\": \"$NAME\", \"production_branch\": \"main\",
    \"deployments_enabled\": true, \"production_deployments_enabled\": true,
    \"pr_comments_enabled\": false, \"preview_deployment_setting\": \"none\" }}}")
if echo "$R" | grep -q '"success": *true'; then
  echo "projeto $NAME ligado ao repo $GIT_USER/$NAME"
  echo "url: https://$NAME.pages.dev"
else
  echo "erro (ou sem resposta em 10s):"; echo "$R"
  echo "dica: projeto criado por upload direto não aceita Git depois; apague e rode cflare_create_page.sh"
  exit 1
fi
