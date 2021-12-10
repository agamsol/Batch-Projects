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

echo.%* | findstr /ic:"--batch">nul && set BatchMode=true

for /L %%a in (1 1 !Args.length!) do (
    for %%b in ("help" "current-timestamp" "webhook" "attach-files" "url" "replace" "edit-message" "delete-message" "batch") do (
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
                    for /f "skip=2 tokens=2 delims==" %%A in ('wmic os get LocalDateTime /value') do for %%B in (%%A) do set "LocalDateTime=%%B"
                    set /a "minutes=1!LocalDateTime:~22,3!-1000, hours=minutes/60+100, minutes=minutes%%60+100"
                    set "TIMESTAMP=!LocalDateTime:~0,4!-!LocalDateTime:~4,2!-!LocalDateTime:~6,2!T!LocalDateTime:~8,2!:!LocalDateTime:~10,2!:!LocalDateTime:~12,2!.!LocalDateTime:~15,7!!hours:~1!:!minutes:~1!"
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
                            if "!BatchMode!"=="true" (
                                echo ERROR=Invalid Message ID
                            ) else echo ERROR: Invalid Message ID Provided.
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
                            if "!BatchMode!"=="true" (
                                echo ERROR=Couldn't Find Embed Configuration
                            ) else echo ERROR: Embed Configuration couldn't be found.
                            exit /b
                        ) 
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
                            if "!BatchMode!"=="true" (
                                echo ERROR=Invalid Message ID.
                            ) else echo WARN: Invalid Message ID Provided.
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

for %%a in (null false) do (
    if "!ValidWebhook!"=="%%a" (
        if "!BatchMode!"=="true" (
            echo ERROR=Invalid Webhook
        ) else echo ERROR: Webhook not provided
        exit /b
    )
)

if "!DeleteMessageMode!"=="true" (
    curl -sL "!WSWebhook!\messages\!MessageID!" | findstr /c:"{\"message\": \"Unknown Message\"">nul && (
        if "!BatchMode!"=="true" (
            echo ERROR=Invalid Message ID
        ) else echo ERROR: Couldn't find message with such ID.
        exit /b
    )
    curl -X DELETE "!WSWebhook!\messages\!MessageID!">nul
    if "!BatchMode!"=="true" (
        echo MessageDeleted=Successfully Deleted Message "!MessageID!".
    ) else echo The message with the ID '!MessageID!' has been successfully deleted.
    exit /b
)

if "!EditMessageMode!"=="true" (
    REM CHECK IF MESSAGE EXISTS
    echo %* | findstr /ic:"--force">nul && set ForceSend=true
    curl -sL "!WSWebhook!\messages\!MessageID!" | findstr /c:"{\"message\": \"Unknown Message\"">nul && (
        if "!BatchMode!"=="true" (
            echo ERROR=Couldn't Find Message Specified
        ) else echo ERROR: Couldn't find message with such ID.
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
            if "!BatchMode!"=="true" (
                echo WARN=Raw-Link detected
            ) else echo WARN: The URL provided seemed to not be a RAW page, disable raw checking using '--raw-check false'.
            if exist "!Configuration!" del /s /q "!Configuration!">nul
            exit /b
        )
    )
    set EmbedConfigurationJson=-F "payload_json=<!Configuration!"
    
    call :NumberValidator "!ReplaceAmount!"
    if defined NotNumber (
        if "!BatchMode!"=="true" (
            echo ERROR=Invalid METADATA for "Replace" Feature.
        ) else echo ERROR: Failed to validate 'replace' flag's META-DATA.
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
            if "!BatchMode!"=="true" (
                echo ERROR=Error occured while sending the message.
            ) else echo ERROR: An error occured while sending the message.
            exit /b
        )
        echo Message Successfully Sent: !CurlOutput:~8,18!
        echo.%%a | findstr /c:"\"tts\": false">nul && (
            set TTS=false
        ) || (
            set TTS=true
        )
        if "!BatchMode!"=="true" (
            echo TTS=!TTS!
        ) else echo Text to Speech: !TTS!
    )
) else (
    if "!BatchMode!"=="true" (
        echo WARN=Nothing To Send
    ) else echo WARN: Nothing to send.
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
    if "!BatchMode!"=="true" (
    echo ERROR=Invalid METADATA for "attach-files" Feature.
    ) else echo ERROR: Failed to validate 'attach-files' flag's META-DATA.
    exit /b
)
if !FilesAmount! neq 0 (
    for /L %%a in (1 1 !FilesAmount!) do (
        if defined !FilesVariableName![%%a] (
            for /f "delims=" %%b in ("!FilesVariableName!") do (
                if not exist "!%%b[%%a]!" (
                    if "!BatchMode!"=="true" (
                        echo ERROR=File To Attach Not Found "!%%b[%%a]!".
                    ) else echo ERROR: File to attach was not found '!%%b[%%a]!'
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
