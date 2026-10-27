#Requires -Version 5.1
<#
.SYNOPSIS
Installs the Windows tools required by the Agent 365 SDK labs.
.EXAMPLE
.\Install-SdkRequirements.ps1 -IncludePython -IncludeNode
.EXAMPLE
.\Install-SdkRequirements.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [switch]$IncludePython,
    [switch]$IncludeNode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-Checked {
    param([string]$Command, [string[]]$Arguments)

    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "'$Command $($Arguments -join ' ')' failed (exit code $LASTEXITCODE). Check the configured package sources and any installer diagnostics above."
    }
}

function Update-SessionPath {
    # Installers update the persistent PATH, not this running PowerShell process.
    $paths = @(
        [Environment]::GetEnvironmentVariable('Path', 'Machine')
        [Environment]::GetEnvironmentVariable('Path', 'User')
        $env:PATH
        (Join-Path $env:USERPROFILE '.dotnet\tools')
    )
    $env:PATH = ($paths | Where-Object { $_ }) -join ';'
}

function Test-ToolVersion {
    param([string]$Command, [string[]]$Arguments, [version]$Minimum)

    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        return $false
    }
    $output = & $Command @Arguments 2>&1
    if ($LASTEXITCODE -ne 0) {
        return $false
    }
    foreach ($line in $output) {
        if ("$line" -match '(\d+\.\d+(?:\.\d+)?)' -and [version]$Matches[1] -ge $Minimum) {
            return $true
        }
    }
    return $false
}

function Install-WindowsPackage {
    param([string]$Id)

    if ($PSCmdlet.ShouldProcess($Id, 'Install using configured WinGet sources')) {
        if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
            throw 'WinGet is required. Install or update App Installer through your organization-approved channel, then rerun this script.'
        }
        Invoke-Checked winget @('install', '--id', $Id, '--exact', '--silent', '--disable-interactivity')
        Update-SessionPath
    }
}

function Test-Python {
    if (Test-ToolVersion python @('--version') ([version]'3.12')) {
        return $true
    }
    return (Test-ToolVersion py @('-3.12', '--version') ([version]'3.12'))
}

function Test-DotNetSdk {
    if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
        return $false
    }
    $sdks = & dotnet --list-sdks 2>&1
    return ($LASTEXITCODE -eq 0 -and [bool]($sdks -match '^10\.'))
}

function Test-AgentCli {
    if (-not (Get-Command a365 -ErrorAction SilentlyContinue)) {
        return $false
    }
    $null = & a365 -h 2>&1
    return ($LASTEXITCODE -eq 0)
}

try {
    if ($env:OS -ne 'Windows_NT') {
        throw 'This installer supports Windows only.'
    }

    if (-not (Test-ToolVersion pwsh @('--version') ([version]'7.0'))) {
        Install-WindowsPackage 'Microsoft.PowerShell'
    }
    if (-not (Test-DotNetSdk)) {
        Install-WindowsPackage 'Microsoft.DotNet.SDK.10'
    }
    if (-not (Test-ToolVersion git @('--version') ([version]'0.0'))) {
        Install-WindowsPackage 'Git.Git'
    }
    if (-not (Test-ToolVersion az @('version', '--output', 'json') ([version]'0.0'))) {
        Install-WindowsPackage 'Microsoft.AzureCLI'
    }
    if ($IncludePython) {
        if (-not (Test-Python)) {
            Install-WindowsPackage 'Python.Python.3.12'
        }
        if (-not (Test-ToolVersion uv @('--version') ([version]'0.0'))) {
            Install-WindowsPackage 'astral-sh.uv'
        }
    }
    if ($IncludeNode -and -not (Test-ToolVersion node @('--version') ([version]'20.10'))) {
        Install-WindowsPackage 'OpenJS.NodeJS.LTS'
    }

    if ($PSCmdlet.ShouldProcess('Agent 365 CLI', 'Install or update the global .NET tool')) {
        $tools = & dotnet tool list --global
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not list global .NET tools.'
        }
        if ($tools -match '^\s*Microsoft\.Agents365\.CLI\s') {
            throw 'The legacy Microsoft.Agents365.CLI tool is installed. Follow the command-conflict instructions on the SDK requirements page to replace it, then rerun this script.'
        }
        $action = if ($tools -match '^\s*Microsoft\.Agents\.A365\.DevTools\.Cli\s') { 'update' } else { 'install' }
        Invoke-Checked dotnet @('tool', $action, '--global', 'Microsoft.Agents.A365.DevTools.Cli')
        Update-SessionPath
    }

    if ($PSCmdlet.ShouldProcess('Az PowerShell module (CurrentUser)', 'Install if missing, using configured PowerShell repositories')) {
        # Always install into PowerShell 7, even when launched from Windows PowerShell.
        $moduleSetup = @'
$ErrorActionPreference = 'Stop'
try {
    if (-not (Get-Module -ListAvailable Az)) {
        Install-Module -Name Az -Scope CurrentUser -ErrorAction Stop
    }
    if (-not (Get-Module -ListAvailable Az.Accounts)) {
        throw 'Az.Accounts is unavailable after installing Az.'
    }
} catch {
    Write-Error "Az installation failed. Ask your administrator to check the configured PowerShell repositories and trust settings. $($_.Exception.Message)"
    exit 1
}
'@
        Invoke-Checked pwsh @('-NoProfile', '-NonInteractive', '-Command', $moduleSetup)
    }

    if ($WhatIfPreference) {
        Write-Host 'Preview only. No packages were installed.'
        return
    }

    $checks = [ordered]@{
        'PowerShell 7+' = (Test-ToolVersion pwsh @('--version') ([version]'7.0'))
        '.NET SDK 10' = (Test-DotNetSdk)
        'Git' = (Test-ToolVersion git @('--version') ([version]'0.0'))
        'Azure CLI' = (Test-ToolVersion az @('version', '--output', 'json') ([version]'0.0'))
        'Agent 365 CLI' = (Test-AgentCli)
    }
    if ($IncludePython) {
        $checks['Python 3.12+'] = Test-Python
        $checks['uv'] = Test-ToolVersion uv @('--version') ([version]'0.0')
    }
    if ($IncludeNode) {
        $checks['Node.js 20.10+'] = Test-ToolVersion node @('--version') ([version]'20.10')
    }
    $failed = @($checks.Keys | Where-Object { -not $checks[$_] })
    if ($failed.Count -gt 0) {
        throw "Verification failed for: $($failed -join ', '). Open a new terminal and rerun the script. If this persists, check PATH and the configured package sources."
    }
    Write-Host 'SDK tools are ready. Open a new PowerShell 7 terminal before starting the lab.'
    Write-Host 'Install Agent 365 Skills for your assistant and complete the tenant, permission, and Azure OpenAI steps on the SDK requirements page.'
} catch {
    Write-Error $_
    exit 1
}
