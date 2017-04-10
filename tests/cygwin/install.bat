@ECHO OFF
ECHO --------------------------------------------------------------------------
ECHO Automated Cygwin setup
ECHO --------------------------------------------------------------------------

SETLOCAL

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && SET OS=32 || SET OS=64

FOR /F %%D IN ("%CD%") DO SET DRIVE=%%~dD

SET CYGWIN=setup-x86

if 64 == %OS% (
  SET CYGWIN=%CYGWIN%_%OS%
)

SET CYGWIN=%CYGWIN%.exe

SET SITE=http://cygwin.mirrors.pair.com/
SET ROOTDIR=%DRIVE%\cygwin%OS%
SET SETUPFILE=%DRIVE%\Temp\%CYGWIN%
REM -- Packages to installin in addition to the default.
SET PACKAGES=mintty,vim,wget,curl,ctags,diffutils,git,git-completion,tar,gawk,bzip2
SET PACKAGES=%PACKAGES%,openssh,openssl,openssl-devel,python-2.7,python-jinja,python-crypto,python-openssl,python-setuptools

FOR %%F IN (%SETUPFILE%) DO SET SETUPDIR=%%~dpF

if not exist %SETUPDIR% (
  MKDIR %SETUPDIR%
)

if not exist %ROOTDIR% (
  MKDIR %ROOTDIR%
)

if not exist %SETUPFILE% (
  ECHO [INFO] Downloading
  bitsadmin.exe /transfer "Downloading Cygwin" https://www.cygwin.com/%CYGWIN% %SETUPFILE%
)

if not exist %SETUPFILE% (
  ECHO [ERROR] Downloading failed
  GOTO end
)

REM -- https://cygwin.com/faq/faq.html#faq.setup.cli
SET INSTALLER=%SETUPFILE% --quiet-mode --no-shortcuts --download --local-install --no-verify --site %SITE% --local-package-dir %SETUPDIR% --root %ROOTDIR%

ECHO [INFO] Installing default packages
%INSTALLER%

ECHO [INFO] Installing custom packages
%INSTALLER% --packages %PACKAGES%

REM -- Update PATH variable.
SET PATH=%ROOTDIR%\bin;%PATH%

REM -- Compute path to CWD in Unix style.
FOR /F %%D IN ('cygpath.exe -u %~dp0') DO SET CWD=%%D

ECHO [INFO] Installing Ansible
bash.exe --login "%CWD%/../ansible.sh"

ECHO [INFO] Installing VirtualBox
bash.exe --login "%CWD%/../virtualbox.sh"

ECHO [INFO] Installing Vagrant
bash.exe --login "%CWD%/../vagrant.sh"

REM -- Provision the VM.
if /I "test-vm" == "%1" (
  REM -- "cikit-php-version" -- "cikit-nodejs-version" -- "setup-solr".
  bash.exe --login "%CWD%/../cikit.sh %2 %3 %4"
)

:end

ENDLOCAL
PAUSE
EXIT /B 0
