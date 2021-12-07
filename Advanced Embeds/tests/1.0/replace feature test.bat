@echo off
setlocal enabledelayedexpansion

set "webhook="


: <Replace Strings Array>
for %%a in (
    "$VPNStatus$:\\:green_circle: ON"
    "16GB:1666GB"
) do (
    set /a ReplaceStringLength+=1
    set "ReplaceStringArray[!ReplaceStringLength!]=%%~a"
)

call index.bat --URL "https://pastebin.com/raw/3yi3PQpg" --replace "!ReplaceStringLength!:ReplaceStringArray"

pause
exit /b
