$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$wrun = Join-Path $scriptDir "wrun.ps1"
$userBin = Join-Path $HOME ".local\bin"

if (-not ($env:Path -split ";" | Where-Object { $_ -eq $userBin })) {
    $env:Path = "$userBin;$env:Path"
}

function global:wrun {
    & $wrun @args
}

function global:python { & $wrun "python" @args }
function global:pip { & $wrun "python" "-m" "pip" @args }
function global:pytest { & $wrun "pytest" @args }
function global:node { & $wrun "node" @args }
function global:npm { & $wrun "npm" @args }
function global:npx { & $wrun "npx" @args }
function global:java { & $wrun "java" @args }
function global:javac { & $wrun "javac" @args }
function global:dotnet { & $wrun "dotnet" @args }
function global:docker { & $wrun "docker" @args }
function global:docker-compose { & $wrun "docker-compose" @args }
function global:gh { & $wrun "gh" @args }
function global:rtk { & $wrun "rtk" @args }

if ($env:WR_BRIDGE_QUIET -ne "1") {
    Write-Host "Atalhos WSL carregados para PowerShell. Exemplos: python --version, dotnet --version, docker ps, rtk gain"
}
