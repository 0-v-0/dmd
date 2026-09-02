@echo off
call D:\dev\BuildTools\devcmd.bat
set LIB=%LIB%;D:\dev\dmd2\windows\lib64
set UniversalCRTSdkDir=D:\dev\BuildTools\Windows Kits\10
set UCRTVersion=10.0.26100.0
cd /d D:\gh\dmd
D:\gh\dmd\generated\windows\release\64\dmd.exe -conf= -m64 -ID:\dev\dmd2\src\druntime\import -c compiler\test\runnable\test18588.d -de 2>&1