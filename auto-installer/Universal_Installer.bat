@echo off
title Ultimate Software Installer Pro v4.0
setlocal enabledelayedexpansion

:: ===========================================
:: CONFIGURATION
:: ===========================================
set VERSION=4.0
set AUTHOR=TechPro Installer
set "DEFAULT_PACKAGE_MANAGER=BOTH"  :: WINGET, CHOCOLATEY, or BOTH
set "LOG_FILE=logs\install_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.txt"
set "SOFTWARE_LISTS_DIR=software_lists"
set "BACKUP_DIR=backups"
set "CREATE_RESTORE_POINT=YES"

:: Colors with fallback for compatibility
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" (
    for /f %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
) else (
    set "ESC="
)
set "RESET=%ESC%[0m"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "RED=%ESC%[91m"
set "BLUE=%ESC%[94m"
set "CYAN=%ESC%[96m"
set "MAGENTA=%ESC%[95m"
set "BOLD=%ESC%[1m"
set "UNDERLINE=%ESC%[4m"

:: ===========================================
:: INITIALIZATION & ADMIN CHECK
:: ===========================================
:init
cls
call :print_header "ULTIMATE SOFTWARE INSTALLER PRO v%VERSION%"

echo %YELLOW%Checking system requirements...%RESET%
echo.

:: Check admin rights
call :check_admin
if !ADMIN_STATUS! neq 1 goto :eof

:: Create necessary directories
for %%d in (logs "%SOFTWARE_LISTS_DIR%" "%BACKUP_DIR%" cache) do (
    if not exist "%%~d" mkdir "%%~d"
)

:: Detect available package managers
call :detect_package_managers

:: Initialize log
echo [%date% %time%] ===== INSTALLATION SESSION STARTED ===== > "%LOG_FILE%"
echo [%date% %time%] System: %PROCESSOR_ARCHITECTURE%, OS: %OS% >> "%LOG_FILE%"
echo [%date% %time%] Detected managers: Winget:!WINGET_AVAILABLE! Choco:!CHOCO_AVAILABLE! >> "%LOG_FILE%"

goto main_menu

:: ===========================================
:: MAIN MENU
:: ===========================================
:main_menu
cls
call :print_header "MAIN MENU"

echo %CYAN%[1]%RESET% %BOLD%Quick Install Wizard%RESET%        %YELLOW%(Recommended for beginners)%RESET%
echo %CYAN%[2]%RESET% %BOLD%Smart Package Finder%RESET%        %YELLOW%(Search & install any software)%RESET%
echo %CYAN%[3]%RESET% %BOLD%Batch Installation%RESET%          %YELLOW%(From predefined lists)%RESET%
echo %CYAN%[4]%RESET% %BOLD%Create Custom List%RESET%          %YELLOW%(Build your own collection)%RESET%
echo %CYAN%[5]%RESET% %BOLD%System Tools%RESET%                %YELLOW%(Optimize & maintain)%RESET%
echo %CYAN%[6]%RESET% %BOLD%Settings & Configuration%RESET%
echo %CYAN%[7]%RESET% %BOLD%Help & Tutorial%RESET%
echo %CYAN%[8]%RESET% %BOLD%Exit%RESET%
echo.
echo %BLUE%═══════════════════════════════════════════════════════%RESET%
echo %YELLOW%Available Package Managers:%RESET%
if !WINGET_AVAILABLE! equ 1 echo   %GREEN%✓%RESET% Windows Package Manager (winget)
if !CHOCO_AVAILABLE! equ 1 echo   %GREEN%✓%RESET% Chocolatey (choco)
echo %BLUE%═══════════════════════════════════════════════════════%RESET%

choice /c 12345678 /n /m "Select option (1-8): "

if %errorlevel% equ 1 goto quick_wizard
if %errorlevel% equ 2 goto package_finder
if %errorlevel% equ 3 goto batch_install
if %errorlevel% equ 4 goto create_list
if %errorlevel% equ 5 goto system_tools
if %errorlevel% equ 6 goto settings
if %errorlevel% equ 7 goto help_tutorial
if %errorlevel% equ 8 goto exit_script

