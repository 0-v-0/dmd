@echo off
cd /d D:\gh\dmd\wt1
git add -A
git commit -m "Add regression test for issue 18924: union overlap"
git log --oneline -1