@echo off

cd /d %~dp0

set HERE=%~dp0
set HERE_DS=%HERE:\=\\%

set BUSYBOX="%HERE%App\Utils\busybox.exe"
set CURL="%HERE%App\Utils\curl.exe"
set SZIP="%HERE%App\Utils\7za.exe"

:::::: NETWORK CHECK

%CURL% -I -s www.google.com | %BUSYBOX% grep -q "200 OK"

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

wmic datafile where name='%HERE_DS%App\\Obsidian\\Obsidian.exe' get version | %BUSYBOX% tail -n2 | %BUSYBOX% cut -c 1-6 > current.txt

for /f %%V in ('more current.txt') do (set CURRENT=%%V)
echo Current: %CURRENT%

set LATEST_URL="https://github.com/obsidianmd/obsidian-releases/releases/latest"

%CURL% -I -k -s %LATEST_URL% | %BUSYBOX% grep -o tag/v[0-9.]\+[0-9] | %BUSYBOX% cut -d "v" -f2 > latest.txt

for /f %%V in ('more latest.txt') do (set LATEST=%%V)
echo Latest: %LATEST%

if exist "current.txt" del "current.txt" > NUL
if exist "latest.txt" del "latest.txt" > NUL

if "%CURRENT%" == "%LATEST%" (
  echo You Have The Latest Version
  pause
  exit
) else goto CONTINUE

::::::::::::::::::::

:CONTINUE

:::::: RUNNING PROCESS CHECK

for /f %%P in ('tasklist /NH /FI "IMAGENAME eq Obsidian.exe"') do if %%P == Obsidian.exe (
  echo Close Obsidian To Update
  pause
  exit
)

::::::::::::::::::::

:::::: GET LATEST VERSION

if exist "TMP" rmdir "TMP" /s /q
mkdir "TMP"

set OBSIDIAN="https://github.com/obsidianmd/obsidian-releases/releases/download/v%LATEST%/Obsidian.%LATEST%%ARCH%.exe"

%CURL% -k -L %OBSIDIAN% -o TMP\Obsidian.%LATEST%%ARCH%.exe

::::::::::::::::::::

:::::: UNPACKING

if exist "App\Obsidian" rmdir "App\Obsidian" /s /q

%SZIP% x -aoa TMP\Obsidian.%LATEST%%ARCH%.exe -o"App\Obsidian" > NUL

::::::::::::::::::::

rmdir "TMP" /s /q

echo Done

pause
