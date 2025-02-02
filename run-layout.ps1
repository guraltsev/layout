$taskName = "Layout"
$command = "$PSScriptRoot\layout.exe"


function Test-IsAdmin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function CreateAdminTask{
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $action = New-ScheduledTaskAction -Execute $command 
    $principal = New-ScheduledTaskPrincipal -UserId $currentUser -LogonType Interactive -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    $task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings 
    try {
        Register-ScheduledTask -TaskName $taskName -InputObject $task -ErrorAction Stop
    }
    catch {
        Write-Output "Failed to create the task '$taskName'. Error: $_"
		# Read-Host -Prompt "Press any key to continue"
        throw
        exit 
    }
    Write-Output "The task '$taskName' has been created successfully."
}

function CreateUserTask{
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $action = New-ScheduledTaskAction -Execute $command
    $principal = New-ScheduledTaskPrincipal -UserId $currentUser -LogonType Interactive 
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    $task = New-ScheduledTask -Action $action -Principal $principal -Settings $settings 
    try {
        Register-ScheduledTask -TaskName $taskName -InputObject $task -ErrorAction Stop
    }
    catch {
        Write-Output "Failed to create the task '$taskName'. Error: $_"
		# Read-Host -Prompt "Press any key to continue"
        throw
        exit 
    }
    Write-Output "The task '$taskName' has been created successfully."
}


# If the task does not exist, create it.
$taskExists = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
if ( -not $taskExists) {
    if ((Test-IsAdmin)) {
        Write-Output "Creating task $taskName"
        Write-Output "$taskName will have highest privileges"
        CreateAdminTask
    }
    else { 
        Write-Output "Creating task $taskName"
        Write-Output "$taskName will have user privileges"
        CreateUserTask
        }
}
else {    
    Write-Output "Task $taskName exists already."
    if ((Test-IsAdmin)) {
        Write-Output "Replacing $taskName to have highest privileges"
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        CreateAdminTask
    }
}

Write-Output "Launching task $taskName"
Start-ScheduledTask -TaskName $taskName
# Read-Host -Prompt "Press any key to continue"
