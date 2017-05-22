@ECHO OFF
ECHO ---------------------------------------------------------------------------
ECHO Automated Cygwin, VirtualBox and Vagrant setup
ECHO ---------------------------------------------------------------------------

SETLOCAL EnableDelayedExpansion

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && SET OS=32 || SET OS=64

REM ----------------------------------------------------------------------------
SET CYGWIN_SITE=http://cygwin.mirrors.pair.com
SET CYGWIN_ROOTDIR=%SystemDrive%\cygwin%OS%
SET CYGWIN_FILENAME=setup-x86

REM -- "setup-x86.exe" or "setup-x86_64.exe".
if 64 == %OS% (
  SET CYGWIN_FILENAME=%CYGWIN_FILENAME%_%OS%
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
FOR /F %%D IN ('cygpath.exe -u %~dp0') DO SET CWD=%%D

REM -- Set path to sources for tests.
SET TESTSDIR=%CWD%/..

REM ----------------------------------------------------------------------------
ECHO [INFO] Installing Ansible
bash --login %TESTSDIR%/ansible.sh

REM -- VirtualBox installation depends on Bash utils, provided by Cygwin.
REM ----------------------------------------------------------------------------
ECHO [INFO] Installing VirtualBox
SET VBOX_SITE=http://download.virtualbox.org/virtualbox
SET VBOX_ROOTDIR=%SystemDrive%\virtualbox%OS%
REM -- 5.1.22
FOR /F "delims=" %%i IN ('bash --login %TESTSDIR%/virtualbox/version.sh "%VBOX_SITE%"') DO SET VBOX_VERSION=%%i
REM -- There's a listing which looks like:
REM -- 3b39482338acaef512ab5b3de384efba *VirtualBox-5.1.22-115126-OSX.dmg
REM -- b2562cf5d492a7186f90742390342482 *VirtualBox-5.1.22-115126-SunOS.tar.gz
REM -- 5918f1e7274412b81e88d40005c0c3c3 *VirtualBox-5.1.22-115126-Win.exe
REM -- Result: VirtualBox-5.1.22-115126-Win.exe
FOR /F "delims=" %%i IN ('bash --login %TESTSDIR%/virtualbox/filename.sh "%VBOX_SITE%" "%VBOX_VERSION%"') DO SET VBOX_FILENAME=%%i
REM -- VirtualBox-5.1.22-115126-Win.exe -> 115126
FOR /F "delims=" %%i IN ('bash --login %TESTSDIR%/virtualbox/build-id.sh "%VBOX_FILENAME%"') DO SET VBOX_BUILD_ID=%%i
REM -- VirtualBox-5.1.22-r115126-MultiArch
SET VBOX_MSINAME=VirtualBox-%VBOX_VERSION%-r%VBOX_BUILD_ID%-MultiArch

if 64 == %OS% (
  REM -- VirtualBox-5.1.22-r115126-MultiArch_amd64.msi
  SET VBOX_MSINAME=%VBOX_MSINAME%_amd%OS%
) else (
  REM -- VirtualBox-5.1.22-r115126-MultiArch_x86.msi
  SET VBOX_MSINAME=%VBOX_MSINAME%_x86
)

REM -- Append ".msi".
SET VBOX_MSINAME=%VBOX_MSINAME%.msi

REM -- Download "*.exe".
wget -nc -O %TEMP%\%VBOX_FILENAME% %VBOX_SITE%/%VBOX_VERSION%/%VBOX_FILENAME%
REM -- Extract "*.exe".
START /B /wait %TEMP%\%VBOX_FILENAME% --path %TEMP% --extract --silent
REM -- Install "*.msi".
CALL :install VirtualBox %TEMP%\%VBOX_MSINAME% %VBOX_ROOTDIR%

REM -- Vagrant installation depends on Bash utils, provided by Cygwin.
REM ----------------------------------------------------------------------------
ECHO [INFO] Installing Vagrant
SET VAGRANT_SITE=https://releases.hashicorp.com/vagrant
SET VAGRANT_DOORDIR=%SystemDrive%\vagrant%OS%
REM -- There's a listing which looks like:
REM -- <li><a href="/vagrant/1.9.5/">vagrant_1.9.5</a></li>
REM -- <li><a href="/vagrant/1.9.5/">vagrant_1.9.4</a></li>
REM -- <li><a href="/vagrant/1.9.5/">vagrant_1.9.3</a></li>
REM -- Result: vagrant_1.9.5
FOR /F "delims=" %%i IN ('bash --login %TESTSDIR%/vagrant/filename.sh "%VAGRANT_SITE%"') DO SET VAGRANT_MSINAME=%%i
REM -- vagrant_1.9.5 -> 1.9.5
FOR /F "delims=" %%i IN ('bash --login %TESTSDIR%/vagrant/version.sh "%VAGRANT_MSINAME%"') DO SET VAGRANT_VERSION=%%i
REM -- vagrant_1.9.5 -> vagrant_1.9.5.msi
SET VAGRANT_MSINAME=%VAGRANT_MSINAME%.msi

wget -nc -O %TEMP%\%VAGRANT_MSINAME% %VAGRANT_SITE%/%VAGRANT_VERSION%/%VAGRANT_MSINAME%
CALL :install Vagrant %TEMP%\%VAGRANT_MSINAME% %VAGRANT_DOORDIR%

REM ----------------------------------------------------------------------------
REM -- Provision the VM.
if /I "test-vm" == "%1" (
  REM -- "php-version" -- "nodejs-version" -- "solr-version" -- "ruby-version".
  bash --login %TESTSDIR%/cikit.sh "%2" "%3" "%4" "%5"
)

REM ----------------------------------------------------------------------------
:download

if not exist %3 (
  ECHO [INFO] Downloading %1
  bitsadmin /transfer "Downloading %1" %2 %3
)

if not exist %3 (
  ECHO [ERROR] %1 downloading failed
  GOTO end
)

EXIT /B 0

REM ----------------------------------------------------------------------------
:install

START /B /wait msiexec /i %2 /L*vx %2-install.log /norestart /QB TARGETDIR=%3
EXIT /B 0

REM ----------------------------------------------------------------------------
:end

ENDLOCAL
PAUSE
EXIT /B 0
