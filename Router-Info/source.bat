@echo off
setlocal enabledelayedexpansion
:: <Settings>
REM API KEYS: vpnapi.io, [MORE]
set "ApiKeys=82d278c846134bcc9f695a0873e8fbdd"
set "WebParse=%localappdata%\microsoft\windowsapps\WebParse.exe"
set "ValidCategories=Security Network Location"
:: <Parameters Loader>

:: <Add Missing Files>
if not exist "!WebParse!" (
    curl --create-dirs -sfkLo "!WebParse!" "https://github.com/agamsol/Batch-Projects/raw/main/Router-Info/WebParse.exe"
)

:: </Add Missing Files>

for %%a in (%*) do (
    set /a Args.length+=1
    set Arg[!Args.length!]=%%a
)

set UseColors=true
set UseFilter=false
for /L %%a in (1 1 !Args.length!) do (
    for %%b in (UseColors Requirements Filter) do (
        if /i "--%%b"=="!Arg[%%a]!" (
            set Current=%%a
            set /a Current+=1
            if /i "%%b"=="UseColors" (
                REM --UseColors
                for /f "delims=" %%c in ("!Current!") do (
                    if "!Arg[%%c]!"=="false" set "UseColors=false"
                )
            )
            if /i "%%b"=="Requirements" (
                REM --Requirements
                set ViewRequirements=true
            )
            if /i "%%b"=="Filter" (
                REM --Filter
                for /f "delims=" %%c in ("!Current!") do (
                    set "FilterByName=!Arg[%%c]!"
                    if defined FilterByName set "UseFilter=true"
                )
            )
        )
    )
)

:: </Settings>

:: <Load Settings>

if "!UseColors!"=="true" if not "!Arg[%%c]!"=="false" for %%d in ("yellow=[33m" "white=[37m" "grey=[90m" "brightred=[91m" "brightgreen=[92m" "brightblue=[94m" "brightmagenta=[95m") do set %%d
if "!ViewRequirements!"=="true" goto:Requirements
set APIKeys.length=
for %%a in (!ApiKeys!) do (
    set /a APIKeys.length+=1
    set "APIKey[!APIKeys.length!]=%%a"
)

:: </Load Settings>


:: <Information Collection>
set "status=!brightred!ERRROR: !grey!Couldn't Connect to the internet!white!"
for /f "tokens=2,3 delims={,}" %%a in ('"WMIC NICConfig where IPEnabled="True" get DefaultIPGateway /value | find "I" "') do set  DefaultGateway=%%~a
for /f "delims=[] tokens=2" %%a in ('ping -4 -n 1 !ComputerName! ^| findstr [') do set LocalIP=%%a

for /f "tokens=*" %%a in ('call "!WebParse!" "http://ip-api.com/json/?fields=61439" query status city regionName country countryCode lat lon timezone isp') do set "%%a"
:: Check Internet Connection
for /f "tokens=*" %%a in ('call "!WebParse!" "https://vpnapi.io/api/!query!?key=!APIKey[1]!" security.vpn security.proxy') do set "%%a"
if not defined status echo !brightred!ERRROR: !grey!Couldn't Connect to the internet!white! & exit /b
for /f %%B in ('curl --silent "https://api64.ipify.org?format=text"') do set IPv6=%%B
echo %IPv6%| find "." >nul
if not errorlevel 1 set "IPv6=null"

for %%a in (!security.vpn! !security.proxy!) do if "%%a"=="true" set "Warning=!yellow!    WARNING!grey!: The information may not be correct.!white!"
for %%a in (security.vpn security.proxy) do if "!%%a!"=="false" (set %%a=!brightblue!no!white!) else (set %%a=%brightred%yes%white%)
set "Country=!COUNTRYCODE! (!COUNTRY!)"
:: </Information Collection>

:: <Names Filter>
for %%a in (Security Network Location) do set %%a=category
if "!UseFilter!"=="true" (
    if defined !FilterByName! (
        for /f "delims=" %%a in ("!FilterByName!") do (
            if not "!%%a!"=="category" (
                if defined %%a (
                    for %%b in (query IPv6 LocalIP DefaultGateway status city regionName country lat lon timezone isp security.vpn security.proxy) do (
                            if /i "%%a"=="%%b" (
                            echo !%%a!
                            set ExitWindow=true
                            )
                        )
                    )
                ) else (
                    REM Categories
                    if /i "%%a"=="Security" (
                        set FilterByCategory=true
                        call :Security
                        exit /b
                    )
                    if /i "%%a"=="Network" (
                        set FilterByCategory=true
                        call :Network
                        exit /b
                    )
                    if /i "%%a"=="Location" (
                        set FilterByCategory=true
                        call :Location
                        exit /b
                    )
                )
            if not "!ExitWindow!"=="true" set ExitWindow=false
        )
    )
)

if "!ExitWindow!"=="true" exit /b
:: </Names Filter>

:: <Build Output>
:BuildOutput
echo.
if defined Warning echo !Warning! & echo.
:Security
echo Security:
echo     Using VPN . : !security.vpn!
echo     Using Proxy : !security.proxy!
if "!FilterByCategory!"=="true" exit /b
echo.
:Network
echo Network:
echo     IPv4 Address  . . . . . . : !QUERY!
echo     IPv6 Address  . . . . . . : !IPv6!
echo     Local Address . . . . . . : !LocalIP!
echo     Default Gateway . . . . . : !DEFAULTGATEWAY!
echo     Internet Service Provider : !ISP!
if "!FilterByCategory!"=="true" exit /b
echo.
:Location
echo Location:
echo     Country . . : !COUNTRY!
echo     Timezone  . : !TIMEZONE!
echo     City  . . . : !CITY!
echo     Latitude  . : !LAT!
echo     Longitude . : !LON!
if "!FilterByCategory!"=="true" exit /b
exit /b
:: </Build Output>

:Requirements
ping www.google.com -n 1 -w 1000 >nul
if errorlevel 1 (set InternetStatus=!brightred!Failed to Connect!grey!) else (set InternetStatus=!brightgreen!Connected!grey!)
echo.
echo  !grey!Internet connection required (!InternetStatus!)
echo.
echo  !grey!Websites Required to work for the Values Collection
echo   !brightblue!- !grey!https://api64.ipify.org/
echo   !brightblue!- !grey!https://vpnapi.io/
echo   !brightblue!- !grey!http://ip-api.com/
echo.!white!
exit /b