@ECHO OFF
ECHO ---------------------------------------------------------------------------
ECHO Automated Cygwin, VirtualBox and Vagrant setup
ECHO ---------------------------------------------------------------------------

SETLOCAL EnableDelayedExpansion

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && SET OS=32 || SET OS=64

SET TEMPDIR=%SystemDrive%\Temp

if not exist %TEMPDIR% (
  MKDIR %TEMPDIR%
)

REM ----------------------------------------------------------------------------
SET CYGWIN_SITE=http://cygwin.mirrors.pair.com
SET CYGWIN_ROOTDIR=%SystemDrive%\cygwin%OS%
SET CYGWIN_FILENAME=setup-x86

if 64 == %OS% (
  SET CYGWIN_FILENAME=%CYGWIN_FILENAME%_%OS%
)

SET CYGWIN_FILENAME=%CYGWIN_FILENAME%.exe
SET CYGWIN_INSTALLER=%TEMPDIR%/%CYGWIN_FILENAME%

REM -- Read packages from the file.
FOR /F %%L IN (%~dp0\packages.txt) DO SET CYGWIN_PACKAGES=!CYGWIN_PACKAGES!%%L,

if not exist %CYGWIN_ROOTDIR% (
  MKDIR %CYGWIN_ROOTDIR%
)

if not exist %CYGWIN_INSTALLER% (
  ECHO [INFO] Downloading Cygwin
  bitsadmin.exe /transfer "Downloading Cygwin" https://www.cygwin.com/%CYGWIN_FILENAME% %CYGWIN_INSTALLER%
)

if not exist %CYGWIN_INSTALLER% (
  ECHO [ERROR] Cygwin downloading failed
  GOTO end
)

REM -- https://cygwin.com/faq/faq.html#faq.setup.cli
SET CYGWIN_INSTALLER=%CYGWIN_INSTALLER% --quiet-mode --no-shortcuts --download --local-install --no-verify --site %CYGWIN_SITE% --local-package-dir %TEMPDIR% --root %CYGWIN_ROOTDIR%

ECHO [INFO] Installing default Cygwin packages
%CYGWIN_INSTALLER%

ECHO [INFO] Installing custom Cygwin packages
%CYGWIN_INSTALLER% --packages %CYGWIN_PACKAGES:~0,-1%

REM -- Compute path to CWD in Unix style.
FOR /F %%D IN ('cygpath.exe -u %~dp0') DO SET CWD=%%D

REM -- Update PATH variable to have Cygwin available.
SET PATH=%CYGWIN_ROOTDIR%\bin;%PATH%
SET TESTSDIR=%CWD%/..

REM ----------------------------------------------------------------------------
ECHO [INFO] Installing Ansible
bash.exe --login %TESTSDIR%/ansible.sh

REM ----------------------------------------------------------------------------
ECHO [INFO] Installing VirtualBox
if not exist LATEST.txt (
  wget.exe http://download.virtualbox.org/virtualbox/LATEST.TXT
)

FOR /F %%V IN (LATEST.TXT) DO SET VIRTUALBOX_VERSION=%%V

REM @todo Continue here.

REM ----------------------------------------------------------------------------
ECHO [INFO] Installing Vagrant

REM -- Provision the VM.
if /I "test-vm" == "%1" (
  REM -- "php-version" -- "nodejs-version" -- "solr-version" -- "ruby-version".
  bash.exe --login %TESTSDIR%/cikit.sh "%2" "%3" "%4" "%5"
)

:end

ENDLOCAL
PAUSE
EXIT /B 0
