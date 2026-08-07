@echo off
setlocal
set "WRUN=%~dp0wrun.cmd"
set "USER_BIN=%USERPROFILE%\.local\bin"

echo ;%PATH%; | find /I ";%USER_BIN%;" >nul
if errorlevel 1 set "PATH=%USER_BIN%;%PATH%"

doskey wrun=%WRUN% $*
doskey python=%WRUN% python $*
doskey pip=%WRUN% python -m pip $*
doskey pytest=%WRUN% pytest $*
doskey node=%WRUN% node $*
doskey npm=%WRUN% npm $*
doskey npx=%WRUN% npx $*
doskey java=%WRUN% java $*
doskey javac=%WRUN% javac $*
doskey dotnet=%WRUN% dotnet $*
doskey docker=%WRUN% docker $*
doskey gh=%WRUN% gh $*
doskey rtk=%WRUN% rtk $*

if /I not "%WR_BRIDGE_QUIET%"=="1" echo Atalhos WSL carregados para CMD. Exemplos: python --version, dotnet --version, docker ps, rtk gain
endlocal
