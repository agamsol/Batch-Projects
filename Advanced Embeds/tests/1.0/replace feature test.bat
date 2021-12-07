@echo off
setlocal enabledelayedexpansion

set "webhook=https://discord.com/api/webhooks/862063271578566732/84cgOVpNwNnvto7cYpfjdACzLmRim0LkPCgprmnp9hS8W82hSFLyumNfbHduAxqSMLa_"


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