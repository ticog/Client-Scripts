Install-Module PSWindowsUpdate -Force -Confirm:$false
Start-Sleep 5
import-module PSWindowsUpdate

# Define the path to your script
$scriptPath = "$env:HOMEPATH\Desktop\Client-Scripts\Test.ps1"
# Create a new scheduled task action
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$scriptPath`""
# Create a new scheduled task trigger for logon
$trigger = New-ScheduledTaskTrigger -AtLogOn
# Define the principal (user) for whom the task will run
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
# Create the scheduled task
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "LogonScript" -Description "Run script at logon"

$Update = (Get-WindowsUpdate -Title ".*23H2").KB

if ($Update) {
    write-host "[+] 23H2 Update wurde gefunden`n" -ForegroundColor Green
    write-host "[+] Wird nun installiert...`n" -ForegroundColor Green
    Install-WindowsUpdate -KBArticleID $Update -Hide -ForceInstall -AutoReboot
} else {
    continue
}

Restart-Computer