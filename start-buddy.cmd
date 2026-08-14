@echo off
REM ============================================================
REM  Buddy launcher for Windows
REM  Builds the web UI, then starts the server on port 4000.
REM ============================================================
cd /d "%~dp0"

echo [Buddy] Installing server dependencies...
call npm --prefix server install || goto :err

echo [Buddy] Installing web dependencies...
call npm --prefix web install || goto :err

echo [Buddy] Building the web UI...
call npm --prefix web run build || goto :err

echo.
echo [Buddy] Starting Buddy on http://localhost:4000
echo [Buddy] On your phone, open http://YOUR-LAN-IP:4000
echo.
call npm --prefix server run start
goto :eof

:err
echo.
echo [Buddy] Something went wrong. See the message above.
pause
