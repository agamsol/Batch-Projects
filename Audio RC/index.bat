@echo off
setlocal enabledelayedexpansion

REM index.bat version : 2.1

:: <Settings>
set "GithubRepo=https://raw.githubusercontent.com/agamsol/Batch-Projects/main/Audio%%20RC"
set "MainProgramPath=%appdata%\Audio RC"
set "SettingsFile=config.inf"
set "WebSettings=WebSettings.txt"
set "DefaultCreationCode=1234"
set "DefaultTTSVoice=David"
set "DefaultTTSVolume=70"
set "Files="Audio.vbs" "TTS.vbs" "youtube-dl.exe" "ffmpeg" "rentry.exe" "curl.exe""
set "FileRequirements="Audio.vbs" "TTS.vbs" "rentry.exe" "youtube-dl.exe" "curl.exe" "ffmpeg\ffmpeg.exe" "ffmpeg\ffprobe.exe" "ffmpeg\ffplay.exe""
:: </Settings>

REM Scan for enabled features each number of seconds
set "ScanTimeout=10"

:: <Prepare>
for %%a in (!Files!) do (
    set /a Files.Length+=1
    set "File[!Files.Length!]=bin\%%~a"
)
if not exist Youtube-Sounds md Youtube-Sounds
call :getPID ownPID
:: </Prepare>

:: <Get OS Running>
for /f "tokens=4-5 delims=. " %%i in ('ver') do if "%%i.%%j"=="6.1" (set "CurrentOS=7") else (set "CurrentOS=10")
if !CurrentOS! equ 10 (
    set "TTSLoaderNoVal="TTS" "TTS_SPEAK" "TTS_VOICE" "TTS_VOLUME""
    set "TTSLoader="TTS=false" "TTS_SPEAK=Something to say" "TTS_VOICE=David" "TTS_VOLUME=100""
)
:: </Get OS Running>

:: <Download Missing Files>
for %%a in (!FileRequirements!) do if not exist "bin\%%a" set /a MissingFiles+=1
if !MissingFiles! geq 1 (
    echo.
    echo  Preparing to download missing files . . .
)

for %%a in (!FileRequirements!) do (
    set File=%%~a
    if not exist "!MainProgramPath!\bin\%%~a" (
        echo.
        echo  INFO: Downloading File: '%%~a'
        set "FileURL=!File:\=/!"
        chcp 437 > nul
        "!File[6]!" --create-dirs -#fkLo "!MainProgramPath!\bin\!File!" "!GithubRepo!/bin/!FileURL!"
    )
)

:: <Load Config + WebSettings>
if not exist "!SettingsFile!" call :CREATE_SETTINGS new
call :LoadLocalConfig
call :LoadPasteSettings
:: </Load Config + WebSettings>

title  Listening - !Webpage:/raw=!
cls
echo.
echo   Session has started: !Webpage:/raw=!
echo      Edit Code: !DefaultCode!

:: <Loop>
:SCAN_CHANGE
call :LoadPasteSettings
if /i "!TTS!"=="true" call :PLAY_TTS "!TTS_SPEAK!" "!TTS_VOICE!" "!TTS_VOLUME!"
if /i "!YOUTUBE!"=="true" call :YOUTUBE_PLAY "!YOUTUBE_URI!"

timeout /t !ScanTimeout! /nobreak>nul
goto :SCAN_CHANGE
:: </Loop>