:: ===========================================
:: QUICK INSTALL WIZARD (For Beginners)
:: ===========================================
:quick_wizard
cls
call :print_header "QUICK INSTALL WIZARD"

echo %YELLOW%Welcome to the Quick Install Wizard!%RESET%
echo I'll help you install the most popular software for your needs.
echo.
echo %BOLD%Select your computer type:%RESET%
echo.
echo %CYAN%[1]%RESET% %BOLD%Personal / Home Use%RESET%
echo   • Browser, Media, Office, Communication
echo.
echo %CYAN%[2]%RESET% %BOLD%Work / Office Computer%RESET%
echo   • Productivity, Development, Team Collaboration
echo.
echo %CYAN%[3]%RESET% %BOLD%Gaming & Entertainment%RESET%
echo   • Games, Streaming, Performance Tools
echo.
echo %CYAN%[4]%RESET% %BOLD%Creative & Design%RESET%
echo   • Graphics, Video, Audio Editing
echo.
echo %CYAN%[5]%RESET% %BOLD%Developer Machine%RESET%
echo   • IDEs, Tools, Servers, Version Control
echo.
echo %CYAN%[6]%RESET% %BOLD%Custom Selection%RESET%
echo   • Choose from all categories
echo.
echo %CYAN%[0]%RESET% Back to Main Menu
echo.

:retry_choice
choice /c 1234560 /n /m "Select category (1-6, 0=Back): "

set "CATEGORY_FILE="
if %errorlevel% equ 1 set "CATEGORY_FILE=personal"
if %errorlevel% equ 2 set "CATEGORY_FILE=work"
if %errorlevel% equ 3 set "CATEGORY_FILE=gaming"
if %errorlevel% equ 4 set "CATEGORY_FILE=creative"
if %errorlevel% equ 5 set "CATEGORY_FILE=developer"
if %errorlevel% equ 6 goto custom_selection
if %errorlevel% equ 7 goto main_menu

:: Check if category file exists, create if not
if not exist "%SOFTWARE_LISTS_DIR%\%CATEGORY_FILE%.txt" (
    echo %YELLOW%Creating %CATEGORY_FILE% software list...%RESET%
    call :create_category_list "%CATEGORY_FILE%"
)

cls
call :print_header "CATEGORY: %CATEGORY_FILE:^= %"

echo %GREEN%Recommended software for this category:%RESET%
echo %BLUE%═══════════════════════════════════════════════════════%RESET%
type "%SOFTWARE_LISTS_DIR%\%CATEGORY_FILE%.txt"
echo %BLUE%═══════════════════════════════════════════════════════%RESET%
echo.

echo %YELLOW%Installation Options:%RESET%
echo [1] Install ALL recommended software
echo [2] Select specific software to install
echo [3] View detailed information
echo [4] Back to category selection
choice /c 1234 /n /m "Select option: "

if %errorlevel% equ 1 (
    echo Installing ALL software from %CATEGORY_FILE% category...
    call :batch_install_file "%SOFTWARE_LISTS_DIR%\%CATEGORY_FILE%.txt"
    pause
    goto quick_wizard
)
if %errorlevel% equ 2 (
    call :selective_install "%SOFTWARE_LISTS_DIR%\%CATEGORY_FILE%.txt"
    goto quick_wizard
)
if %errorlevel% equ 3 (
    call :show_category_details "%CATEGORY_FILE%"
    goto quick_wizard
)
if %errorlevel% equ 4 goto quick_wizard

:: ===========================================
:: SMART PACKAGE FINDER
:: ===========================================
:package_finder
cls
call :print_header "SMART PACKAGE FINDER"

