@echo off
setlocal enabledelayedexpansion
title Audio RC ^| Installing

pushd %~dp0
set "curl=curl.exe"
set "schtask_name=Audio-RC"
set "MainProgramPath=%appdata%\Audio RC"
set "GithubRepo=https://raw.githubusercontent.com/agamsol/Batch-Projects/main/Audio%%20RC"
set "MainFolder="index.bat" "background.vbs""
set "FileRequirements="Audio.vbs" "TTS.vbs" "rentry.exe" "youtube-dl.exe" "curl.exe" "ffmpeg\ffmpeg.exe" "ffmpeg\ffprobe.exe" "ffmpeg\ffplay.exe""

if /i "%~1"=="--credentials" goto :ShowCredentials

call :AdminPermissions
if !errorlevel! equ 60 exit /b

:: <Get OS Running>
for /f "tokens=4-5 delims=. " %%i in ('ver') do if "%%i.%%j"=="6.1" (set "CurrentOS=7") else (set "CurrentOS=10")
:: </Get OS Running>

if not exist !MainProgramPath! (
    echo.
    echo  INFO: Preparing Installation of 'Audio RC' version 2.1
    md "!MainProgramPath!"
)

set DownloadVCPP=false
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Installer\Products\1D5E3C0FEDA1E123187686FED06E995A" >nul 2>&1 && (
    echo.
    echo  WARNING: 'Microsoft Visual C++ 2010' is already installed.
) || (
    echo.
    echo  INFO: installing program 'Microsoft Visual C++ 2010' . . .
    set DownloadVCPP=true
    "!curl!" --create-dirs -#fkLo "!temp!\vcredist_x86.exe" "https://github.com/agamsol/Batch-Projects/blob/main/Audio%%20RC/installer/vcredist_x86.exe?raw=true"
    call "!temp!\vcredist_x86.exe" /q
)

:: <Download Files>
echo.
echo  INFO: Downloading missing files . . .
for %%a in (!FileRequirements!) do set /a Files.Length+=1
for %%a in (!FileRequirements!) do (
    set File=%%~a
    echo.
    if not exist "!MainProgramPath!\bin\%%~a" (
        echo  INFO: Downloading File: '%%~a'
        set "FileURL=!File:\=/!"
        "!curl!" --create-dirs -#fkLo "!MainProgramPath!\bin\!File!" "!GithubRepo!/bin/!FileURL!"
    ) else (
        echo  WARNING: File Already exists. '%%~a'
        timeout /t 0 /nobreak >nul
    )

)
for %%a in (!MainFolder!) do (
    if "%%~a"=="index.bat" (set "File=AudioVB.bat") else set File=%%~a
    echo.
    if not exist "!MainProgramPath!\!File!" (
        echo  INFO: Downloading File: '%%~a'
        "!curl!" --create-dirs -#fkLo "!MainProgramPath!\!File!" "!GithubRepo!/%%~a"
    ) else (
        echo  WARNING: File Already exists. '%%~a'
        timeout /t 0 /nobreak >nul
    )
)
:: </Download Files>

echo.
echo  INFO Adding 'Audio RC' to Startup.
>nul 2>&1 schtasks /query /TN "!schtask_name!"
if !errorlevel! equ 0 (
    echo.
    echo  WARN: The scheduled task '!schtask_name!' Already exists . . .
    echo.
    set /p "AlreadyExistTask=Replace task? (yes/no) : "
    echo.
    if /i "!AlreadyExistTask!"=="yes" (
        schtasks /delete /f /tn "!schtask_name!" >nul 2>&1
        echo  INFO: Successfully Deleted old task.
    ) else (
        echo  INFO: User requested to not replace existing task.
        timeout /t 5 /nobreak>nul
        exit /b
    )
)
echo.
schtasks /create /ru USERS /tn "!schtask_name!" /tr "cmd /c cd /d \"%%appdata%%\Audio RC\" & wscript.exe \"%%appdata%%\Audio RC\background.vbs\"" /SC ONLOGON >nul 2>&1
echo  INFO: Successfully created scheduled task.
schtasks /query /XML /TN "!schtask_name!" >"%temp%\!schtask_name!.xml"
echo.
echo  INFO: Exported XML file of a task
echo    Saved: '%temp%\!schtask_name!.xml'

chcp 437>nul
if !CurrentOS! equ 7 (
    powershell -Command "^(gc "%temp%\!schtask_name!.xml"^) -replace '<Hidden>false</Hidden>', '<Hidden>true</Hidden>' | Out-File "%temp%\!schtask_name!_new.xml""
) else (
    powershell -Command "^(gc "%temp%\!schtask_name!.xml"^) -replace '<Settings>', '<Settings> <Hidden>true</Hidden>' | Out-File "%temp%\!schtask_name!_new.xml""
)
chcp 65001>nul

echo.
echo  INFO: Changed scheduled task config to Hidden.
schtasks /delete /tn "!schtask_name!" /f >nul 2>&1
echo.
echo  INFO: Successfully deleted old scheduled task.
schtasks /create /XML "%temp%\!schtask_name!_new.xml" /TN "!schtask_name!" >nul 2>&1
echo.
echo  INFO: Successfully Uploaded XML file as a scheduled task.
del "%temp%\!schtask_name!.xml" "%temp%\!schtask_name!_new.xml"
echo.
echo  INFO: Deleted All XML Files

title Audio RC ^| Installation complete.
echo.
echo  INFO: Finished Installing 'Audio RC'.
timeout /t 3 /nobreak>nul
title Audio RC ^| Getting Remote Control Credentials.
schtasks /run /TN "Audio-RC" >nul 2>&1
echo.
echo  INFO: Successfully started 'Audio-RC' in background.
echo         Please wait while we collect your remote credentials.
:CheckConfigCreated
if not exist "!MainProgramPath!\config.inf" (
    timeout /t 2 /nobreak>nul
    goto :CheckConfigCreated
) else goto :ShowCredentials

:: <Plugins>
:AdminPermissions
echo.
echo  INFO: Checking Permissions . . .
net session >nul 2>&1
if !ErrorLevel! neq 0 (
    title Audio RC ^| ERROR
    echo.
    echo  ERROR: Administrator Permissions are required, Please run as Administrator.
    timeout /t 10 /nobreak >nul
    exit /b 60
)
exit /b 61

:ShowCredentials
if not exist "!MainProgramPath!\config.inf" (
    title Audio RC ^| ERROR
    echo.
    echo  ERROR: config file not found.
)
cd /d "!MainProgramPath!"
for /f "delims=" %%a in (config.inf) do (
<nul set /p="%%a" | >nul findstr /rc:"^[\[#].*" || set "%%a"
)
title Audio RC ^| Remote-Control-Credentials
echo.
echo  INFO: Here are your Audio Remote Control credentials:
echo     Webpage   : !Webpage:/raw=!
echo     Edit Code : !DefaultCode!
echo.
echo  * You may save these credentials somewhere.
echo.
echo  Press any key to exit . . .
pause>nul
exit /b
:: </Plugins>