:: <TTS Plugin>
:PLAY_TTS
set TTS_VOICE_SELECTED=
set VolumeDurationError=
if not defined TTS_SPEAK (
    echo.
    echo  ERROR: I had Nothing to say, i disabled TTS for you.
    REM DISABLE TTS (TTS=false)
    set TTS=false
    call :CREATE_SETTINGS "edit"
    exit /b
)
if /i "!TTS_VOICE!"=="david" set TTS_VOICE_SELECTED=David
if /i "!TTS_VOICE!"=="zira" set TTS_VOICE_SELECTED=Zira
if not defined TTS_VOICE_SELECTED (
    echo.
    echo  ERROR: Voice Selected was invalid
    REM DISABLE TTS + SET VOICE TO DAVID
    set TTS=false
    set TTS_VOICE=!DefaultTTSVoice!
    call :CREATE_SETTINGS "edit"
    exit /b
)
if not !TTS_VOLUME! geq 1 set VolumeDurationError=true
if not !TTS_VOLUME! leq 100 set VolumeDurationError=true
if "!VolumeDurationError!"=="true" (
    echo.
    echo  ERROR: Volume number has to be at the range of 1 - 100
    echo       Setting volume to '!DefaultTTSVolume!' and disabling TTS.
    set TTS_VOLUME=!DefaultTTSVolume!
    call :CREATE_SETTINGS "edit"
    exit /b
)
echo.
echo  Request: TTS with the voice '!TTS_VOICE_SELECTED!' - Volume: !TTS_VOLUME!
echo     Speech: !TTS_SPEAK!
call "!File[2]!" "!TTS_VOICE_SELECTED!" "!TTS_VOLUME!" "!TTS_SPEAK!"
set TTS=false
call :CREATE_SETTINGS "edit"
exit /b
:: </TTS Plugin>

:: <Youtube Plugin>
:YOUTUBE_PLAY
set IsValid=false

for /f "delims=" %%a in ('call "!File[3]!" --no-playlist -e "!YOUTUBE_URI!" 2^>nul') do set IsValid=true
if "!IsValid!"=="true" for /f "delims=" %%a in ('call "!File[3]!" --no-playlist -e "!YOUTUBE_URI!"') do set "VideoName=%%a"

if "!IsValid!"=="false" (
    echo.
    echo  ERROR: Youtube Video not found, I Disabled YouTube Read Mode and reset the URL.
    set YOUTUBE=false
    set YOUTUBE_URI=URL
    call :CREATE_SETTINGS "edit"
    exit /b
) else (
    for /f "delims=" %%a in ('call "!File[3]!" --restrict-filenames -o "%%(title)s.%%(ext)s" --no-playlist --get-filename "!YOUTUBE_URI!"') do (
    set "SoundName=%%a"
    set "SoundName=!SoundName:.mp4=.mp3!"
    )
)
echo.
echo  Request: Youtube Audio - Downloading Sound
echo     Title: !VideoName!

if not exist "Youtube-Sounds\!SoundName!" "!File[3]!" --restrict-filenames -o "Youtube-Sounds\%%(title)s.%%(ext)s" --extract-audio --audio-format mp3 --no-playlist --ffmpeg-location "!File[4]!" "!YOUTUBE_URI!" >nul 2>&1

start "" "!File[1]!" "Youtube-Sounds\!SoundName!"
for /F "skip=1 delims=" %%a in (
    'wmic process where "Description='wscript.exe' and ParentProcessID=%ownPID%" get Description^,ProcessID'
) do for %%b in (%%a) do set AudioPID=%%b

:SongRunning
tasklist | find "!AudioPID!" >nul 2>&1
if !ErrorLevel! equ 0 (
    call :LoadPasteSettings
    if /i "!STOP_SOUNDS!"=="true" (
        set STOP_SOUNDS=false
        echo.
        echo  Request to stop sound accepted.
        taskkill /f /pid "!AudioPID!" >nul 2>&1
    )
) else (
    set YOUTUBE=false
    set STOP_SOUNDS=false
    call :CREATE_SETTINGS "edit"
    echo  Audio Has finished playing.
    ping localhost -n 5 >nul
    exit /b
)
ping localhost -n 2 >nul
goto :SongRunning
:: </Youtube Plugin>

:: <Plugins>
:LoadPasteSettings
call :CHECK_CONNECTION
call :GetPasteStatus
for %%a in (!TTSLoaderNoVal! "YOUTUBE" "YOUTUBE_URI" "STOP_SOUNDS") do set %%~a=
for /F "delims=" %%a in ('call "!file[6]!" -k -s !Webpage!') do (
   <nul set /p="%%a" | >nul findstr /rc:";" || set "%%a"
)
exit /b

