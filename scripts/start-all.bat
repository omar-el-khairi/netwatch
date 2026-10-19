@echo off
echo Demarrage backend...
start "NetWatch Backend" cmd /k "cd /d %~dp0..\backend && npm run dev"
timeout /t 3 /nobreak >nul
echo Demarrage dashboard...
start "NetWatch Dashboard" cmd /k "cd /d %~dp0..\dashboard && npm run dev"
timeout /t 2 /nobreak >nul
echo Demarrage agent...
start "NetWatch Agent" cmd /k "cd /d %~dp0..\agents && python agent.py"
echo OK — Backend :4000 | Dashboard :5173 | Agent actif
