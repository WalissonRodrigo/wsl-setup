@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0bootstrap-machine.ps1" %*
exit /b %errorlevel%
