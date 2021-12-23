@echo off
setlocal enabledelayedexpansion

for %%a in ("ParseSource" "ParseType" "JsonKeys" "Arg[2]" "ParseKeys") do set %%~a=

set Arg[2]=%~2
if not defined Arg[2] (echo ERROR: Nothing to parse. && exit /b)

set "ParseSource=%~1"
if "!ParseSource:://=!"=="!ParseSource!" (
    set ParseType=FILE
) else (
    set ParseType=URI
)

set "JsonKeys=%*"
set "JsonKeys=!JsonKeys:*%~1=!"
set "JsonKeys=!JsonKeys:~1!"

if "!ParseType!"=="URI" (
    curl -f "!ParseSource!">nul 2>&1 || echo ERROR: URL not found. && exit /b
    for %%a in (!JsonKeys!) do (
        set "ParseKeys=!ParseKeys!; $RespPart = '%%~a=' + $Response.%%~a ; $RespPart | Format-List"
    )
    powershell "$Response = Invoke-RestMethod '!ParseSource!' !ParseKeys!"
)
if "!ParseType!"=="FILE" (
    if exist "!ParseSource!" (
        for %%a in (!JsonKeys!) do (
            set "ParseKeys=!ParseKeys!; $ValuePart = '%%~a=' + $Value.%%~a ; $ValuePart"
        )
        powershell "$Value = (Get-Content '!ParseSource!' | Out-String | ConvertFrom-Json) !ParseKeys!"
    ) else echo ERROR: File not found.
)