echo %YELLOW%Search for any software across Chocolatey and Winget repositories%RESET%
echo.
echo %CYAN%How to use:%RESET%
echo 1. Search by name, category, or description
echo 2. Select package manager (or search both)
echo 3. Install directly or add to your list
echo.
echo %BOLD%Search Options:%RESET%
echo [1] Search by software name
echo [2] Browse by category
echo [3] Most popular software
echo [4] Recently added
echo [5] Back to Main Menu
echo.

choice /c 12345 /n /m "Select search method: "

if %errorlevel% equ 1 goto search_by_name
if %errorlevel% equ 2 goto browse_categories
if %errorlevel% equ 3 goto most_popular
if %errorlevel% equ 4 goto recently_added
if %errorlevel% equ 5 goto main_menu

:search_by_name
cls
call :print_header "SEARCH SOFTWARE"
set /p "search_term=Enter software name or keywords: "
if "!search_term!"=="" goto package_finder

echo.
echo %YELLOW%Searching for: "!search_term!"%RESET%
echo This may take a moment...
echo.

:: Search in both repositories
set "results_file=cache\search_results_%time:~0,2%%time:~3,2%%time:~6,2%.txt"

if !WINGET_AVAILABLE! equ 1 (
    echo %BLUE%[Winget Results]%RESET%
    winget search "!search_term!" --source winget | head -20
    echo.
)

if !CHOCO_AVAILABLE! equ 1 (
    echo %MAGENTA%[Chocolatey Results]%RESET%
    choco search "!search_term!" -r | head -20
    echo.
)

echo %BLUE%═══════════════════════════════════════════════════════%RESET%
echo.
set /p "package_id=Enter Package ID to install (or press Enter to go back): "
if not "!package_id!"=="" (
    call :install_with_manager "!package_id!"
)
goto package_finder

:browse_categories
cls
call :print_header "BROWSE BY CATEGORY"

echo %CYAN%Select a category to browse:%RESET%
echo.
echo [1] Browsers
echo [2] Media Players
echo [3] Office & Productivity
echo [4] Development Tools
echo [5] Security & Privacy
echo [6] System Utilities
echo [7] Graphics & Design
echo [8] Games & Entertainment
echo [9] Back
echo.

choice /c 123456789 /n /m "Select category: "

set "choco_cat="
set "winget_cat="

if %errorlevel% equ 1 set "choco_cat=browsers" & set "winget_cat=Browsers"
if %errorlevel% equ 2 set "choco_cat=mediaplayers" & set "winget_cat=Video.Players"
if %errorlevel% equ 3 set "choco_cat=productivity" & set "winget_cat=Productivity"
if %errorlevel% equ 4 set "choco_cat=development" & set "winget_cat=DeveloperTools"
if %errorlevel% equ 5 set "choco_cat=security" & set "winget_cat=Security"
if %errorlevel% equ 6 set "choco_cat=system" & set "winget_cat=Utilities"
if %errorlevel% equ 7 set "choco_cat=graphics" & set "winget_cat=DesignTools"
if %errorlevel% equ 8 set "choco_cat=games" & set "winget_cat=Games"
if %errorlevel% equ 9 goto package_finder

echo.
echo %YELLOW%Browsing %choco_cat% category...%RESET%
echo.

if !CHOCO_AVAILABLE! equ 1 (
    echo %MAGENTA%[Chocolatey - %choco_cat%]%RESET%
    choco search --category="%choco_cat%" --approved-only | head -15
    echo.
)

if !WINGET_AVAILABLE! equ 1 (
    echo %BLUE%[Winget - %winget_cat%]%RESET%
    winget search --tag "%winget_cat%" | head -15
    echo.
)

echo %BLUE%═══════════════════════════════════════════════════════%RESET%
echo.
echo %YELLOW%Tips:%RESET%
echo • Visit %UNDERLINE%https://community.chocolatey.org/packages%RESET% for more packages
echo • Visit %UNDERLINE%https://winget.run/%RESET% to browse Winget packages
echo • Use exact Package ID for installation
echo.
pause
goto browse_categories

