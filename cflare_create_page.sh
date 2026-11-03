#!/usr/bin/env bash
set -euo pipefail
pause() { echo; read -t 10 -rp "Fecha em 10s (Enter fecha já)... " _ || true; echo; }
trap pause EXIT   # a janela só fecha depois de você ler o resultado
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"   # pasta raiz (ex.: portal/003)
VARS="$DIR/setups_1234.yml"; KEYS="$DIR/configs_1234.yml"
yget() { { grep -E "^$2:" "$1" || true; } | head -1 | sed -E "s/^$2:[[:space:]]*//; s/\r$//; s/^\"//; s/\"$//"; }
need() { command -v "$1" >/dev/null || { echo "falta: $1"; exit 1; }; }
to_bytes() { local v="${1^^}" num; num="${v//[^0-9]/}"; case "$v" in *GB) echo $((num*1073741824));; *MB) echo $((num*1048576));; *KB) echo $((num*1024));; *) echo "$num";; esac; }

N=$(yget "$VARS" user_num)   # conta definida no setups_1234.yml (user_num)
[[ "$N" =~ ^[0-9]+$ ]] && [ -n "$(yget "$KEYS" "git_user_$N")" ] || { echo "user_num inválido no yml: $N"; exit 1; }
GIT_USER=$(yget "$KEYS" "git_user_$N");   GIT_TOKEN=$(yget "$KEYS" "git_token_$N")
CF_ACCOUNT=$(yget "$KEYS" "cflare_user_$N"); CF_TOKEN=$(yget "$KEYS" "cflare_token_$N")
EMAIL=$(yget "$KEYS" "email_$N")
HOST=$(yget "$VARS" git_host); HOST="${HOST:-github.com}"
NAME="$(yget "$VARS" front_theme)-$(yget "$VARS" page_counter)"; CHUNK=$(yget "$VARS" upload_chunks)

# cada conta tem o seu próprio git (histórico/commits separados), na mesma pasta de trabalho
GD="$DIR/.git_repo$N"
g() { git --git-dir="$GD" --work-tree="$DIR" "$@"; }
prep_git() {
  need git
  [ -f "$GD/HEAD" ] || git --git-dir="$GD" init -q -b main   # pasta pode existir vazia (placeholder)
  g config --local user.name "$GIT_USER"; g config --local user.email "$EMAIL"
  git config --global pack.compression 0; git config --global pack.window 0
  mkdir -p "$GD/info"
  printf '%s\n' '.git_repo*' > "$GD/info/exclude"   # só os repos (git não ignora sozinho pastas fora de .git)
  g remote remove origin 2>/dev/null || true
  g remote add origin "https://$GIT_USER:$GIT_TOKEN@$HOST/$GIT_USER/$NAME.git"
}
# Cria o projeto Pages <tema>-<contador> já ligado ao repo do GitHub (branch main). O deploy sai sempre do Git.
need curl; prep_git
R=$(curl -sS -X POST "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT/pages/projects" \
  -H "Authorization: Bearer $CF_TOKEN" -H "Content-Type: application/json" --data "{
  \"name\": \"$NAME\", \"production_branch\": \"main\",
  \"source\": {\"type\": \"github\", \"config\": {
    \"owner\": \"$GIT_USER\", \"repo_name\": \"$NAME\", \"production_branch\": \"main\",
    \"deployments_enabled\": true, \"production_deployments_enabled\": true,
    \"pr_comments_enabled\": false, \"preview_deployment_setting\": \"none\" }}}")
if echo "$R" | grep -q '"success": *true'; then
  echo "projeto criado e conectado ao Git: $NAME (o 1º deploy começa sozinho)"
  echo "url: https://$NAME.pages.dev"
else
  echo "erro (ou projeto já existe):"; echo "$R"; exit 1
fi
