@ECHO OFF
SETLOCAL EnableDelayedExpansion

>nul 2>&1 cacls "%SYSTEMROOT%\system32\config\system"

if %ERRORLEVEL% NEQ 0 (
  GOTO :UAC_REQUEST
) else (
  GOTO :UAC_ACCEPTED
)

:UAC_ACCEPTED
ECHO ---------------------------------------------------------------------------
ECHO Automated Cygwin, VirtualBox and Vagrant setup
ECHO ---------------------------------------------------------------------------

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && SET ARCH=32 || SET ARCH=64
REM -- Disable UAC.
REM -- @todo: Is it really have to be disabled? At the top we're requesting this script to be executed by UID 1. Also, restart is needed to apply.
REM reg ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f

REM -- Save PowerShell version into variable with exit code.
powershell -command "exit $PSVersionTable.PSVersion.Major"

REM -- PowerShell 3 or better must be installed.
REM -- https://github.com/BR0kEN-/cikit#windows
if %ERRORLEVEL% LSS 3 (
  ECHO [INFO] Installing PowerShell 3
  CALL :download PowerShell https://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x64.msu %TEMP%\KB2506143-x64.msu
  START /B /wait %TEMP%\KB2506143-x64.msu /quiet /norestart
  REM -- @todo: How to deal with fact that after this execution system restart is needed?
  REM -- https://serverfault.com/a/539247
)

REM ----------------------------------------------------------------------------
SET CYGWIN_SITE=http://cygwin.mirrors.pair.com
SET CYGWIN_ROOTDIR=%SystemDrive%\cygwin%ARCH%
SET CYGWIN_FILENAME=setup-x86

REM -- "setup-x86.exe" or "setup-x86_64.exe".
if 64 == %ARCH% (
  SET CYGWIN_FILENAME=%CYGWIN_FILENAME%_%ARCH%
)

SET CYGWIN_FILENAME=%CYGWIN_FILENAME%.exe
SET CYGWIN_INSTALLER=%TEMP%\%CYGWIN_FILENAME%

REM -- Read packages from the file.
FOR /F %%L IN (%~dp0\packages.txt) DO SET CYGWIN_PACKAGES=!CYGWIN_PACKAGES!%%L,

if not exist %CYGWIN_ROOTDIR% (
  MKDIR %CYGWIN_ROOTDIR%
)

CALL :download Cygwin https://www.cygwin.com/%CYGWIN_FILENAME% %CYGWIN_INSTALLER%

REM -- https://cygwin.com/faq/faq.html#faq.setup.cli
SET CYGWIN_INSTALLER=%CYGWIN_INSTALLER% --quiet-mode --no-shortcuts --download --local-install --no-verify --site %CYGWIN_SITE% --local-package-dir %TEMP% --root %CYGWIN_ROOTDIR%

ECHO [INFO] Installing default Cygwin packages
START /B /wait %CYGWIN_INSTALLER%

ECHO [INFO] Installing custom Cygwin packages
START /B /wait %CYGWIN_INSTALLER% --packages %CYGWIN_PACKAGES:~0,-1%

REM -- Update PATH variable to have Cygwin available.
SET PATH=%CYGWIN_ROOTDIR%\bin;%PATH%

REM -- Compute path to CWD in Unix style.
FOR /F %%D IN ('cygpath -u %~dp0') DO SET CWD=%%D

REM -- Set path to sources for tests.
SET TESTSDIR=%CWD%/..

REM ----------------------------------------------------------------------------
REM -- 7-Zip will be used for unpacking ISO image, containing VirtualBox Guest Additions.
ECHO [INFO] Installing 7-Zip
SET SEVENZIP_FILENAME=7z1604

REM -- "7z1604.msi" or "7z1604-x64.msi".
if 64 == %ARCH% (
  SET SEVENZIP_FILENAME=%SEVENZIP_FILENAME%-x%ARCH%
)

SET SEVENZIP_FILENAME=%SEVENZIP_FILENAME%.msi

CALL :download 7-Zip http://7-zip.org/a/%SEVENZIP_FILENAME% %TEMP%\%SEVENZIP_FILENAME%
CALL :install 7-Zip %TEMP%\%SEVENZIP_FILENAME%

REM -- Update PATH variable to have 7-Zip available.
SET PATH=%PROGRAMFILES%\7-Zip;%PATH%

REM ----------------------------------------------------------------------------
ECHO [INFO] Installing Ansible
bash --login %TESTSDIR%/ansible.sh

REM ----------------------------------------------------------------------------
ECHO [INFO] Installing VirtualBox
CALL :install_variables virtualbox

SET VBOXGUEST_FILENAME=VBoxGuestAdditions_%VERSION%.iso
SET VBOXGUEST_MOUNTDIR=%TEMP%\vbox-guest-additions

CALL :download VirtualBoxGuestAdditions %URL%/%VBOXGUEST_FILENAME% %TEMP%\%VBOXGUEST_FILENAME%

7z e -o%VBOXGUEST_MOUNTDIR% %TEMP%\%VBOXGUEST_FILENAME% -y
REM -- Ensure Oracle certificate added for unattended VirtualBox installation.
certutil -addstore -f "TrustedPublisher" %VBOXGUEST_MOUNTDIR%\vbox-sha1.cer

START /B /wait %VBOXGUEST_MOUNTDIR%\VboxWindowsAdditions.exe /S
START /B /wait %TEMP%\%EXE% --path %TEMP% --extract --silent
CALL :install VirtualBox %TEMP%\%MSI%

REM ----------------------------------------------------------------------------
ECHO [INFO] Installing Vagrant
CALL :install_variables vagrant
CALL :install Vagrant %TEMP%\%MSI%

REM ----------------------------------------------------------------------------
if /I "test-vm" == "%1" (
  REM -- "php-version" -- "nodejs-version" -- "solr-version" -- "ruby-version".
  bash --login %TESTSDIR%/cikit.sh "%2" "%3" "%4" "%5"

  if "%ERRORLEVEL%" NEQ "0" (
    ECHO [ERROR] Unable to boot VM.
    EXIT /B 1
  ) else (
    ECHO [SUCCESS] VM successfully provisioned.
  )
)

ENDLOCAL
EXIT /B 0

REM ----------------------------------------------------------------------------
:UAC_REQUEST
SET SCRIPT=%TEMP%\cikit.vbs

if exist %SCRIPT% (
  DEL %SCRIPT%
)

ECHO Set UAC = CreateObject^("Shell.Application"^) > %SCRIPT%
ECHO UAC.ShellExecute "cmd", "/c %~s0 %*", "", "runas", 1 >> %SCRIPT%

START /B /wait %SCRIPT%
EXIT /B 0

REM ----------------------------------------------------------------------------
:download
if not exist %3 (
  ECHO [INFO] Downloading %1
  bitsadmin /transfer "Downloading %1" "%2" "%3"
)

if not exist %3 (
  ECHO [ERROR] %1 downloading failed
  EXIT /B 1
)

EXIT /B 0

REM ----------------------------------------------------------------------------
:install_variables
FOR /F "tokens=1-4 delims=|" %%a IN ('bash --login %TESTSDIR%/%1/install.sh "windows" "%ARCH%" "%TEMP%"') DO SET "EXE=%%a" & SET "MSI=%%b" & SET "VERSION=%%c" & SET "URL=%%d"
EXIT /B

REM ----------------------------------------------------------------------------
:install
START /B /wait msiexec /i %2 TARGETDIR=%SystemDrive%\%1%ARCH% /L*vx %1-install.log /norestart /QB
EXIT /B 0
