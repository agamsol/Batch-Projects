@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
set "el=bgbrightred=[101m,bgblack=[40m,bgyellow=[43m,black=[30m,red=[31m,green=[32m,yellow=[33m,blue=[34m,magenta=[35m,cyan=[36m,white=[37m,grey=[90m,brightred=[91m,brightgreen=[92m,brightyellow=[93m,brightblue=[94m,brightmagenta=[95m,brightcyan=[96m,brightwhite=[97m,underline=[4m,underlineoff=[24m"
set "%el:,=" && set "%"
FOR /F "tokens=3 delims= " %%G in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal"') do set docsdir=%%G
if not exist "!docsdir!\Rockstar Games\GTA V\User Music" md "!docsdir!\Rockstar Games\GTA V\User Music"
set "WorkingPath=!appdata!\GTA 5 Tools"

set File= & set MissingFiles= & set Filled=
set db="GTA%%205%%20Tools.ico" "Shortcuts.vbs" "pssuspend.exe" "youtube-dl.exe" "ffmpeg\bin\ffmpeg.exe" "ffmpeg\bin\ffprobe.exe" "ffmpeg\bin\ffplay.exe"
for %%a in (!db!) do if not exist "!WorkingPath!\Lib\%%~a" (
    set /a MissingFiles+=1
    )
for %%a in (!db!) do if not exist "!WorkingPath!\Lib\%%~a" (
set /a File+=1
cls
echo.
echo   !green!√ !grey!Downloading Files !File!/!MissingFiles!
set el=%%~a
set temp.elpath=!EL:%%20= !
set el=!el:\=/!
>nul curl --create-dirs -#fkLo "!WorkingPath!\Lib\!temp.elpath!" "https://github.com/agamsol/Batch-Projects/raw/main/GTA%%205%%20Tools/Lib/!el!"
set Filled=true
)
if "!Filled!"=="true" (
    for /f "usebackq tokens=3*" %%D IN (`reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop`) do set DESKTOP_PATH=%%D
    cscript "!WorkingPath!\Lib\Shortcuts.vbs" "!DESKTOP_PATH!\GTA 5 Tools" "!appdata!\GTA 5 Tools\Actions.bat" "%~dp0\Lib\GTA 5 Tools.ico, 0" >nul 2>&1
)

:: <Main Selection Menu>
:MAIN_MENU
title GTA 5 Tools
cls
echo.
echo   !brightblue!╔═══════════════════════════╗
echo   ║       !white!█!bgbrightred! !black!MAIN MENU !bgblack!!white!█       !brightblue!║
echo   ╠═══════════════════════════╣
echo   ║                           ║
echo   ║  !magenta!1. !grey!Solo-Public Session   !brightblue!║
echo   ║                           ║
echo   ║  !magenta!2. !grey!Self-Radio Songs      !brightblue!║
echo   ║                           ║
echo   ╚═══════════════════════════╝
echo.
set /p "Userinput.MainSelection=!magenta!--> !grey!"
if !Userinput.MainSelection! equ 1 call:SoloPublicSession
if !Userinput.MainSelection! equ 2 call:Music_MENU
echo.
echo   !brightred!ERROR: !grey!Invalid Option selected.
ping localhost -n 4 >nul
goto:MAIN_MENU
:: </Main Selection Menu>


:: <Solo-Public Session>
:SoloPublicSession
 title GTA 5 Tools ^| Solo-Public Session -^> Console
 call:GTA_STATUS
 cls
 echo.
 if "!IS.RUNNING.GTA!"=="false" (
     echo   !brightred!ERROR: !grey!GTA is not running . . .
     ping localhost -n 4 >nul
     goto:MAIN_MENU
 )
 echo  !grey!INFO: Suspending Connection . . .
 call "!WorkingPath!\Lib\pssuspend.exe" GTA5.exe >nul 2>&1
 ping localhost -n 2 >nul
 echo.
 echo  !grey!INFO: Waiting !cyan!10 !grey!seconds
 ping localhost -n 10 >nul
 echo.
 echo  !grey!INFO: Resuming Connection . . .
 call "!WorkingPath!\Lib\pssuspend.exe" GTA5.exe -r >nul 2>&1
 ping localhost -n 3 >nul
 echo.
 echo  !brightgreen!INFO: !grey!Connection resumed, Solo-Public Session generated.
 ping localhost -n 10 >nul
 GOTO:MAIN_MENU
:: </Solo-Public Session>


