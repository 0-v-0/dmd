@echo off
call D:\dev\BuildTools\devcmd.bat
set "LIB=%LIB%;D:\dev\dmd2\windows\lib64"
set "UniversalCRTSdkDir=D:\dev\BuildTools\Windows Kits\10"
set "UCRTVersion=10.0.26100.0"
cd /d D:\gh\dmd\wt1

echo === Build build.exe ===
D:\dev\dmd2\windows\bin64\dmd.exe -ofgenerated\build.exe -g compiler\src\build.d
if errorlevel 1 exit /b 1

echo === Build dmd.exe ===
generated\build.exe
if errorlevel 1 exit /b 1

echo === BUILD SUCCESS ===
