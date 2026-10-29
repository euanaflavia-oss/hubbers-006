#!/bin/bash
GHT=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
GLT=glpat-qFXtX8FXPsfUXYKiU-lWG2M6MQpvOjEKdTptOXhreQ8.01.171b2rfqp
GL=mikealvarrez/acompanhantes-de-luxo
GH=eumariahelenap/acompanhantes-de-luxo
API=https://api.github.com
H="Authorization: Bearer $GHT"
export GIT_TERMINAL_PROMPT=0

curl -s -X POST -H "$H" $API/user/repos -d '{"name":"acompanhantes-de-luxo","private":true}' >/dev/null

mkdir -p .github/workflows
cat > .github/workflows/main.yml <<EOF
name: mirror-gitlab
on:
  workflow_dispatch:
jobs:
  mirror:
    runs-on: ubuntu-latest
    steps:
      - run: |
          git clone --bare "https://oauth2:$GLT@gitlab.com/$GL.git" r
          cd r
          git config http.postBuffer 524288000
          for c in \$(git rev-list --reverse master | awk 'NR%300==0'); do
            git push --force "https://$GHT@github.com/$GH.git" \$c:refs/heads/master
          done
          git push --force "https://$GHT@github.com/$GH.git" master:master master:main
EOF

git init -q
git config --local user.name  "MA"
git config --local user.email "mikealvarrez.02@gmail.com"
git add .
git commit -qm "." || true
git -c credential.helper= push --force "https://oauth2:$GLT@gitlab.com/$GL.git" HEAD:master HEAD:main

SHA=$(curl -s -H "$H" $API/repos/$GH/contents/.github/workflows/main.yml | grep -m1 '"sha"' | cut -d'"' -f4)
B64=$(base64 -w0 .github/workflows/main.yml)
if [ -n "$SHA" ]; then EXTRA=",\"sha\":\"$SHA\""; else EXTRA=""; fi
curl -s -X PUT -H "$H" $API/repos/$GH/contents/.github/workflows/main.yml \
  -d "{\"message\":\"wf\",\"content\":\"$B64\"$EXTRA}" | grep -m1 -E '"message"|"path"'

BR=$(curl -s -H "$H" $API/repos/$GH | grep -m1 '"default_branch"' | cut -d'"' -f4)
sleep 5
curl -s -i -X POST -H "$H" $API/repos/$GH/actions/workflows/main.yml/dispatches -d "{\"ref\":\"$BR\"}" | head -1
echo "Acompanhe: https://github.com/$GH/actions"