:most_popular
cls
call :print_header "MOST POPULAR SOFTWARE"

echo %YELLOW%Top 10 Most Popular Packages:%RESET%
echo.
echo %MAGENTA%[Chocolatey Popular]%RESET%
echo 1. googlechrome - Google Chrome Browser
echo 2. firefox - Mozilla Firefox
echo 3. vlc - VLC Media Player
echo 4. 7zip - 7-Zip Compression
echo 5. notepadplusplus - Notepad++
echo 6. adobereader - Adobe Reader
echo 7. java8jre - Java Runtime
echo 8. slack - Slack
echo 9. teamviewer - TeamViewer
echo 10. zoom - Zoom Client
echo.

echo %BLUE%[Winget Popular]%RESET%
echo 1. Microsoft.VisualStudioCode
echo 2. Git.Git
echo 3. Microsoft.PowerToys
echo 4. Docker.DockerDesktop
echo 5. Python.Python.3.11
echo 6. Microsoft.PowerShell
echo 7. Postman.Postman
echo 8. NodeJS.NodeJS
echo 9. Microsoft.WindowsTerminal
echo 10. Ubuntu
echo.

echo %BLUE%═══════════════════════════════════════════════════════%RESET%
set /p "install_popular=Enter package number to install (1-10) or name: "
if not "!install_popular!"=="" (
    call :install_popular_package "!install_popular!"
)
goto package_finder

:: ===========================================
:: HELPER FUNCTIONS
:: ===========================================
:check_admin
set "ADMIN_STATUS=0"
net session >nul 2>&1
if %errorLevel% equ 0 (
    set "ADMIN_STATUS=1"
) else (
    echo %RED%[ERROR] Administrator privileges required!%RESET%
    echo.
    echo %YELLOW%To run this script:%RESET%
    echo 1. Right-click on the file
    echo 2. Select "Run as administrator"
    echo 3. Click Yes on the UAC prompt
    echo.
    echo %YELLOW%Alternatively, run this command:%RESET%
    echo powershell -Command "Start-Process '%~f0' -Verb RunAs"
    echo.
    pause
)
goto :eof

:detect_package_managers
set "WINGET_AVAILABLE=0"
set "CHOCO_AVAILABLE=0"

where winget >nul 2>&1
if %errorlevel% equ 0 set "WINGET_AVAILABLE=1"

where choco >nul 2>&1
if %errorlevel% equ 0 set "CHOCO_AVAILABLE=1"

:: Install Chocolatey if not available but user wants it
if !CHOCO_AVAILABLE! equ 0 (
    echo %YELLOW%Chocolatey not detected.%RESET%
    set /p "install_choco=Would you like to install Chocolatey? (Y/N): "
    if /i "!install_choco!"=="Y" (
        echo Installing Chocolatey...
        powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
        where choco >nul 2>&1
        if %errorlevel% equ 0 set "CHOCO_AVAILABLE=1"
    )
)

:: Install Winget if not available
if !WINGET_AVAILABLE! equ 0 (
    echo %YELLOW%Winget not detected. Installing...%RESET%
    powershell -Command "Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe"
    where winget >nul 2>&1
    if %errorlevel% equ 0 set "WINGET_AVAILABLE=1"
)

if !WINGET_AVAILABLE! equ 0 if !CHOCO_AVAILABLE! equ 0 (
    echo %RED%[ERROR] No package manager available!%RESET%
    echo Please install at least one package manager manually.
    pause
    exit /b 1
)
goto :eof

:print_header
echo %BOLD%%CYAN%╔═══════════════════════════════════════════════════════╗
echo ║ %~1%RESET%
echo %BOLD%%CYAN%╚═══════════════════════════════════════════════════════╝%RESET%
echo.
goto :eof

