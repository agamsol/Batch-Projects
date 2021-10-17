@echo off
setlocal enabledelayedexpansion

set "schtask_name=Audio-RC"
set "MainProgramPath=%appdata%\Audio RC"

call :AdminPermissions
if !errorlevel! equ 60 exit /b

taskkill /f /im "timeout.exe" >nul 2>&1
echo.
echo  INFO: Force-Stopped a task 'timeout.exe' (if it ran)
echo.
rd /s /q "!MainProgramPath!" >nul 2>&1
echo  INFO: Removed 'Audio-RC' Directory.
schtasks /delete /f /tn "!schtask_name!" >nul 2>&1
echo.
echo  INFO: Removed 'Audio-RC' from startup
echo.
echo  INFO: Exiting in 10 seconds.
timeout /t 10 /nobreak>nul
exit /b
:: <Plugins>

:AdminPermissions
echo.
echo  Checking Permissions . . .
net session >nul 2>&1
if !ErrorLevel! neq 0 (
    echo.
    echo  ERROR: Administrator Permissions are required, Please run as Administrator.
    title Audio RC ^| ERROR
    timeout /t 10 /nobreak >nul
    exit /b 60
)
exit /b 61
:: </Plugins>
