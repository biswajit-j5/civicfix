@echo off
setlocal
cd /d "%~dp0"
title CivicFix - Local Development Server

echo.
echo  ======================================
echo          CIVICFIX LOCAL STARTER
echo  ======================================
echo.

where node >nul 2>nul
if errorlevel 1 (
  echo [ERROR] Node.js is not installed or is not on PATH.
  echo Install Node.js 22 LTS from https://nodejs.org/en/download
  echo Then close and reopen this window.
  pause
  exit /b 1
)

where npm >nul 2>nul
if errorlevel 1 (
  echo [ERROR] npm was not found. Reinstall Node.js with npm included.
  pause
  exit /b 1
)

echo [1/2] Checking and installing project dependencies...
if not exist "node_modules\vite\bin\vite.js" (
  call npm install
  if errorlevel 1 (
    echo.
    echo [ERROR] npm install failed. Check your internet connection and read the error above.
    pause
    exit /b 1
  )
) else (
  echo Dependencies already appear to be installed.
)

echo.
echo [2/2] Starting CivicFix...
echo When Vite prints a Local URL, open it in your browser.
echo Keep this window open while you use CivicFix.
echo.
call npm run dev
if errorlevel 1 (
  echo.
  echo [ERROR] CivicFix stopped with an error. Read the output above.
)
pause
