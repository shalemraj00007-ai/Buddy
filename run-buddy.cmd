@echo off
REM Fast start: assumes server deps are installed and web/ is already built.
cd /d "%~dp0"
echo [Buddy] Starting Buddy on http://localhost:4000
echo [Buddy] On your phone, open http://YOUR-LAN-IP:4000
call npm --prefix server run start
