# Um den Script beim Client zu starten, benutze dieser Oneliner: 
# (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ticog/Client-Scripts/main/Initialize.ps1" -UseBasicParsing).Content | powershell -c -
Clear-Host

Get-Date -Format "hh:mm"> C:\date.txt

New-Item -Path "C:\" -Name "Script" -ItemType Directory | out-null
Install-PackageProvider -Name Nuget -Confirm:$false -Force -ForceBootstrap | out-null

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Set-executionpolicy Bypass -Confirm:$false -Force
write-Host "[!] Execution Policy auf: $(Get-ExecutionPolicy)" -ForegroundColor Yellow
(Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ticog/Client-Scripts/main/AutoPilot.ps1" -UseBasicParsing).Content | powershell -c -
write-Host "[!] AutoPilot.ps1 ausgeführt" -ForegroundColor Yellow

if (((Get-PackageProvider) | Where-Object {$_.Name -eq "NuGet"}).Name ){
    Write-Host "[+] NuGet PackageProvider ist installiert, Version: $(((Get-PackageProvider) | Where-Object {$_.Name -eq "NuGet"}).Version -replace "", "")" -ForegroundColor Green
} else {
    Write-Host "[+] NuGet PackageProvider ist NICHT installiert..." -ForegroundColor Red
}

$path = "C:\Windows\Temp"
Write-Host "[!] Github Repo wir nun unter `"$path\`" geklont" -ForegroundColor Yellow

Invoke-WebRequest -uri "https://github.com/ticog/Client-Scripts/archive/refs/heads/main.zip" -OutFile "$path\Client-Scripts.zip"
Expand-Archive "$path\Client-Scripts.zip" "$path"
Copy-Item -Recurse "C:\Windows\Temp\Client-Scripts-main\*" "C:\Script\" | Out-Null

# Scheduled Task
Write-Host "[!] Scheduled Task wird nun für das Windows Update registriert" -ForegroundColor Yellow

# big brain time
# nimmt die Zeit, addiert +10 min, konvertiert sie zu einer str
$Time = ([string](Get-Date).AddMinutes(5)).Substring(10,6)
$scriptPath = "C:\Script\WindowsUpdate.ps1"
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$scriptPath`""
$t1 = New-ScheduledTaskTrigger -Daily -At $Time
$t2 = New-ScheduledTaskTrigger -Once -At $Time -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Hours 23 -Minutes 55)
$t1.Repetition = $t2.Repetition
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $t1 -Principal $principal -TaskName "WindowsUpdate" -Description "At Startup The System will Update windows to 23H2"

# Set-Date Logon
$SetDateTaskTrigger = New-ScheduledTaskTrigger -AtStartup
$SetDateTask = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-command set-date 00:00"
Register-ScheduledTask -Action $SetDateTask -Trigger $SetDateTaskTrigger -Principal $principal -TaskName "set-date" -Description "sets date to 00:00"

if ("WindowsUpdate" -in (Get-ScheduledTask).TaskName) {
    Write-Host "[+] Scheduled Task wurde erstellt" -ForegroundColor Green
}

Write-Host "[!] 23H2 Cab Datei wird eingespielt" -ForegroundColor Yellow

# Cab File für 23H2
while (-not (get-childitem -Path "$path\"| Where-Object {$_.Name -eq "23H2.cab"})) {
    start-process curl -ArgumentList "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/49a41627-758a-42b7-8786-cc61cc19f1ee/public/windows11.0-kb5027397-x64_955d24b7a533f830940f5163371de45ff349f8d9.cab" , "-o C:\Windows\Temp\23H2.cab" -wait -NoNewWindow
    Start-Process -FilePath "dism.exe" -ArgumentList "/online", "/add-package", "/packagepath:C:\Windows\Temp\23H2.cab", "/NoRestart" -NoNewWindow -Wait
    Start-Sleep 5
}

Write-Host "[!] Es wird nun nach dem Neustart mit Windows Updates fortgefahren, bitte schalte das Geraet NICHT ab!" -ForegroundColor White -BackgroundColor Red
Start-Sleep 5

Restart-Computer