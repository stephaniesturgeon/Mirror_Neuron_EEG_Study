use MAtlab version 2018
open git bash


commands
dir - shows you what folder you're in
cd - change folder


cd into SARGv2 folder:
cd Desktop
cd SARGv2
cd sarg-mirror

git status (will tell you if the repo is up to date) (changes are in red)
git commit -m (changes won't be saved to repo without a commit so write something after -m in "")
git push (if you made changes do this to send to repo)


if you changed something on another machine
git pull (pull down changes from repo, this will update everything on this machine)


to add something that didn't get pushed/tracked
git add FILE_NAME
git commit -m "comment"
git push