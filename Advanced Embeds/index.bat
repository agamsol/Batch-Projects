@echo off
setlocal enabledelayedexpansion

: <Defaults>
set "Source=https://github.com/agamsol/Batch-Projects/raw/main/Advanced%%20Embeds"
set AttachFiles=0
set ReplaceAmount=0
set FilesAmount=0
: </Defaults>

for %%a in (%*) do (
    set /a Args.length+=1
    set Arg[!Args.length!]=%%~a
)

for /L %%a in (1 1 !Args.length!) do (
    for %%b in ("help" "current-timestamp" "webhook" "attach-files" "url" "replace" "edit-message" "delete-message") do (
        if /i "!Arg[%%a]!"=="--%%~b" (
            set queueArg=%%a
            set /a queueArg+=1
            for /f "delims=" %%c in ("!queueArg!") do (
                if /i "%%~b"=="HELP" (
                curl --ssl-no-revoke -L "!Source!/HELP.txt?raw=true"
                set /p "MoreInformation=---> "
                if /i "!MoreInformation!"=="Y" start "" "!Source!\README.md"
                exit /b
                )
                if /i "%%~b"=="CURRENT-TIMESTAMP" (
                    for /f %%A in ('wmic os get localdatetime /value ^| find /i "LocalDateTime"') do set "%%A"
                    set "TIMESTAMP=!LocalDateTime:~0,4!-!LocalDateTime:~4,2!-!LocalDateTime:~6,2!T!LocalDateTime:~8,2!:!LocalDateTime:~10,2!:!LocalDateTime:~12,2!.!LocalDateTime:~15,3!Z"
                    if not defined Arg[%%c] (echo TIMESTAMP=!TIMESTAMP!) else echo !Arg[%%c]!=!TIMESTAMP!
                    exit /b
                )
                if /i "%%~b"=="WEBHOOK" (
                    if defined Arg[%%c] (
                        set WebhookProvided=true
                        call :WebhookCheck "!Arg[%%c]!"
                    )
                )
                if /i "%%~b"=="DELETE-MESSAGE" (
                    if defined Arg[%%c] (
                        call :NumberValidator "!Arg[%%c]!"
                        if defined NotNumber (
                            echo ERROR: Invalid Message ID Provided.
                            exit /b
                        )
                        set DeleteMessageMode=true
                        set "MessageID=!Arg[%%c]!"
                    )
                )
                if /i "%%~b"=="ATTACH-FILES" (
                    REM --attach-files "<Amount>:<Variable Name>"
                    if defined Arg[%%c] (
                        for /f "tokens=1-2 delims=:" %%d in ("!Arg[%%c]!") do (
                            set "FilesAmount=%%~d"
                            set "FilesVariableName=%%~e"
                            call :AttachFiles
                        )
                    )
                )
                if /i "%%~b"=="URL" (
                    if /i "!Arg[%%c]:~0,4!"=="http" (
                        set "Configuration=!TEMP!\EmbedConfiguration.json"
                        set URLValue=!Arg[%%c]!
                        curl --raw -Lf "!Arg[%%c]!" >nul 2>&0 && (
                            set AttachEmbedConfiguration=true
                        ) || (
                            echo ERROR: Embed Configuration couldn't be found.
                            exit /b
                        ) 
                    ) else (
                        echo ERROR: Embed Configuration URL has not been provided, Checking for files to attach.
                    )
                )
                if /i "%%~b"=="REPLACE" (
                    REM --replace "<Amount>:<Variable Name>"
                    if defined Arg[%%c] (
                        for /f "tokens=1-2 delims=:" %%d in ("!Arg[%%c]!") do (
                            set "ReplaceAmount=%%~d"
                            set "ReplaceVariableName=%%~e"
                        )
                    )
                )
                if /i "%%~b"=="EDIT-MESSAGE" (
                    if defined Arg[%%c] (
                        call :NumberValidator "!Arg[%%c]!"
                        if defined NotNumber (
                            echo WARN: Invalid Message ID Provided.
                            exit /b
                        )
                        set EditMessageMode=true
                        set "MessageID=!Arg[%%c]!"
                    )
                )
            )
        )
    )
)
if not defined ValidWebhook set ValidWebhook=null
if "!ValidWebhook!"=="null" if defined webhook call :WebhookCheck "!webhook!"
if "!ValidWebhook!"=="null" (
    echo ERROR: Webhook not provided
    exit /b
)
if "!ValidWebhook!"=="false" (
    echo ERROR: Invalid Webhook URL Provided.
    exit /b
)
if "!DeleteMessageMode!"=="true" (
    curl -sL "!WSWebhook!\messages\!MessageID!" | findstr /c:"{\"message\": \"Unknown Message\"">nul && (
        echo ERROR: Couldn't find message with such ID.
        exit /b
    )
    curl -X DELETE "!WSWebhook!\messages\!MessageID!">nul
    echo The message with the ID '!MessageID!' has been successfully deleted.
    exit /b
)

