@echo off
cd /d "%~dp0passenger-ui"
npm install
npm run dev
pause
