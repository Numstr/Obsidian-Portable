@echo off

cd /d %~dp0

set HERE=%~dp0
set HERE_DS=%HERE:\=\\%

set BUSYBOX="%HERE%App\Utils\busybox.exe"
set SZIP="%HERE%App\Utils\7za.exe"

:::::: NETWORK CHECK

%BUSYBOX% wget -q --user-agent="Mozilla" --spider https://google.com

if "%ERRORLEVEL%" == "1" (
  echo Check Your Network Connection
  pause
  exit
)

::::::::::::::::::::

:::::: ARCH

if "%PROCESSOR_ARCHITECTURE%" == "x86" (
  set ARCH=-32
) else if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  set ARCH=
) else exit

:: set ARCH=-32
:: set ARCH=

::::::::::::::::::::

:::::: VERSION CHECK

if not exist "%WINDIR%\system32\wbem\wmic.exe" goto LATEST

wmic datafile where name='%HERE_DS%App\\Obsidian\\Obsidian.exe' get version | %BUSYBOX% tail -n2 ^
 | %BUSYBOX% rev ^
 | %BUSYBOX% cut -c 6- ^
 | %BUSYBOX% rev > current.txt

for /f %%V in ('more current.txt') do (set CURRENT=%%V)
echo Current: %CURRENT%

:LATEST

set LATEST_URL="https://github.com/obsidianmd/obsidian-releases/releases/latest"

%BUSYBOX% wget -q -O - %LATEST_URL% | %BUSYBOX% grep -o tag/v[0-9.]\+[0-9] | %BUSYBOX% cut -d "v" -f2 > latest.txt

for /f %%V in ('more latest.txt') do (set LATEST=%%V)
echo Latest: %LATEST%
echo:

if exist "current.txt" del "current.txt" > NUL
if exist "latest.txt" del "latest.txt" > NUL

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

set OBSIDIAN="https://github.com/obsidianmd/obsidian-releases/releases/download/v%LATEST%/Obsidian.%LATEST%%ARCH%.exe"

%BUSYBOX% wget %OBSIDIAN% -O TMP\Obsidian_%LATEST%%ARCH%.exe

::::::::::::::::::::

:::::: UNPACKING

echo:
echo Unpacking

if exist "App\Obsidian" rmdir "App\Obsidian" /s /q

%SZIP% x -aoa TMP\Obsidian_%LATEST%%ARCH%.exe -o"App\Obsidian" > NUL

rmdir "TMP" /s /q

:::::: APP INFO

%BUSYBOX% sed -i "/Version/d" "%HERE%App\AppInfo\AppInfo.ini"
echo. >> "App\AppInfo\AppInfo.ini"
echo [Version] >> "App\AppInfo\AppInfo.ini"
echo DisplayVersion=%LATEST% >> "App\AppInfo\AppInfo.ini"

::::::::::::::::::::

echo:
echo Done

pause
