$bridgeDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$wrunCmd = Join-Path $bridgeDir "wrun.cmd"
$userBin = Join-Path $HOME ".local\bin"

if (Test-Path -LiteralPath $userBin) {
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Process")
    if (-not (($currentPath -split ";") -contains $userBin)) {
        $env:Path = "$userBin;$currentPath"
    }
}

function global:wrun {
    & $wrunCmd @args
}

function global:python {
    & $wrunCmd python @args
}

function global:pip {
    & $wrunCmd python -m pip @args
}

function global:pytest {
    & $wrunCmd pytest @args
}

function global:node {
    & $wrunCmd node @args
}

function global:npm {
    & $wrunCmd npm @args
}

function global:npx {
    & $wrunCmd npx @args
}

function global:java {
    & $wrunCmd java @args
}

function global:javac {
    & $wrunCmd javac @args
}

function global:dotnet {
    & $wrunCmd dotnet @args
}

function global:docker {
    & $wrunCmd docker @args
}

function global:docker-compose {
    & $wrunCmd docker-compose @args
}

function global:gh {
    & $wrunCmd gh @args
}

function global:rtk {
    & $wrunCmd rtk @args
}
