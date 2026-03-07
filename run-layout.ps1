<# 
.SYNOPSIS
  Create/Update and start a Windows Scheduled Task that runs layout.exe.

.DESCRIPTION
  This script registers (or re-registers) a Scheduled Task and then starts it.

  Key behavior:
  - By default, the task is named "Layout" and runs "layout.exe" located next to this script.
  - If the script is run in an elevated PowerShell session, the task is configured to run with highest privileges.
  - BUG FIX: Windows Task Scheduler defaults to stopping a running task after ~72 hours ("Stop the task if it runs longer than").
    This script disables that limit by setting ExecutionTimeLimit to 0, so the process is not terminated after ~3 days.

.PARAMETER TaskName
  Name of the Scheduled Task (default: Layout).

.PARAMETER ExePath
  Full path to the executable to run (default: <script directory>\layout.exe).

.PARAMETER Force
  Recreate the task even if it already exists.

.NOTES
  - The task uses LogonType "Interactive", meaning it runs in the current user session.
    If you need it to run while logged off, change LogonType and provide credentials accordingly.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

param(
    [string]$TaskName = 'Layout',
    [string]$ExePath  = (Join-Path -Path $PSScriptRoot -ChildPath 'layout.exe'),
    [switch]$Force
)

function Test-IsAdmin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal   = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-ExecutableExists([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Executable not found: '$Path'. Place 'layout.exe' next to this script or pass -ExePath."
    }
}

function New-LayoutTaskDefinition {
    param(
        [Parameter(Mandatory)]
        [bool]$RunHighest
    )

    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name

    # Run the exe with the script directory as working directory, in case the exe expects relative files.
    $action = New-ScheduledTaskAction -Execute $ExePath -WorkingDirectory $PSScriptRoot

    $runLevel = if ($RunHighest) { 'Highest' } else { 'Limited' }
    $principal = New-ScheduledTaskPrincipal -UserId $currentUser -LogonType Interactive -RunLevel $runLevel

    # IMPORTANT: ExecutionTimeLimit = 0 disables the default 72-hour stop behavior.
    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -ExecutionTimeLimit ([TimeSpan]::Zero) `
        -MultipleInstances IgnoreNew

    return New-ScheduledTask -Action $action -Principal $principal -Settings $settings
}

function Register-OrUpdateTask {
    param(
        [Parameter(Mandatory)]
        [bool]$RunHighest
    )

    $existing = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

    if ($existing -and -not $Force -and -not $RunHighest) {
        Write-Output "Task '$TaskName' already exists. Run this script as Administrator (or pass -Force) if you need to update it."
        return
    }

    if ($existing -and ($Force -or $RunHighest)) {
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
    }

    $task = New-LayoutTaskDefinition -RunHighest:$RunHighest
    Register-ScheduledTask -TaskName $TaskName -InputObject $task | Out-Null

    if ($RunHighest) {
        Write-Output "Task '$TaskName' registered with highest privileges. Execution time limit disabled."
    } else {
        Write-Output "Task '$TaskName' registered with user privileges. Execution time limit disabled."
    }
}

# ---- Main ----
Assert-ExecutableExists -Path $ExePath

$runHighest = Test-IsAdmin
Register-OrUpdateTask -RunHighest:$runHighest

Write-Output "Starting task '$TaskName'..."
Start-ScheduledTask -TaskName $TaskName
