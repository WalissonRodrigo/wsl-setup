param()

$ErrorActionPreference = "Stop"

$workspaceRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$bridgeDir = Join-Path $workspaceRoot "windows-bridge"
$userBin = Join-Path $HOME ".local\bin"
$wrunCmd = Join-Path $bridgeDir "wrun.cmd"
$gitBashRc = Join-Path $HOME ".bashrc"
$powerShellProfiles = @(
    $PROFILE.CurrentUserCurrentHost,
    (Join-Path $HOME "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1")
) | Select-Object -Unique
$powerShellBridgeProfile = Join-Path $bridgeDir "powershell-profile.ps1"
$cmdAutorun = Join-Path $bridgeDir "cmd-autorun.cmd"
$tools = @(
    "wrun",
    "python",
    "pip",
    "pytest",
    "node",
    "npm",
    "npx",
    "java",
    "javac",
    "dotnet",
    "docker",
    "docker-compose",
    "gh",
    "rtk"
)

function Ensure-Directory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Ensure-PathContains {
    param([string]$PathToAdd)

    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $items = @()

    if ($userPath) {
        $items = $userPath -split ";" | Where-Object { $_ -and $_.Trim() }
    }

    if ($items -notcontains $PathToAdd) {
        $newPath = @($PathToAdd) + $items
        [Environment]::SetEnvironmentVariable("Path", ($newPath -join ";"), "User")
    }
}

function Write-Wrapper {
    param(
        [string]$ToolName,
        [string]$TargetWrun
    )

    $wrapperPath = Join-Path $userBin ("{0}.cmd" -f $ToolName)
    $wrapperContent = if ($ToolName -eq "wrun") {
@"
@echo off
setlocal
call "$TargetWrun" %*
exit /b %errorlevel%
"@
    } else {
@"
@echo off
setlocal
call "$TargetWrun" $ToolName %*
exit /b %errorlevel%
"@
    }

    Set-Content -Path $wrapperPath -Value $wrapperContent -Encoding ASCII
}

function Ensure-BashrcHook {
    param([string]$BridgeDir)

    $hookStart = '# WR Systems windows-bridge'
    $hookEnd = '# /WR Systems windows-bridge'
    $hookLine = @(
        $hookStart
        'case $- in'
        "  *i*) test -f `"$BridgeDir/activate-wsl-tools.sh`" && source `"$BridgeDir/activate-wsl-tools.sh`" ;;"
        'esac'
        $hookEnd
    ) -join "`n"
    $legacyHookLine = "test -f `"$BridgeDir/activate-wsl-tools.sh`" && source `"$BridgeDir/activate-wsl-tools.sh`""
    $hookBlockPattern = "(?ms)^\Q$hookStart\E\r?\n.*?^\Q$hookEnd\E\s*"

    if (-not (Test-Path -LiteralPath $gitBashRc)) {
        New-Item -ItemType File -Path $gitBashRc -Force | Out-Null
    }

    $current = Get-Content -Path $gitBashRc -Raw
    $updated = $current

    if ($updated -match $hookBlockPattern) {
        $updated = [regex]::Replace($updated, $hookBlockPattern, "$hookLine`n")
    } elseif ($updated -match [regex]::Escape($legacyHookLine)) {
        $updated = $updated -replace [regex]::Escape($legacyHookLine), $hookLine
    }

    if ($updated -notmatch [regex]::Escape($hookLine)) {
        if ($updated.Length -gt 0 -and -not $updated.EndsWith("`n")) {
            $updated += "`n"
        }
        $updated += "$hookLine`n"
    }

    if ($updated -ne $current) {
        Set-Content -Path $gitBashRc -Value $updated -Encoding ASCII
    }
}

function Ensure-PowerShellProfile {
    param(
        [string]$ProfilePath,
        [string]$BridgeProfilePath
    )

    $hookLine = ". `"$BridgeProfilePath`""

    Ensure-Directory -Path (Split-Path -Parent $ProfilePath)

    if (-not (Test-Path -LiteralPath $ProfilePath)) {
        New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
    }

    $current = Get-Content -Path $ProfilePath -Raw
    if ($current -notmatch [regex]::Escape($hookLine)) {
        if ($current.Length -gt 0 -and -not $current.EndsWith("`n")) {
            Add-Content -Path $ProfilePath -Value ""
        }
        Add-Content -Path $ProfilePath -Value $hookLine
    }
}

function Ensure-CmdAutorun {
    param([string]$AutorunScript)

    New-Item -Path "HKCU:\Software\Microsoft\Command Processor" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Command Processor" -Name AutoRun -Value "`"$AutorunScript`""
}

function Unblock-BridgeScripts {
    param([string]$DirectoryPath)

    Get-ChildItem -Path $DirectoryPath -File -Include *.ps1,*.cmd -Recurse | ForEach-Object {
        Unblock-File -Path $_.FullName -ErrorAction SilentlyContinue
    }
}

Ensure-Directory -Path $userBin
Ensure-PathContains -PathToAdd $userBin
Unblock-BridgeScripts -DirectoryPath $bridgeDir

foreach ($tool in $tools) {
    Write-Wrapper -ToolName $tool -TargetWrun $wrunCmd
}

$driveLetter = $bridgeDir.Substring(0, 1).ToLowerInvariant()
$gitBridgeDir = "/$driveLetter" + $bridgeDir.Substring(2).Replace("\", "/")
foreach ($profilePath in $powerShellProfiles) {
    Ensure-PowerShellProfile -ProfilePath $profilePath -BridgeProfilePath $powerShellBridgeProfile
}
Ensure-BashrcHook -BridgeDir $gitBridgeDir
Ensure-CmdAutorun -AutorunScript $cmdAutorun

Write-Host "Bridge global instalado."
Write-Host "User bin: $userBin"
Write-Host "Wrappers criados para: $($tools -join ', ')"
Write-Host "Git Bash configurado para carregar o bridge automaticamente."
Write-Host "PowerShell configurado para carregar o bridge automaticamente."
Write-Host "CMD configurado com AutoRun do bridge."
Write-Host "Abra um novo PowerShell, CMD ou Git Bash para usar os comandos."