:: <Music Selection Menu>
:Music_MENU
title GTA 5 Tools ^| Self Radio
set Tracks.count=0
for /f "delims=" %%a in ('dir /b "!docsdir!\Rockstar Games\GTA V\User Music\*.mp3"2^>nul') do (
    set /a Tracks.count+=1
)
set "Tracks.count.menu=!Tracks.count!             "
cls
echo.
echo   !brightblue!╔═══════════════════════════╗
echo   ║    !white!█!bgbrightred! !black!MAIN MUSIC MENU !bgblack!!white!█    !brightblue!║
echo   ╠═══════════════════════════╣
echo   ║                           ║
echo   ║  !magenta!1. !grey!Add New Track         !brightblue!║
echo   ║                           ║
echo   ║  !magenta!2. !grey!Delete Track          !brightblue!║
echo   ║                           ║
echo   ║  !magenta!3. !grey!Manage Station Tracks !brightblue!║
echo   ║                           ║
echo   ╠═══════════════════════════╣
echo   ║   !brightwhite!Tracks Amount: !brightred!!Tracks.count.menu:~0,8! !brightblue!║
echo   ╚═══════════════════════════╝
if !Tracks.count! gtr 0 if !Tracks.count! lss 4 echo. &echo   !yellow!WARNING: !grey!You must have !cyan!4 !grey!or more tracks for !cyan!Self-Radio station!grey!.
echo.
echo   !grey!Return to previous page? !cyan!"BACK"!grey!.
echo.
set /p "Userinput.MusicMenu=!magenta!--> !grey!"
set Tracks.count=0
set Tracks.count.menu=0
if "!Userinput.MusicMenu!"=="1" goto:Music_AddTrack
if "!Userinput.MusicMenu!"=="2" goto:Music_DeleteTrack
if "!Userinput.MusicMenu!"=="3" goto:Music_Manage
if /i "!Userinput.MusicMenu!"=="back" goto:MAIN_MENU
echo.
echo   !brightred!ERROR: !grey!Invalid Option selected.
ping localhost -n 4 >nul
goto:Music_MENU
:: </Music Selection Menu>

