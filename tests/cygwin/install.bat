@ECHO OFF
SETLOCAL EnableDelayedExpansion

>nul 2>&1 cacls %SYSTEMROOT%\system32\config\system

if %errorlevel% NEQ 0 (
  goto UAC_REQUEST
) else (
  goto UAC_ACCEPTED
)

:UAC_ACCEPTED
ECHO ---------------------------------------------------------------------------
ECHO Automated Cygwin, VirtualBox and Vagrant setup
ECHO ---------------------------------------------------------------------------

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && SET OS=32 || SET OS=64
REM -- Disable UAC.
reg ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f

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

REM ----------------------------------------------------------------------------
ECHO [INFO] Installing VirtualBox
CALL :install_variables "virtualbox"
START /B /wait %TEMP%\%FILENAME% --path %TEMP% --extract --silent
CALL :install VirtualBox %TEMP%\%MSINAME% %SystemDrive%\virtualbox%OS%

REM ----------------------------------------------------------------------------
ECHO [INFO] Installing Vagrant
CALL :install_variables "vagrant"
CALL :install Vagrant %TEMP%\%MSINAME% %SystemDrive%\vagrant%OS%

REM ----------------------------------------------------------------------------
if /I "test-vm" == "%1" (
  REM -- "php-version" -- "nodejs-version" -- "solr-version" -- "ruby-version".
  bash --login %TESTSDIR%/cikit.sh "%2" "%3" "%4" "%5"
)

ECHO All good.
PAUSE
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
  bitsadmin /transfer "Downloading %1" %2 %3
)

if not exist %3 (
  ECHO [ERROR] %1 downloading failed
  GOTO end
)

EXIT /B 0

REM ----------------------------------------------------------------------------
:install_variables
FOR /F "tokens=1,2 delims=|" %%a IN ('bash --login %TESTSDIR%/%1/install.sh "%OS%" "%TEMP%"') DO SET "FILENAME=%%a" & SET "MSINAME=%%b"
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
