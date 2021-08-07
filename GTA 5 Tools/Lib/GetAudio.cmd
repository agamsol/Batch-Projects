@echo off
setlocal enabledelayedexpansion

:Select
cls
echo Provide Youtube Video Link
set /p "YoutubeURL=--> "

for /f "delims=" %%a in ('call youtube-dl.exe "!YoutubeURL!" -e 2^>nul') do set "SongName=%%a"

if not defined SongName (
    echo Song Not Found.
    ping localhost -n 4 >nul
    goto:Select
)

youtube-dl --extract-audio --audio-format mp3 -o "%%(title)s.%%(ext)s" --ffmpeg-location "ffmpeg\bin" "!YoutubeURL!" >nul

pause