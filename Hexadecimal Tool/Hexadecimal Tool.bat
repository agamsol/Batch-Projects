@echo off
setlocal enabledelayedexpansion

rem Arguments:
rem   --plain-to-hex    Convert Plain String to Hex String
rem   --hex-to-plain    Convert hex string to plain string

if /i "%~1"=="--plain-to-hex" (
    set "PlainString=%~2"
    call:PlainToHex
    exit /b
)
if /i "%~1"=="--hex-to-plain" (
    set "HexString=%~2"
    call:HexToPlain
    exit /b
)
exit /b

:PlainToHex
echo !PlainString!>PlainText.hex
certutil -encodehex PlainText.hex output.hex >nul
set "HexString="
for /f "delims=" %%A in (output.hex) do (
    set "line=%%A"
    set "line=!line:~5,48!"
    set "HexString=!HexString!!line!"
)
del PlainText.hex output.hex
set "HexString=!HexString: =!"
echo !HexString!
goto:eof

:HexToPlain
echo !HexString!>HexString.hex
certutil -decodehex HexString.hex output.hex >nul
set /p PlainString=<output.hex
del HexString.hex output.hex
echo !PlainString!
goto:eof
