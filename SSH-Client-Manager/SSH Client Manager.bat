@echo off
setlocal enabledelayedexpansion
pushd "%~dp0"

:MAIN_MENU
set selection=
for /f "delims=" %%a in ('type "config.ini"') do set "%%a"
title Main Selection Menu
cls
echo:
echo   1. Add new server
echo:
echo   2. Remove Existing Server
echo:
echo   3. View All Servers
echo:
set /p "selection=--> "

if !selection! equ 1 (
    set selection_int=
    title Add A New Server
    cls
    echo:
    echo   Please Provide Server Name
    echo           Example: %username%@192.168.1.1
    echo:
    echo  TYPE "BACK" FOR HOME PAGE.
    echo:
    set /p "selection_int=--> "
    if /i "!selection_int!"=="back" goto :MAIN_MENU
    if defined selection_int (
        set "Servers_List=!Servers_List! "!selection_int!""
        call :CREATE_CONFIG
        echo:
        echo  The server '!selection_int!' has been successfully added.
        timeout /t 4 /nobreak>nul
    )
)

if !selection! equ 2 (
    :DELETE_SERVER
    title Delete A Server - List
    cls
    echo:
    echo   Please select a server from the list below in order to delete it
    call :LIST_SERVERS
    if not defined option[!selection_int!] (
        echo:
        echo ERROR: Invalid option selected.
        echo:
        timeout /t 4 /nobreak>nul
        goto :DELETE_SERVER
    )
    title Removing A Server
    for /f "delims=" %%a in ("!selection_int!") do (
        for /f "delims=" %%b in ("!option[%%a]!") do (
            echo: !Servers_List! | findstr /c:"%%b">nul && (
                set Servers_List=!Servers_List:"%%b"=!
                call :CREATE_CONFIG
                echo:
                echo SUCCESS: The server "%%b" has been successfully deleted.
                timeout /t 5 /nobreak >nul
            )
        )
    )
)

if !selection! equ 3 (
    :USE_SERVERS
    set selection_int_2=
    title Connect To A Server - List
    cls
    echo:
    echo   Please select a server from the list below in order to connect to it
    call :LIST_SERVERS
    if not defined option[!selection_int!] (
        echo:
        echo ERROR: Invalid option selected.
        echo:
        timeout /t 4 /nobreak>nul
        goto :USE_SERVERS
    )
    :ESTABLISH_CONNECTION
    cls
    for /f "delims=" %%a in ("!selection_int!") do (
        for /f "delims=" %%b in ("!option[%%a]!") do (
            for /f "tokens=1,2 delims=@" %%c in ("%%~b") do (
                title Connecting To - %%d
                echo:
                echo     [+] Trying to connect to '%%d' with the username of '%%c'
                echo:
                if exist "%userprofile%\.ssh\known_hosts" (
                    echo     [-] Cleaning files from previous connections . . .
                    echo:
                    del /s /q "%userprofile%\.ssh\known_hosts" >nul 2>&1
                )
                call ssh "%%c@%%d" -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o LogLevel=ERROR
                cmd /c exit /b
                (
                    echo:
                    echo  SSH Connection has stopped, What would you like to do?
                    echo       1. Reconnect
                    echo       2. Retrun to previous page
                    echo       3. Retrun to MAIN PAGE
                    echo:
                )
                set /p "selection_int_2=--> "
                if !selection_int_2! equ 1 goto :ESTABLISH_CONNECTION
                if !selection_int_2! equ 2 goto :USE_SERVERS
                if !selection_int_2! equ 3 goto :MAIN_MENU
            )
        )
    )


)
goto :MAIN_MENU

:: <CREATE CONFIG>
:CREATE_CONFIG
>"config.ini" (
    echo ; Config file for SSH Client Manager
    echo Servers_List=!Servers_List!
)
exit /b
:: </CREATE CONFIG>

:: <LIST ALL SERVERS>
:LIST_SERVERS
set selection_int=
set ServersCount=0
for /f "tokens=1 delims==" %%a in ('set option[ 2^>nul') do set %%a=
for /f "delims=" %%a in ('type "config.ini"') do set "%%a"
if defined Servers_List (
    for %%a in (!Servers_List!) do (
        set /a ServersCount+=1
        set option[!ServersCount!]=%%~a
    )
)
if !ServersCount! equ 0 (
    echo:
    echo ERROR: No servers that were added.
    echo   You can add them in the main menu in option 1.
    echo:
    timeout /t 4 /nobreak>nul
    goto :MAIN_MENU
)
echo:
for /L %%a in (1 1 !ServersCount!) do (
    echo  %%a --^> !option[%%a]!
)
echo:
echo  TYPE "BACK" FOR HOME PAGE.
echo:
set /p "selection_int=--> "
if /i "!selection_int!"=="back" goto :MAIN_MENU
exit /b
:: </LIST ALL SERVERS>