:create_category_list
set "category=%~1"
if "!category!"=="personal" (
    (
        echo # Personal / Home Computer Essentials
        echo # Generated: %date% %time%
        echo.
        echo # Browsers
        echo googlechrome       ; Chocolatey: Google Chrome
        echo Microsoft.Edge     ; Winget: Microsoft Edge
        echo.
        echo # Media & Entertainment
        echo vlc                ; VLC Media Player
        echo Spotify.Spotify    ; Spotify Music
        echo.
        echo # Communication
        echo Discord.Discord    ; Discord
        echo zoom               ; Zoom Client
        echo.
        echo # Utilities
        echo 7zip               ; 7-Zip Compression
        echo adobereader        ; Adobe Reader
        echo ccleaner           ; System Cleaner
        echo.
        echo # Office
        echo LibreOffice        ; Free Office Suite
    ) > "%SOFTWARE_LISTS_DIR%\!category!.txt"
)

if "!category!"=="developer" (
    (
        echo # Developer Machine Essentials
        echo.
        echo # IDEs & Editors
        echo Microsoft.VisualStudioCode
        echo JetBrains.IntelliJIDEA.Community
        echo Notepad++.Notepad++
        echo.
        echo # Version Control
        echo Git.Git
        echo GitHub.GitHubDesktop
        echo.
        echo # Development Tools
        echo Docker.DockerDesktop
        echo Postman.Postman
        echo Python.Python.3.11
        echo NodeJS.NodeJS
        echo Microsoft.PowerShell
        echo.
        echo # Databases
        echo MongoDB             ; MongoDB Community
        echo MySQLWorkbench      ; MySQL GUI
    ) > "%SOFTWARE_LISTS_DIR%\!category!.txt"
)
goto :eof

:install_with_manager
set "package=%~1"
echo.
echo %YELLOW%Select package manager for !package!:%RESET%
echo [1] Chocolatey (choco)
echo [2] Winget (winget)
echo [3] Try both (auto-detect)
choice /c 123 /n /m "Select: "

if %errorlevel% equ 1 (
    if !CHOCO_AVAILABLE! equ 1 (
        choco install !package! -y
    ) else (
        echo %RED%Chocolatey not available!%RESET%
    )
)
if %errorlevel% equ 2 (
    if !WINGET_AVAILABLE! equ 1 (
        winget install --id !package! --silent --accept-package-agreements
    ) else (
        echo %RED%Winget not available!%RESET%
    )
)
if %errorlevel% equ 3 (
    echo %YELLOW%Trying both package managers...%RESET%
    if !WINGET_AVAILABLE! equ 1 (
        winget install --id !package! --silent 2>nul && (
            echo %GREEN%✓ Installed via Winget%RESET%
            goto :eof
        )
    )
    if !CHOCO_AVAILABLE! equ 1 (
        choco install !package! -y 2>nul && (
            echo %GREEN%✓ Installed via Chocolatey%RESET%
            goto :eof
        )
    )
    echo %RED%Failed to install with both managers%RESET%
)
goto :eof

:: ===========================================
:: CREATE CUSTOM LIST WIZARD
:: ===========================================
:create_list
cls
call :print_header "CREATE CUSTOM SOFTWARE LIST"

echo %YELLOW%Create your own personalized software collection%RESET%
echo.
echo [1] Start from scratch (empty list)
echo [2] Start from template (recommended categories)
echo [3] Import from existing installation
echo [4] Merge multiple lists
echo [5] Back to Main Menu
echo.

choice /c 12345 /n /m "Select option: "

if %errorlevel% equ 1 goto create_new_list
if %errorlevel% equ 2 goto use_template
if %errorlevel% equ 3 goto import_existing
if %errorlevel% equ 4 goto merge_lists
if %errorlevel% equ 5 goto main_menu

:create_new_list
set /p "list_name=Enter name for your list (e.g., MyLaptop): "
if "!list_name!"=="" goto create_list