:CREATE_SETTINGS
call :CHECK_CONNECTION
if not exist "!SettingsFile!" (
    for %%a in (!TTSLoader! "YOUTUBE=false" "YOUTUBE_URI=URL" "STOP_SOUNDS=false") do set "%%~a"
)

if !CurrentOS! equ 10 (
    >"!WebSettings!" (
    echo ; if you want to play TTS enable TTS, You can also choose what it will say. ^(under TTS_SPEAK^)
    echo ; TTS Supported voices: David, Zira
    echo ; TTS Volume: 1 - 100
    echo TTS=!TTS!
    echo TTS_SPEAK=!TTS_SPEAK!
    echo TTS_VOICE=!TTS_VOICE!
    echo TTS_VOLUME=!TTS_VOLUME!
    echo.
    )
) else >"!WebSettings!" echo ; Since you are using windows 7 TTS feature is disabled for you.
>>"!WebSettings!" (
    echo ; if you want to play YouTube Music enable YOUTUBE, under "YOUTUBE_URI" provide the youtube URL
    echo YOUTUBE=!YOUTUBE!
    echo YOUTUBE_URI=!YOUTUBE_URI!
    echo.
    echo ; if you asked the computer to play sounds you can stop them by changing this to true.
    echo STOP_SOUNDS=!STOP_SOUNDS!
)
if !CurrentOS! equ 10 (
    >>"!WebSettings!" (
        echo.
        echo ; if both modes are enabled the program will only read TTS and then youtube
        echo ; if both modes are disabled the script will do continue listening for change.
    )
)

set "EditMode=%~1"
if "!EditMode!"=="new" (
    set "APIRequest=call !File[5]! --edit-code !DefaultCreationCode! new"
) else (
    set "APIRequest=call !File[5]! edit -u "!Webpage:/raw=!" --edit-code !DefaultCreationCode!"
)
for /f "delims=" %%a in ('type !WebSettings! ^| !APIRequest!') do if "!EditMode!"=="new" set "%%~a"
del "!WebSettings!"
if not exist "!SettingsFile!" (
    >"!SettingsFile!" (
    echo [Paste_Settings]
    echo Webpage=!URL!/raw
    echo DefaultCode=!EDIT_CODE!
    )
    attrib +r "!SettingsFile!"
    call :LoadLocalConfig
)
exit /b

:CHECK_CONNECTION
ping rentry.co -n 1 | findstr "TTL" >nul
if !ErrorLevel! equ 1 (
    echo.
    echo  ERROR: Failed to connect, Retrying in 5 minutes.
    ping localhost -n 300 >nul
    goto:CHECK_CONNECTION
)
exit /b

:GetPasteStatus
for /f "tokens=*" %%a in ('call "!file[6]!" -k -s !Webpage!') do if "%%a"=="<!DOCTYPE html>" (
    echo.
    echo  ERROR: Paste not found, Prepating to re-install.
    ping localhost -n 5 >nul
    attrib -r "!SettingsFile!"
    del "!SettingsFile!"
    call :CREATE_SETTINGS new
)
exit /b

:getPID  <RtnVar>
setlocal disableDelayedExpansion
:getLock
set "lock=%temp%\%~nx0.%time::=.%.lock"
set "uid=%lock:\=:b%"
set "uid=%uid:,=:c%"
set "uid=%uid:'=:q%"
set "uid=%uid:_=:u%"
setlocal enableDelayedExpansion
set "uid=!uid:%%=:p!"
endlocal & set "uid=%uid%"
2>nul ( 9>"%lock%" (
  for /f "skip=1" %%A in (
    'wmic process where "name='cmd.exe' and CommandLine like '%%<%uid%>%%'" get ParentProcessID'
  ) do for %%B in (%%A) do set "PID=%%B"
  (call )
)) || goto :getLock
del "%lock%" 2>nul
endlocal & set "%~1=%PID%"
exit /b

:LoadLocalConfig
for /F "delims=" %%a in (!SettingsFile!) do (
   <nul set /p="%%a" | >nul findstr /rc:"^[\[#].*" || set "%%a"
)
exit /b
:: </Plugins>
