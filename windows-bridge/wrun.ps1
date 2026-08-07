param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$CommandArgs
)

$ErrorActionPreference = "Stop"

function Convert-WindowsPathToWsl {
    param([string]$WindowsPath)

    $fullPath = [System.IO.Path]::GetFullPath($WindowsPath)
    $drive = $fullPath.Substring(0, 1).ToLowerInvariant()
    $rest = $fullPath.Substring(2).Replace('\', '/')
    return "/mnt/$drive$rest"
}

if (-not $CommandArgs -or $CommandArgs.Count -eq 0) {
    throw "Informe o comando a ser executado no WSL."
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$execScriptWindows = Join-Path $scriptDir "exec-in-wsl.sh"

if (-not (Test-Path -LiteralPath $execScriptWindows)) {
    throw "Arquivo nao encontrado: $execScriptWindows"
}

$workspacePath = Convert-WindowsPathToWsl -WindowsPath (Get-Location).Path
$execScriptWsl = Convert-WindowsPathToWsl -WindowsPath $execScriptWindows
$distro = if ($env:WR_WSL_DISTRO) { $env:WR_WSL_DISTRO } else { "Ubuntu" }

& wsl.exe -d $distro --cd $workspacePath -- bash $execScriptWsl @CommandArgs
exit $LASTEXITCODE
