# Um den Script beim Client zu starten, benutze dieser Oneliner: 
# (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ticog/Client-Scripts/main/Initialize.ps1" -UseBasicParsing).Content | powershell -c -
Clear-Host
Write-Host "[WARNING] Script wurde gestartet. 10 Sekunden Zeit um abzubrechen!`n`n`n`n[WARNING] Um abzubrechen: CTRL + C"
Start-Sleep 10

Set-executionpolicy Bypass
write-Host "[!] Execution Policy auf: $(Get-ExecutionPolicy)" -ForegroundColor Yellow

New-Item -Path "C:\" -Name "Script" -ItemType Directory | out-null
Install-PackageProvider -Name Nuget -Confirm:$false -Force -ForceBootstrap 

if (((Get-PackageProvider) | ? {$_.Name -eq "NuGet"}).Name ){
    Write-Host "[+] NuGet PackageProvider ist installiert" -ForegroundColor Green
} else {
    Write-Host "[+] NuGet PackageProvider ist NICHT installiert..." -ForegroundColor Red
}

$path = "C:\Windows\Temp"

Write-Host "[!] Github Repo wir nun unter `"$path\`" geklont" -ForegroundColor Yellow

Invoke-WebRequest -uri "https://github.com/ticog/Client-Scripts/archive/refs/heads/main.zip" -OutFile "$path\Client-Scripts.zip"
Expand-Archive "$path\Client-Scripts.zip" "$path"

Copy-Item -Recurse "C:\Windows\Temp\Client-Scripts-main\*" "C:\Script\" | Out-Null

Write-Host "[!] Scheduled Task wird nun für das Windows Update registriert" -ForegroundColor Yellow 

$scriptPath = "C:\Script\WindowsUpdate.ps1"
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$scriptPath`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "WindowsUpdate" -Description "At Startup The System will Update windows to 23H2"

if ("WindowsUpdate" -in (Get-ScheduledTask).TaskName) {
    Write-Host "[+] Scheduled Task wurde erstellt" -ForegroundColor Green
}

Write-Host "[!] 23H2 Cab Datei wird eingespielt" -ForegroundColor Yellow

Invoke-WebRequest -uri "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/49a41627-758a-42b7-8786-cc61cc19f1ee/public/windows11.0-kb5027397-x64_955d24b7a533f830940f5163371de45ff349f8d9.cab" -UseBasicParsing -OutFile "$path\23H2.cab"
Start-Process -FilePath "dism.exe" -ArgumentList "/online", "/add-package", "/packagepath:C:\Windows\Temp\23H2.cab", "/NoRestart" -NoNewWindow -Wait


Write-Host "[!] Es wird nun nach dem Neustart mit Windows Updates fortgefahren, bitte schalte das Geraet NICHT ab!" -ForegroundColor White -BackgroundColor Red
Start-Sleep 5

Restart-Computer