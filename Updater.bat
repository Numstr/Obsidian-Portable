@echo off
SetLocal EnableExtensions EnableDelayedExpansion

cd /d %~dp0

set HERE=%~dp0

set BUSYBOX="%HERE%App\Utils\busybox.exe"
set CURL="%HERE%App\Utils\curl.exe"
set SZIP="%HERE%App\Utils\7za.exe"

:::::: NETWORK CHECK

%CURL% -is www.google.com | %BUSYBOX% grep -q "200 OK"

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

set LATEST="https://github.com/obsidianmd/obsidian-releases/releases/latest"

%CURL% -s -k -I %LATEST% | %BUSYBOX% grep -o tag/v[0-9.]\+[0-9] | %BUSYBOX% cut -d "v" -f2 > version.txt

for /f %%V in ('more version.txt') do (set VERSION=%%V)
echo Latest: %VERSION%

if exist "version.txt" del "version.txt" > NUL

::::::::::::::::::::

:::::: RUNNING PROCESS CHECK

for /f %%P in ('tasklist /NH /FI "IMAGENAME eq Obsidian.exe"') do if %%P == Obsidian.exe (
  echo Close Session To Update
  pause
  exit
)

::::::::::::::::::::

:::::: GET LATEST VERSION

if exist "TMP" rmdir "TMP" /s /q
mkdir "TMP"

set OBSIDIAN="https://github.com/obsidianmd/obsidian-releases/releases/download/v%VERSION%/Obsidian.%VERSION%%ARCH%.exe"

%CURL% -# -k -L %OBSIDIAN% -o TMP\Obsidian.%VERSION%%ARCH%.exe

::::::::::::::::::::

:::::: UNPACKING

if exist "App\Obsidian" rmdir "App\Obsidian" /s /q

%SZIP% x -aoa TMP\Obsidian.%VERSION%%ARCH%.exe -o"App\Obsidian" > NUL

::::::::::::::::::::

rmdir "TMP" /s /q

echo Done

pause
