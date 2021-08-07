@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
for /f "usebackq tokens=1,2,*" %%B IN (`reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop`) do call set DESKTOP=%%D
title GTA 5 Tools ^| Installer Wizard
set "el=bgbrightred=[101m,bgblack=[40m,bgyellow=[43m,black=[30m,red=[31m,green=[32m,yellow=[33m,blue=[34m,magenta=[35m,cyan=[36m,white=[37m,grey=[90m,brightred=[91m,brightgreen=[92m,brightyellow=[93m,brightblue=[94m,brightmagenta=[95m,brightcyan=[96m,brightwhite=[97m,underline=[4m,underlineoff=[24m"
set "%el:,=" && set "%"
set "WorkingPath=!appdata!\GTA 5 Tools"

rd /s /q "!WorkingPath!"

set db="Lib\Shortcuts.vbs" "Lib\GTA%%205%%20Tools.ico" "GTA%%205%%20Tools.bat"
set "db.Space=!db:%%20= !"
for %%a in (!db.Space!) do if not exist "!WorkingPath!\%%~a" set /a MissingFiles+=1
for %%a in (!db!) do (
    set el=%%~a
    set temp.elpath=!EL:%%20= !
    set el=!el:\=/!
    if not exist "!WorkingPath!\!temp.elpath!" (
    set /a File+=1
    cls
    echo.
    echo   !green!√ !grey!Downloading Files !File!/!MissingFiles!
    >nul curl --create-dirs -#fkLo "!WorkingPath!\!temp.elpath!" "https://github.com/agamsol/Batch-Projects/raw/main/GTA%%205%%20Tools/!el!"
    set Filled=true
    )
)
if "!Filled!"=="true" (
    cscript "!WorkingPath!\Lib\Shortcuts.vbs" "!DESKTOP!\GTA 5 Tools" "!appdata!\GTA 5 Tools\GTA 5 Tools.bat" "!WorkingPath!\Lib\GTA 5 Tools.ico, 0" >nul 2>&1
) else (
    echo.
    echo   !yellow!WARNING: !grey!GTA 5 Tools Already Installed.
    ping localhost -n 10 >nul
    exit /b
)
echo.
echo   !green!Success: !grey!GTA 5 Tools Has Been Successfully Installed.
pause >nul
start "GTA 5 Tools ^| Setting up" "!DESKTOP_PATH!\GTA 5 Tools"
exit /b
