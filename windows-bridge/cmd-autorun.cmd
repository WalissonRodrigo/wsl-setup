@echo off
set "USER_BIN=%USERPROFILE%\.local\bin"
if not exist "%USER_BIN%" goto :eof

echo(;%PATH%; | findstr /I /C:";%USER_BIN%;" >nul
if errorlevel 1 set "PATH=%USER_BIN%;%PATH%"
