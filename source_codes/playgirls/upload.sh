# https://github.com/settings/tokens
# https://gitlab.com/-/user_settings/personal_access_tokens


# rm -f ~/.ssh/id_ed25519_gitlab ~/.ssh/id_ed25519_gitlab.pub
# ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519_gitlab -C "gitlab" -q
# curl -s --header "PRIVATE-TOKEN: glpat-qFXtX8FXPsfUXYKiU-lWG2M6MQpvOjEKdTptOXhreQ8.01.171b2rfqp" --data-urlencode "title=auto-$(date +%s)" --data-urlencode "key=$(cat ~/.ssh/id_ed25519_gitlab.pub)" "https://gitlab.com/api/v4/user/keys" > /dev/null
# sleep 5
# export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_gitlab -o StrictHostKeyChecking=no"
# git init
# git config --global user.name  "MA"
# git config --global user.email "mikealvarrez.02@gmail.com"
# git config --global pack.compression 0
# git config --global pack.window 0
# git remote add     origin git@gitlab.com:mikealvarrez/playgirls-002.git
# git remote set-url origin git@gitlab.com:mikealvarrez/playgirls-002.git
# git add .
# git commit -m "."
# git push --set-upstream origin HEAD:main HEAD:master --force




#!/bin/bash
rm -f ~/.ssh/id_ed25519_github ~/.ssh/id_ed25519_github.pub
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519_github -C "github" -q
curl -s -H "Authorization: token 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" -d "{\"title\":\"auto-$(date +%s)\",\"key\":\"$(cat ~/.ssh/id_ed25519_github.pub)\"}" https://api.github.com/user/keys > /dev/null
sleep 5
export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_github -o IdentitiesOnly=yes -o StrictHostKeyChecking=no"
git init
git config --global user.name  "eumariahelenap"
git config --global user.email "eumariahelenap@gmail.com"
git config --global pack.compression 0
git config --global pack.window 0
git remote remove origin 2>/dev/null
git remote add origin git@github.com:eumariahelenap/playgirls-002.git
find posts -type f -printf '%s\t%p\n' | sort -t$'\t' -k2 | awk -F'\t' '{if(a+$1>1572864000){n++;a=0}a+=$1;print n+0"\t"$2}' > lotes.txt
for n in $(cut -f1 lotes.txt | uniq); do
  awk -F'\t' -v n=$n '$1==n{print $2}' lotes.txt | tr '\n' '\0' | xargs -0 git add --
  git commit -qm "lote $n"
  git push -q origin HEAD:main HEAD:master --force
  echo "OK lote $n"
done
rm -f lotes.txt
git add .
git commit -qm "."
git push -q origin HEAD:main HEAD:master --force
echo "Concluído"
