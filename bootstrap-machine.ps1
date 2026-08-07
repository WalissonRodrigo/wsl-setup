param(
    [string]$Distro = "Ubuntu",
    [switch]$ValidateOnly
)

$ErrorActionPreference = "Stop"

function Test-IsAdministrator {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Convert-WindowsPathToWsl {
    param([string]$WindowsPath)

    $fullPath = [System.IO.Path]::GetFullPath($WindowsPath)
    $drive = $fullPath.Substring(0, 1).ToLowerInvariant()
    $rest = $fullPath.Substring(2).Replace('\', '/')
    return "/mnt/$drive$rest"
}

function Get-InstalledDistros {
    $distros = & wsl.exe -l -q 2>$null
    return @($distros | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoWslPath = Convert-WindowsPathToWsl -WindowsPath $repoRoot
$bootstrapWslScript = "$repoWslPath/wsl-setup/bootstrap-workspace.sh"
$installBridgeScript = Join-Path $repoRoot "windows-bridge\install-global.ps1"

if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) {
    throw "WSL nao esta disponivel neste Windows. Atualize o sistema antes de continuar."
}

$distros = Get-InstalledDistros

if ($distros -notcontains $Distro) {
    if (-not (Test-IsAdministrator)) {
        throw "A distro '$Distro' ainda nao esta instalada. Execute este script como Administrador para instalar o WSL2 e a distro automaticamente."
    }

    Write-Host "Instalando WSL2 e a distro '$Distro'..."
    & wsl.exe --install -d $Distro
    Write-Host ""
    Write-Host "Se o Windows solicitar reinicializacao, reinicie a maquina."
    Write-Host "Depois abra o Ubuntu uma vez para criar o usuario Linux e reexecute este script."
    exit 0
}

if (Test-IsAdministrator) {
    & wsl.exe --set-version $Distro 2 | Out-Null
}

try {
    $probe = & wsl.exe -d $Distro -- bash -lc "echo WSL_READY"
} catch {
    $probe = $null
}

if ($probe -notcontains "WSL_READY") {
    throw "A distro '$Distro' existe, mas ainda nao esta pronta para automacao. Abra o Ubuntu uma vez, finalize a criacao do usuario Linux e reexecute o script."
}

if ($ValidateOnly) {
    Write-Host "Validacao concluida: WSL, distro '$Distro', caminho do repositorio e instalador do bridge estao acessiveis."
    Write-Host "Repo WSL path: $repoWslPath"
    exit 0
}

Write-Host "Provisionando ambiente dentro do WSL..."
& wsl.exe -d $Distro --cd $repoWslPath -- bash $bootstrapWslScript

Write-Host "Aplicando windows-bridge global..."
powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installBridgeScript

Write-Host ""
Write-Host "Provisionamento concluido."
Write-Host "Feche e reabra PowerShell, CMD e Git Bash antes de usar os comandos."
