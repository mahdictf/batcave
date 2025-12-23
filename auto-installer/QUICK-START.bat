@echo off
echo ========================================
echo     SOFTWARE INSTALLER - QUICK START
echo ========================================
echo.
echo Hi! This tool will help you install software easily.
echo.
echo [1] I'm new - Show me how to find software
echo [2] I know what I want - Start installer
echo [3] Exit
echo.
choice /c 123 /n

if %errorlevel% equ 1 goto tutorial
if %errorlevel% equ 2 goto start_installer
if %errorlevel% equ 3 exit

:tutorial
start https://community.chocolatey.org/packages
echo.
echo Great! Now visit the Chocolatey website above.
echo Look for software and note the "Package Id".
echo.
echo Example: For Google Chrome, the Package Id is "googlechrome"
echo.
echo Press any key to continue to the installer...
pause > nul

:start_installer
powershell -Command "Start-Process '%~dp0Ultimate_Installer.bat' -Verb RunAs"
exit