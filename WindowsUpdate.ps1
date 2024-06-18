$GetOSVersion = (Get-ComputerInfo).OSDisplayVersion


if ($GetOSVersion -ne "23H2") {
    Write-Host "[!] PSWindowsUpdate Modul wird installiert..." -ForegroundColor Yellow
    Install-Module PSWindowsUpdate -Force -Confirm:$false
    try {
        Import-module PSWindowsUpdate -ErrorAction Stop
        Write-Host "[!] PSWindowsupdate Modul wurde installiert" -ForegroundColor Green
    } catch {
        write-Host "[!] PSWindowsUpdate Modul konnte nicht installiert werden" -ForegroundColor Red
    }
    write-host "[+] Updates werden nun installiert...`n" -ForegroundColor Green
    Install-WindowsUpdate -AcceptAll -ForceInstall -AutoReboot

} else {

    $scriptPath = "C:\Script\WindowsReset.ps1"
    $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-NoProfile -NoLogo -WindowStyle Normal -File `"$scriptPath`""
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -TaskName "AutoFactoryReset" -Description "At Startup The System will reset to Factory defaults"
    Start-Sleep 5
    Restart-Computer
}
