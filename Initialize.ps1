# Um den Script beim Client zu starten, benutze dieser Oneliner: 
# (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ticog/Client-Scripts/main/Initialize.ps1" -UseBasicParsing).Content | powershell -c -

New-Item -Path "C:\" -Name "Script" -ItemType Directory

Install-PackageProvider -Name Nuget -Confirm:$false -Force -ForceBootstrap 
$path = "C:\Windows\Temp"

Invoke-WebRequest -uri "https://github.com/ticog/Client-Scripts/archive/refs/heads/main.zip" -OutFile "$path\Client-Scripts.zip"
Expand-Archive "$path\Client-Scripts.zip" "$path"

Copy-Item -Recurse "C:\Windows\Temp\Client-Scripts-main\*" "C:\Script\" | Out-Null
 
$scriptPath = "C:\Script\WindowsUpdate.ps1" | Out-Null
$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$scriptPath`"" | Out-Null
$trigger = New-ScheduledTaskTrigger -AtStartup | Out-Null
$principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest | Out-Null
Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "WindowsUpdate" -Description "At Startup The System will Update windows to 23H2" | Out-Null



Invoke-WebRequest -uri "https://catalog.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/49a41627-758a-42b7-8786-cc61cc19f1ee/public/windows11.0-kb5027397-x64_955d24b7a533f830940f5163371de45ff349f8d9.cab" -UseBasicParsing -OutFile "$path\23H2.cab"
Start-Process -FilePath "dism.exe" -ArgumentList "/online", "/add-package", "/packagepath:C:\Windows\Temp\23H2.cab", "/NoRestart" -NoNewWindow -Wait


Write-Host "[!] Es wird nun nach dem Neustart mit Windows Updates fortgefahren, bitte schalte das Geraet NICHT ab!" -ForegroundColor Green
sleep 5
Restart-Computer