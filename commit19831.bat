@echo off
cd /d D:\gh\dmd\wt1
git add -A
git commit -m "Fix issue 19831: indexing tuple with alias this in array dim"
git log --oneline -1
