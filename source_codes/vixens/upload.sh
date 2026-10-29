
rm -f ~/.ssh/id_ed25519_gitlab ~/.ssh/id_ed25519_gitlab.pub
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519_gitlab -C "gitlab" -q
curl -s --header "PRIVATE-TOKEN: glpat-qFXtX8FXPsfUXYKiU-lWG2M6MQpvOjEKdTptOXhreQ8.01.171b2rfqp" --data-urlencode "title=auto-$(date +%s)" --data-urlencode "key=$(cat ~/.ssh/id_ed25519_gitlab.pub)" "https://gitlab.com/api/v4/user/keys" > /dev/null
sleep 5
export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519_gitlab -o StrictHostKeyChecking=no"
git init
git config --local user.name  "MA"
git config --local user.email "mikealvarrez.02@gmail.com"
git remote add     origin git@gitlab.com:mikealvarrez/vixens
git remote set-url origin git@gitlab.com:mikealvarrez/vixens
git add .
git commit -m "."
git push --set-upstream origin HEAD --force