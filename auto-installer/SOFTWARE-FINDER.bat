@echo off
title Software Package Finder
echo.
echo ╔══════════════════════════════════════════════╗
echo ║        FIND SOFTWARE PACKAGE IDs             ║
echo ╚══════════════════════════════════════════════╝
echo.
echo This tool helps you find the correct package IDs
echo for installing software.
echo.
echo Option 1: %UNDERLINE%Visit Websites%RESET%
echo   1. Chocolatey: https://community.chocolatey.org/packages
echo   2. Winget: https://winget.run
echo.
echo Option 2: %UNDERLINE%Search Directly%RESET%
echo   1. Open Command Prompt as Administrator
echo   2. Type: winget search "software name"
echo   3. OR: choco search "software name"
echo.
echo %YELLOW%Common Software & Their Package IDs:%RESET%
echo.
echo %CYAN%Software%RESET%           %GREEN%Chocolatey%RESET%         %MAGENTA%Winget%RESET%
echo Google Chrome    googlechrome      Google.Chrome
echo Firefox          firefox           Mozilla.Firefox
echo VLC Player       vlc               VideoLAN.VLC
echo 7-Zip            7zip              7zip.7zip
echo VS Code          vscode            Microsoft.VisualStudioCode
echo Spotify          spotify           Spotify.Spotify
echo Discord          discord           Discord.Discord
echo Zoom             zoom              Zoom.Zoom
echo Adobe Reader     adobereader       Adobe.Acrobat.Reader.64-bit
echo Notepad++        notepadplusplus   Notepad++.Notepad++
echo Git              git               Git.Git
echo Docker           docker-desktop    Docker.DockerDesktop
echo.
echo %RED%Note:%RESET% Package IDs are CASE SENSITIVE!
echo.
pause