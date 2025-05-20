@echo off

setlocal enabledelayedexpansion

cd /d %~dp0

set HERE=%~dp0
set HERE_DS=%HERE:\=\\%

set BUSYBOX="%HERE%App\Utils\busybox.exe"
set CURL=%HERE%App\Utils\curl.exe
set SZIP="%HERE%App\Utils\7za.exe"

:::::: PROXY

set USE_PROXY=false
set PROXY_TYPE=http
set PROXY_ADDRESS=127.0.0.1:3128


if %USE_PROXY% == true (
  set PROXY_URL=%PROXY_TYPE%://%PROXY_ADDRESS%
  set CURL_PROXY=--proxy !%PROXY_URL!
)

::::::::::::::::::::

:::::: NETWORK CHECK

%CURL% -I -s %CURL_PROXY% https://cern.ch | %BUSYBOX% grep -q "HTTP"

if "%ERRORLEVEL%" == "1" (
  echo Check Your Network Connection
  pause
  exit
)

::::::::::::::::::::

:::::: ARCH

if "%PROCESSOR_ARCHITECTURE%" == "x86" (
  set ARCH=6.7z
) else if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  set ARCH=4.7z
) else exit

:: set ARCH=6.7z
:: set ARCH=4.7z
:: set ARCH=2.7z

:: 6.7z x32
:: 4.7z x64
:: 2.7z arm64

::::::::::::::::::::

:::::: VERSION CHECK

if not exist "%WINDIR%\system32\wbem\wmic.exe" goto LATEST

for /f %%V in ('wmic datafile where "name='%HERE_DS%App\\Obsidian\\Obsidian.exe'" get version
  ^| %BUSYBOX% tail -n2
  ^| %BUSYBOX% rev
  ^| %BUSYBOX% cut -c 6-
  ^| %BUSYBOX% rev') ^
do (set CURRENT=%%V)
echo Current: %CURRENT%

:LATEST

set LATEST_URL="https://github.com/obsidianmd/obsidian-releases/releases/latest"

for /f %%V in ('%CURL% -I -s %CURL_PROXY% %LATEST_URL%
  ^| %BUSYBOX% grep -o tag/v[0-9.]\+[0-9]
  ^| %BUSYBOX% cut -d "v" -f2') ^
do (set LATEST=%%V)
echo Latest: %LATEST%
echo:

if "%CURRENT%" == "%LATEST%" (
  echo You Have The Latest Version
  pause
  exit
) else goto PROCESS

::::::::::::::::::::

:PROCESS

:::::: RUNNING PROCESS CHECK

if not exist "%WINDIR%\system32\tasklist.exe" goto GET

for /f %%P in ('tasklist /NH /FI "IMAGENAME eq Obsidian.exe"') do if %%P == Obsidian.exe (
  echo Close Obsidian To Update
  pause
  exit
)

::::::::::::::::::::

:GET

:::::: GET LATEST VERSION

if exist "TMP" rmdir "TMP" /s /q
mkdir "TMP"

set OBSIDIAN="https://github.com/obsidianmd/obsidian-releases/releases/download/v%LATEST%/Obsidian-%LATEST%.exe"

%CURL% -L %CURL_PROXY% %OBSIDIAN% -o TMP\Obsidian-%LATEST%.exe

::::::::::::::::::::

:::::: UNPACKING

echo:
echo Unpacking

if exist "App\Obsidian" rmdir "App\Obsidian" /s /q

%SZIP% x -t# -aoa TMP\Obsidian-%LATEST%.exe -o"TMP" %ARCH% > NUL
%SZIP% x -aoa TMP\%ARCH% -o"App\Obsidian" > NUL

rmdir "TMP" /s /q

:::::: APP INFO

%BUSYBOX% sed -i "/Version/d" "%HERE%App\AppInfo\AppInfo.ini"
for /f %%N in ('%BUSYBOX% tail -c 1 %HERE%App\AppInfo\AppInfo.ini') do (set LINE=%%N)
if "%LINE%" == "n" (
  (echo;& echo;) >> "App\AppInfo\AppInfo.ini"
)
(echo [Version]& echo DisplayVersion=%LATEST%) >> "App\AppInfo\AppInfo.ini"

::::::::::::::::::::

echo:
echo Done

pause
