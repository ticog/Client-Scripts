Install-Module PSWindowsUpdate -Force -Confirm:$false
Start-Sleep 5
import-module PSWindowsUpdate

New-Item -Path "C:\" -Name "Script" -ItemType Directory
Copy-Item "WindowsReset.ps1" "C:\Script\WindowsReset.ps1" 
# Define the path to your script
$scriptPath = "C:\Script\WindowsReset.ps1"
# Create a new scheduled task action
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$scriptPath`""
# Create a new scheduled task trigger for logon
$trigger = New-ScheduledTaskTrigger -AtStartup
# Define the principal (user) for whom the task will run
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
# Create the scheduled task
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "AutoFactoryReset" -Description "At Startup The System will reset to Factory defaults"

write-host "[+] Updates werden nun installiert...`n" -ForegroundColor Green
Install-WindowsUpdate -AcceptAll -ForceInstall -AutoReboot

Restart-Computer