:: <Add New Track>
:Music_AddTrack
 set SongName.FileNameValidator=
 cls
 echo.
 echo   !cyan!Provide Youtube Video Link to download
 echo.
 set /p "YoutubeURL=!magenta!--> !grey!"
 echo.
 for /f "delims=" %%a in ('call "!WorkingPath!\Lib\youtube-dl.exe" --no-playlist -e "!YoutubeURL!" 2^>nul') do set "SongName=%%a"
 if not defined SongName (
     echo   !brightred!ERROR: !grey!Song URL not found.
     ping localhost -n 4 >nul
     goto:Music_AddTrack
 )
 title GTA 5 Tools ^| Downloading Track
 set SongName.FileNameValidator=!SongName!
 for %%a in ("/" "\" ":" "<" ">" "|") do set SongName.FileNameValidator=!SongName.FileNameValidator:%%~a=!
 set "el=#!SongName.FileNameValidator!"
 :replaceLoop
 for /F "tokens=1 delims=*" %%A in ("!el!") do (
   set "prefix=%%A"
   set "el1=!el:*%%A=!"
   if defined el1 (
     set "el1=!el1:~1!"
     set CheckAgain=1
   ) else set "CheckAgain="
   set "el=%%A!el1!"
 )
 if defined CheckAgain goto :replaceLoop
 set "SongName.FileNameValidator=!el:~1!"
 set SongName.FileNameValidator=!SongName.FileNameValidator:"=!
 set SongName.FileNameValidator=!SongName.FileNameValidator:?=!
 if exist "!docsdir!\Rockstar Games\GTA V\User Music\!SongName.FileNameValidator!.mp3" (
     echo   !yellow!WARNING: !grey!Song Already Exists.
     ping localhost -n 4 >nul
     goto:Music_AddTrack
 )
 call "!WorkingPath!\Lib\youtube-dl.exe" --no-playlist --extract-audio --audio-format mp3 -o "!docsdir!\Rockstar Games\GTA V\User Music\!SongName.FileNameValidator!.mp3" --ffmpeg-location "!WorkingPath!\Lib\ffmpeg\bin" "!YoutubeURL!" >nul
 echo   !brightgreen!Success!grey!, The Track "!SongName.FileNameValidator!" Has been added.
 ping localhost -n 4 >nul
 goto:Music_MENU
:: </Add New Track>

:: <Delete a Track>
:Music_DeleteTrack
 title GTA 5 Tools ^| Select A Track To Delete
 call:SelfRadio_list
 :Music_DeleteTrack_Deletion
 title GTA 5 Tools ^| Delete a track
 cls
 echo.
 echo   !yellow!WARNING: !grey!You are about to delete the track "!brightred!!Userinput.TrackSelection!!grey!"
 echo          Please type "!brightgreen!confirm!grey!" to delete the track.
 echo.
 set /p "Userinput.ConfirmDeletion=!magenta!--> !brightgreen!"
 echo.
 if /i "!Userinput.ConfirmDeletion!"=="confirm" (
     del /q "!docsdir!\Rockstar Games\GTA V\User Music\!Track.ID[%Userinput.TrackSelection%]!"
     echo   !brightgreen!Success!grey!, The Track "!brightred!!Userinput.TrackSelection!!grey!" Has been deleted.
     ping localhost -n 7 >nul
     goto:Music_MENU
 )
 echo   !brightred!Cancelling deletion . . .
 ping localhost -n 4 >nul
 goto:Music_MENU
:: </Delete a Track>

:: <Manage Tracks>
:Music_Manage
 title GTA 5 Tools ^| Manage Music
 call:SelfRadio_list
 title GTA 5 Tools ^| Manage Track: !Userinput.TrackSelection:~,-4!
 cls
 echo.
 echo      !grey!Track Name: !brightred!!Userinput.TrackSelection:~,-4!
 echo.
 echo      !brightblue!1. !grey!Delete Track
 echo.
 echo      !brightblue!2. !grey!Rename Track
 echo.
 echo      !grey!Return to previous page? !cyan!"BACK"!grey!.
 echo.
 set /p "Userinput.ManageTrack=!magenta!--> !grey!"
 if /i "!Userinput.ManageTrack!"=="back" goto:Music_Manage
 if !Userinput.ManageTrack! equ 1 set "Userinput.TrackSelection=!Userinput.TrackSelection!" & call:Music_DeleteTrack_Deletion
 if !Userinput.ManageTrack! equ 2 (
     echo.
     echo   !grey!What's the new name for your track?
     echo.
     set /p "Userinput.RenameTrack=!magenta!--> !grey!"
     rename "!docsdir!\Rockstar Games\GTA V\User Music\!Userinput.TrackSelection!" "!Userinput.RenameTrack!.mp3"
     echo.
     echo   !green!Success!grey!, The Track's new name is !brightblue!!Userinput.RenameTrack!!grey!.
     ping localhost -n 7 >nul
     goto:Music_MENU
 )
 echo.
 echo   !brightred!ERROR: !grey!Invalid Option selected.
 ping localhost -n 4 >nul
 goto:Music_Manage
:: </Manage Tracks>

:: <Self Radio Tracks Lister>
:SelfRadio_list
 for /f "delims=" %%a in ('set "Track.ID[" 2^>nul') do set "%%a]="
 set Tracks.count=0
 set Tracks.count.menu=0
 for /f "delims=" %%a in ('dir /b "!docsdir!\Rockstar Games\GTA V\User Music\*.mp3"2^>nul') do set /a Tracks.count+=1
 if !Tracks.count! equ 0 (
     echo.
     echo   !brightred!ERROR: !grey!No tracks to display.
     ping localhost -n 4 >nul
     goto:Music_MENU
 )
 set Tracks.count=0
 set Tracks.count.menu=0
 cls
 echo.
 echo             !brightblue!════════════════════
 echo           //  !white!█!bgbrightred! !black!TRACKS LIST !bgblack!!white!█  !brightblue!\\
 echo    ╔═════════════════════════════════════════════════════════════╗
 echo    ║                                                             ║
 for /f "delims=" %%a in ('dir /b "!docsdir!\Rockstar Games\GTA V\User Music\*.mp3"2^>nul') do (
     set "Track.current.menu=%%~Na                                                                  "
     set /a Tracks.count+=1
     if !Tracks.count! lss 10 set "Tracks.count= !Tracks.count!"
     if !Tracks.count! leq 99 echo    ║  !magenta!!Tracks.count!. !grey!!Track.current.menu:~0,54! !brightblue!║
     if !Tracks.count! gtr 99 echo    ║ !magenta!!Tracks.count!. !grey!!Track.current.menu:~0,54! !brightblue!║
     set "Track.ID[!Tracks.count: =!]=%%~a"
     echo    ║                                                             ║
 )
 set "Tracks.count.menu=!Tracks.count!                                                        "
 echo    ╠═════════════════════════════════════════════════════════════╣
 echo    ║   !brightwhite!Tracks Amount: !brightred!!Tracks.count.menu:~0,42! !brightblue!║
 echo    ╚═════════════════════════════════════════════════════════════╝
 echo.
 echo    !grey!Return to previous page? !cyan!"BACK"!grey!.
 echo.
 set /p "Userinput.TrackSelection=!magenta!--> !grey!"
 if /i "!Userinput.TrackSelection!"=="back" goto:Music_MENU
 if not defined Track.ID[%Userinput.TrackSelection%] (
     echo.
     echo   !brightred!ERROR: !grey!Invalid Selection
     ping localhost -n 4 >nul
     goto:SelfRadio_list
 )
 set "Userinput.TrackSelection=!Track.ID[%Userinput.TrackSelection%]!"
 goto:eof
:: </Self Radio Tracks Lister>

:: <GTA Running>
:GTA_STATUS
 set IS.RUNNING.GTA=false
 tasklist /FI "IMAGENAME eq GTA5.exe.exe" 2>NUL | find /I /N "GTA5.exe">NUL
 if "%ERRORLEVEL%"=="0" set IS.RUNNING.GTA=true
 goto:eof
:: </GTA Running>