if "!EditMessageMode!"=="true" (
    REM CHECK IF MESSAGE EXISTS
    echo %* | findstr /ic:"--force">nul && set ForceSend=true
    curl -sL "!WSWebhook!\messages\!MessageID!" | findstr /c:"{\"message\": \"Unknown Message\"">nul && (
        echo ERROR: Couldn't find message with such ID.
        if not "!ForceSend!"=="true" exit /b
        goto :SendOverAllMessage
    )
    set "WSWebhook=!WSWebhook!\messages\!MessageID!?wait=true"
    set "EditMsg=--request PATCH"
)

:SendOverAllMessage
if "!AttachEmbedConfiguration!"=="true" (
    curl --ssl-no-revoke -sL "!URLValue!" -o "!Configuration!"
    echo.%*| findstr /ic:"--raw-check false">nul || (
        echo.!URLValue!| findstr /c:"raw">nul || (
            echo WARN: The URL provided seemed to not be a RAW page, disable raw checking using '--raw-check false'.
            if exist "!Configuration!" del /s /q "!Configuration!">nul
            exit /b
        )
    )
    set EmbedConfigurationJson=-F "payload_json=<!Configuration!"
    
    call :NumberValidator "!ReplaceAmount!"
    if defined NotNumber (
        echo ERROR: Failed to validate 'replace' flag's META-DATA.
        exit /b
    )
    if !ReplaceAmount! neq 0 (
        if not exist "!TEMP!\fart.exe" curl -sL "!Source!/fart.exe?raw=true" -o "!TEMP!\fart.exe"
        for /L %%a in (1 1 !ReplaceAmount!) do (
            if defined !ReplaceVariableName![%%a] (
                for /f "delims=" %%b in ("!ReplaceVariableName!") do (
                    set ReplaceString=!%%b[%%a]!
                    set ReplaceString=!ReplaceString:\\:=$EscapedColon$!
                    for /f "tokens=1,* delims=:" %%c in ("!ReplaceString!") do (
                        set "AddBackColons[0]=%%c"
                        set AddBackColons[0]=!AddBackColons[0]:$EscapedColon$=:!
                        set AddBackColons[1]=%%d
                        set AddBackColons[1]=!AddBackColons[1]:$EscapedColon$=:!
                        call "!TEMP!\fart.exe" "!Configuration!" "!AddBackColons[0]!" "!AddBackColons[1]!">nul 2>&1
                    )
                )
            )
        )
    )
)

if "!AttachEmbedConfiguration!"=="true" set ForceSending=true
if !AttachFiles! neq 0 set ForceSending=true
if "!ForceSending!"=="true" (
    for /f "delims=" %%a in ('curl !EditMsg! --silent -H "Content-Type: multipart/form-data" !EmbedConfigurationJson! !QueueFiles! "!WSWebhook!?wait=true"') do (
        set CurlOutput=%%a
        if exist "!Configuration!" del /s /q "!Configuration!">nul
        call :NumberValidator "!CurlOutput:~8,18!"
        if defined NotNumber (
            echo ERROR: An error occured while sending the message.
            exit /b
        )
        echo Message Successfully Sent: !CurlOutput:~8,18!
        echo.%%a | findstr /c:"\"tts\": false">nul && (
            echo Text to Speech: OFF
        ) || (
            echo Text to Speech: ON
        )
    )
) else (
    echo WARN: Nothing to send.
)
exit /b
: <Webhook Validation>
:WebhookCheck
set ValidWebhook=
for /f "tokens=4* delims=/" %%` in ("%~1") do (
    for /f "delims=" %%b in ('curl --ssl-no-revoke -sL "https://discord.com/api/webhooks/%%~a"') do (
        echo.%%b| findstr /c:"channel_id">nul && (
            if not defined ValidWebhook (
                set "WSWebhook=https://discord.com/api/webhooks/%%~a"
                set ValidWebhook=true
            )
        )
    )
)
if not "!ValidWebhook!"=="true" set ValidWebhook=false
exit /b
: </Webhook Validation>

: <Prepare Valid Files to attachment>
:AttachFiles
call :NumberValidator "!FilesAmount!"
if defined NotNumber (
    echo ERROR: Failed to validate 'attach-files' flag's META-DATA.
    exit /b
)
if !FilesAmount! neq 0 (
    for /L %%a in (1 1 !FilesAmount!) do (
        if defined !FilesVariableName![%%a] (
            for /f "delims=" %%b in ("!FilesVariableName!") do (
                if not exist "!%%b[%%a]!" (
                    echo ERROR: File to attach was not found '!%%b[%%a]!'
                ) else (
                    set /a AttachFiles+=1
                    set "QueueFiles=!QueueFiles! -F "File[!AttachFiles!]=@!%%b[%%a]!""
                )
            )
        )
    )
)
exit /b
: </Prepare Valid Files to attachment>

: <Number Validator>
:NumberValidator
set NotNumber=
for /f "delims=0123456789" %%i in (%1) do set "NotNumber=%%i"
exit /b
: </Number Validator>
