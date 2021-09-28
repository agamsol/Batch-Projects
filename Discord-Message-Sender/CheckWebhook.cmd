@echo off
setlocal EnableDelayedExpansion
set "blank=[0m" & set "bgwhite=[107m" & set "bgblack=[40m" & set "bgyellow=[43m" & set "black=[30m" & set "red=[31m" & set "green=[32m" & set "yellow=[33m" & set "blue=[34m" & set "magenta=[35m" & set "cyan=[36m" & set "white=[37m" & set "grey=[90m" & set "brightred=[91m" & set "brightgreen=[92m" & set "brightyellow=[93m" & set "brightblue=[94m" & set "brightmagenta=[95m" & set "brightcyan=[96m" & set "brightwhite=[97m" & set "underline=[4m" & set "underlineoff=[24m"

echo proivide webhook
set /p "Webhook=--> "
if "%webhook:~0,33%"=="https://discord.com/api/webhooks/" goto:CORRECT_STRUCTURE
if "%webhook:~0,37%"=="https://ptb.discord.com/api/webhooks/" goto:CORRECT_STRUCTURE
if "%webhook:~0,40%"=="https://canary.discord.com/api/webhooks/" goto:CORRECT_STRUCTURE
echo !red!ERROR: !grey!The Provided Webhook URL is Incorrect.
pause
:CORRECT_STRUCTURE

FOR /F "tokens=* USEBACKQ" %%F IN (`curl --silent "%webhook%"`) DO ( SET "WebhookCheck=%%F" )

if not defined WebhookCheck echo Error 0 && pause
echo %WebhookCheck% | findstr /ic:"404: Not Found" >nul && ( 
    echo !red!ERORR: !grey!Could not find the Webhook URL
    exit /b
)
echo %WebhookCheck% | findstr /ic:"401: Unauthorized" >nul && ( 
    echo !red!ERROR: !grey!The Webhook URL Provided is Unauthorized.
    exit /b
)
echo %WebhookCheck% | findstr /ic:"Invalid Webhook Token" >nul && ( 
    echo !red!ERROR: !grey!Invalid Webhook Token
    exit /b
)
echo !green!Success, !grey!The Webhook Is correct.!blank!
pause
exit /b