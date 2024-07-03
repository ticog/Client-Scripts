<#
Script:         Initialize.ps1
Beschreibung:   Setz die verschiedenen Komponente zusammen, um das Automatisierungsprozess starten zu können.
Autor:          Sebastian Mihut Masis
#>

# Um den Script beim Client zu starten, benutze dieser Oneliner: 
# (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ticog/Client-Scripts/main/Initialize.ps1" -UseBasicParsing).Content | powershell -c -

Clear-Host

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
New-Item -Path "C:\" -Name "Script" -ItemType Directory | out-null
Install-PackageProvider -Name Nuget -Confirm:$false -Force -ForceBootstrap | out-null
Set-executionpolicy Bypass -Confirm:$false -Force 
write-Host "[!] Execution Policy auf: $(Get-ExecutionPolicy)" -ForegroundColor Yellow

# Ladet das AutoPilot.ps1 Script und startet es
(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ticog/Client-Scripts/main/AutoPilot.ps1" -UseBasicParsing).Content | powershell -c -
write-Host "[!] AutoPilot.ps1 ausgeführt" -ForegroundColor Yellow

# Checkt die NuGet version
if (((Get-PackageProvider) | Where-Object {$_.Name -eq "NuGet"}).Name ){
    Write-Host "[+] NuGet PackageProvider ist installiert, Version: $(((Get-PackageProvider) | Where-Object {$_.Name -eq "NuGet"}).Version -replace "", "")" -ForegroundColor Green
} else {
    Write-Host "[+] NuGet PackageProvider ist NICHT installiert..." -ForegroundColor Red
}

$path = "C:\Windows\Temp"
Write-Host "[!] Github Repo wir nun unter `"$path\`" geklont" -ForegroundColor Yellow

# Klont, bzw. ladet das Zip runter und extrahierts auf das tmp Ordner
Invoke-WebRequest -uri "https://github.com/ticog/Client-Scripts/archive/refs/heads/main.zip" -OutFile "$path\Client-Scripts.zip"
Expand-Archive "$path\Client-Scripts.zip" "$path"
Copy-Item -Recurse "C:\Windows\Temp\Client-Scripts-main\*" "C:\Script\" | Out-Null

# Erstellt die Scheduled Task, welche dann bei startup das WindowsUpdate.ps1 script triggert
Write-Host "[!] Scheduled Task wird nun für das Windows Update registriert" -ForegroundColor Yellow
$scriptPath = "C:\Script\WindowsUpdate.ps1"
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$scriptPath`""
$t = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $t -Principal $principal -TaskName "WindowsUpdate" -Description "At Startup The System will Update windows to 23H2"

# War zu faul um den Namen der Datei zu ändern, jedoch checkt die Task in einem endlosen Loop ob WindowsUpdate.ps1 läuft, wenn nicht startet er es manuell
$SetDateTaskTrigger = New-ScheduledTaskTrigger -AtStartup
$SetDateTask = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File C:\Script\updateTime.ps1"
Register-ScheduledTask -Action $SetDateTask -Trigger $SetDateTaskTrigger -Principal $principal -TaskName "windowsupdatecheck" -Description "checks if windowsupdate is running"

if ("WindowsUpdate" -in (Get-ScheduledTask).TaskName) {
    Write-Host "[+] Scheduled Task wurde erstellt" -ForegroundColor Green
}

Write-Host "[!] 23H2 Cab Datei wird eingespielt" -ForegroundColor Yellow

# Cab File für 23H2, damit es das 23H2 findet
while (-not (get-childitem -Path "$path\"| Where-Object {$_.Name -eq "23H2.cab"})) {
    start-process curl -ArgumentList "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/49a41627-758a-42b7-8786-cc61cc19f1ee/public/windows11.0-kb5027397-x64_955d24b7a533f830940f5163371de45ff349f8d9.cab" , "-o C:\Windows\Temp\23H2.cab" -wait -NoNewWindow
    Start-Process -FilePath "dism.exe" -ArgumentList "/online", "/add-package", "/packagepath:C:\Windows\Temp\23H2.cab", "/NoRestart" -NoNewWindow -Wait
    Start-Sleep 5
}

Restart-Computer