set "list_file=%SOFTWARE_LISTS_DIR%\!list_name!.txt"
if exist "!list_file!" (
    echo %YELLOW%List already exists! Overwrite? (Y/N):%RESET%
    choice /c YN /n
    if %errorlevel% equ 2 goto create_list
)

echo # Custom Software List: !list_name! > "!list_file!"
echo # Created: %date% %time% >> "!list_file!"
echo # Usage: Add package IDs below (one per line) >> "!list_file!"
echo. >> "!list_file!"
echo # Example packages: >> "!list_file!"
echo # googlechrome       ; Chocolatey package >> "!list_file!"
echo # Microsoft.VisualStudioCode ; Winget package >> "!list_file!"
echo. >> "!list_file!"

echo %GREEN%List created: !list_file!%RESET%
notepad "!list_file!"
echo.
echo %YELLOW%Would you like to:%RESET%
echo [1] Install this list now
echo [2] Add more software
echo [3] Return to menu
choice /c 123 /n /m "Select: "

if %errorlevel% equ 1 call :batch_install_file "!list_file!"
if %errorlevel% equ 2 goto create_list
goto main_menu

:: ===========================================
:: HELP & TUTORIAL
:: ===========================================
:help_tutorial
cls
call :print_header "HELP & TUTORIAL"

echo %BOLD%%CYAN%📚 GETTING STARTED%RESET%
echo.
echo %YELLOW%1. Finding Package IDs:%RESET%
echo.
echo %UNDERLINE%For Chocolatey:%RESET%
echo • Visit: %CYAN%https://community.chocolatey.org/packages%RESET%
echo • Search for software
echo • Copy the "Package Id" (e.g., "googlechrome")
echo.
echo %UNDERLINE%For Winget:%RESET%
echo • Visit: %CYAN%https://winget.run/%RESET%
echo • Search for software
echo • Copy the "Package Identifier" (e.g., "Microsoft.VisualStudioCode")
echo.
echo %YELLOW%2. Sample Package IDs:%RESET%
echo.
echo %MAGENTA%Chocolatey Examples:%RESET%
echo • Browsers: googlechrome, firefox, brave
echo • Media: vlc, spotify, itunes
echo • Tools: 7zip, ccleaner, everything
echo • Development: vscode, git, python
echo.
echo %BLUE%Winget Examples:%RESET%
echo • Microsoft.VisualStudioCode
echo • Google.Chrome
echo • Git.Git
echo • VideoLAN.VLC
echo • Spotify.Spotify
echo.
echo %YELLOW%3. Quick Commands:%RESET%
echo • Search: %CYAN%winget search "name"%RESET%
echo • Search: %CYAN%choco search "name"%RESET%
echo • Install: %CYAN%winget install Package.Id%RESET%
echo • Install: %CYAN%choco install package-id -y%RESET%
echo.
echo %RED%⚠️ IMPORTANT:%RESET%
echo • Run script as Administrator
echo • Some software may require restart
echo • Keep your lists backed up
echo.
pause
goto main_menu

:: ===========================================
:: EXIT
:: ===========================================
:exit_script
cls
call :print_header "THANK YOU FOR USING INSTALLER PRO"

echo %GREEN%✅ Installation session completed!%RESET%
echo.
echo %BOLD%Summary:%RESET%
echo • Logs saved to: %LOG_FILE%
echo • Software lists in: %SOFTWARE_LISTS_DIR%\
echo • Backups in: %BACKUP_DIR%\
echo.
echo %YELLOW%📁 Your Files Are Here:%RESET%
echo %~dp0
echo.
echo %CYAN%💡 Tips for Next Time:%RESET%
echo 1. Keep your software lists in cloud storage
echo 2. Share lists with friends/colleagues
echo 3. Update lists when you find new software
echo.
echo %MAGENTA%🔗 Useful Links:%RESET%
echo • Chocolatey Packages: https://community.chocolatey.org/packages
echo • Winget Packages: https://winget.run/
echo • Package Converter: https://chocolatey.org/install
echo.
pause
exit