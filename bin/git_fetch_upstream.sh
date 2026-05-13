#https://stackoverflow.com/questions/7244321/how-do-i-update-or-sync-a-forked-repository-on-github
#git remote add upstream https://github.com/whoever/whatever.git
git fetch upstream
git checkout main
git rebase upstream/main

