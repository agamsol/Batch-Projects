@echo off
setlocal enabledelayedexpansion
for %%a in ("yellow=[33m" "white=[37m" "grey=[90m" "brightred=[91m" "brightgreen=[92m" "brightblue=[94m") do set %%a

:: <Settings>
if not exist "config.ini" (
    echo.
    echo   !grey!First Time Launch Detected, Lets Create The Config file "!brightblue!config.ini!grey!"
    echo.
    set /p "HOSTS_LIST=  !grey!Please Provide !brightblue!Local IPv4 Address: !grey!"
    echo.
    set /p "Webhook=  !grey!Please Provide !brightblue!Discord Webhook URL: !grey!"
    echo.
    set /p "Delay=  !grey!How Much time would you like to auto check status? (Number In Minutes) !grey!"
    for %%a in ("[HOSTS]" "HOSTS_LIST=!HOSTS_LIST!" "Delay=1" "" "[Discord]" "Webhook=!Webhook!" "EmbedImage=https://i.imgur.com/KsdyzHW.png" "DiscordMsgProKey=6JdL4S-Lw8tQC-jGvmZv-6JdL4S" "" "[Embed Colors]" "StartupColor=#5789ff" "OfflineColor=#f35361" "OnlineColor=#53f396") do echo.%%~a>>config.ini
    timeout /t 5 /nobreak >nul
)
for /F "tokens=* delims=" %%l in (config.ini) do echo:%%l | findstr /r /c:"^[\[#].*" >nul || set "%%l"
:: </Settings>

:: <Prepare Script>
if not defined HOSTS_LIST (
    echo.
    echo   !grey![%date% %time:~1,7%] [!brightred!EVENT!grey!]: No Hosts Provided to listen for.
    timeout /t 5 >nul
    exit /b
)

if not defined Webhook (
    echo.
    echo   !grey![%date% %time:~1,7%] [!yellow!EVENT!grey!]: Webhook not defined, turning into window-only mode!white!
)

if not exist "DiscordMsgPRO.exe" (
    echo.
    echo   !grey![%date% %time:~1,7%] [!yellow!EVENT!grey!]: Downloading DiscordMsgPRO . . .
    curl --progress-bar "https://raw.githubusercontent.com/agamsol/Quick-Message-Sender/main/Premium/DiscordMsgPRO.exe" -o "DiscordMsgPRO.exe"
)
call "DiscordMsgPRO.exe" +silent --key "$Key!DiscordMsgProKey!"
set /a Delay*=60
for %%a in (!HOSTS_LIST!) do (
    set /a HOST.count+=1
    set HostID[%%a]=!HOST.count!
    call :GET_HOST_STATUS "%%a"
    if !GetHost_STATUS! equ 1 (
        set "Computername[%%a]=_null_"
    ) else (
        for /f "tokens=1 delims=[" %%b in ('ping -a %%a -n 1') do if not defined Computername[%%a] set "Computername[%%a]=%%b" & set "Computername[%%a]=!Computername[%%a]:Pinging =!" & set "Computername[%%a]=!Computername[%%a]:~,-1!"
    )
)
if !HOST.count! gtr 1 ( set "HOST.count=!HOST.count! Hosts") else ( set "HOST.count=!HOST.count! Host")
:: </Prepare Script>

:: <Start Script>
cls
title Listening To !HOST.count!.
echo.
echo   !grey![%date% %time:~1,7%] [!brightgreen!EVENT!grey!]: Listening To !HOST.count!.

for %%a in (!HOSTS_LIST!) do (
    call :GET_HOST_STATUS "%%a"
    if !GetHost_STATUS! equ 1 (
        set "STARTUP.Message=!STARTUP.Message!\\n\\n:id: HOST !HostID[%%a]!\\n**Local IP:** %%a\\n**Host name:** !computername[%%a]!\\n**Status:** Offline :red_circle:"
    ) else (
        set "STARTUP.Message=!STARTUP.Message!\\n\\n:id: HOST !HostID[%%a]!\\n**Local IP:** %%a\\n**Host name:** !computername[%%a]!\\n**Status:** Online :green_circle:"
    )
)
call "DiscordMsgPRO.exe" +silent --embed "Status of !HOST.count!" "!STARTUP.Message!" "!StartupColor!" "!EmbedImage!"
for %%a in (!HOSTS_LIST!) do (
    call :GET_HOST_STATUS "%%a"
    if !GetHost_STATUS! equ 1 (
            set "HostStatus.prev[%%a]=0"
            set "Status[%%a]=0"
        ) else (
            set "HostStatus.prev[%%a]=1"
            set "Status[%%a]=0"
        )
)
:: </Start Script>

:: <Loop Part that checks for Status Changes>
:UPDATE_STATUS
for %%a in (!HOSTS_LIST!) do (
	call :GET_HOST_STATUS "%%a"
    if !GetHost_STATUS! equ 1 (
        if !HostStatus.prev[%%a]! equ 1 (
            rem Last Time was online = Offline message
            echo.
            echo   !grey![%date% %time:~1,7%] [!brightred!EVENT!grey!]: The Host !brightblue!%%a !grey!Was found to be offline.
            set "DiscordMsg[%%a]=:id: HOST !HostID[%%a]!\\n**Local IP:** %%a\\n**Host name:** !computername[%%a]!\\n**Status:** Offline :red_circle:"
            set Status[%%a]=1
            set HostStatus.prev[%%a]=0
        )
    ) else (
        if !HostStatus.prev[%%a]! equ 0 (
            rem Last Time was offline = online message
            if "!Computername[%%a]!"=="_null_" (
                set Computername[%%a]=
                for /f "tokens=1 delims=[" %%b in ('ping -a %%a -n 1') do if not defined Computername[%%a] set "Computername[%%a]=%%b" & set "Computername[%%a]=!Computername[%%a]:Pinging =!" & set "Computername[%%a]=!Computername[%%a]:~,-1!"
            )
            echo.
            echo   !grey![%date% %time:~1,7%] [!brightgreen!EVENT!grey!]: The Host !brightblue!%%a !grey!Was found to be online.
            set "DiscordMsg[%%a]=:id: HOST !HostID[%%a]!\\n**Local IP:** %%a\\n**Host name:** !computername[%%a]!\\n**Status:** Online :green_circle:"
            set Status[%%a]=1
            set HostStatus.prev[%%a]=1
        )
    )
)

:: <Send Queued Messages>
for %%a in (!HOSTS_LIST!) do (
    if !Status[%%a]! equ 1 (
        if !HostStatus.prev[%%a]! equ 0 (
            set "EmbedDetail=":small_orange_diamond: Host Status Changed" "!DiscordMsg[%%a]!" "!OfflineColor!""
        ) else (
            set "EmbedDetail=":small_orange_diamond: Host Status Changed" "!DiscordMsg[%%a]!" "!OnlineColor!""
        )
        call "DiscordMsgPRO.exe" +silent --embed !EmbedDetail! "!EmbedImage!"
        set Status[%%a]=0
    )
)
:: </Send Queued Messages>
timeout /t !Delay! /nobreak >nul
goto :UPDATE_STATUS
:: </Loop Part that checks for Status Changes>


:: <Get Status Per 1 Host (Call Function)>
:GET_HOST_STATUS
set "GetStatus=%~1"
ping !GetStatus! -n 1 | findstr "TTL" >nul
if !ErrorLevel! equ 1 (
    set GetHost_STATUS=1
) else (
    set GetHost_STATUS=0
)
goto:eof
:: </Get Status Per 1 Host (Call Function)>
