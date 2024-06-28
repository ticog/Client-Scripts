$GetOSVersion = (Get-ComputerInfo).OSDisplayVersion
$PSexecLink = "https://download.sysinternals.com/files/PSTools.zip"
Start-Transcript -Path C:\WindowsUpdate.log
if ($GetOSVersion -ne "23H2") {
    Write-Host "[!] PSWindowsUpdate Modul wird installiert..." -ForegroundColor Yellow
    Install-Module PSWindowsUpdate -Force -Confirm:$false
    try {
        Import-module PSWindowsUpdate -ErrorAction Stop
        Write-Host "[!] PSWindowsupdate Modul wurde installiert" -ForegroundColor Green
    } catch {
        write-Host "[!] PSWindowsUpdate Modul konnte nicht installiert werden" -ForegroundColor Red
    }
    Start-Sleep 5
    Install-WindowsUpdate -AcceptAll -IgnoreReboot -Confirm:$false
    
    if ((Get-WURebootStatus -silent) -eq "True"){
        Restart-Computer
        Stop-Transcript
    }
    
    while ($true) {
        Get-WUList > C:\Updates.txt
        if ((Get-Content C:\Updates.txt | Select-String "23H2").Matches.Value -eq "23H2"){ 
            Write-Host "[!] 23H2 gefunden!"
            $kb = ((Get-Content C:\Updates.txt | Select-String ".*23H2").Matches.Value | Select-String "KB[0-9]+").Matches.Value
            write-host "[+] Updates werden nun installiert...`n" -ForegroundColor Green
            Install-WindowsUpdate -KBArticleID $kb -ForceInstall -Confirm:$false -AutoReboot
            break
        } else { 
            Start-Sleep 300
        }
    }

    if ((Get-WUHistory | Select-Object title | Select-String -AllMatches "Windows 11, version 23H2").Matches.Value){
        Restart-Computer
        Stop-Transcript
    } else {
        start-process powershell.exe -Argument "-Command `"[console]::beep(1000, 100)`""
    }

} elseif ($GetOSVersion -eq "23H2") {
    Invoke-WebRequest -UseBasicParsing -Uri $PSexecLink -OutFile "C:\Windows\Temp\psexec.zip"
    Expand-Archive "C:\Windows\Temp\psexec.zip" "C:\Script\"
    Start-Process -FilePath "C:\Script\psexec.exe" -ArgumentList "-accepteula", "-S powershell.exe", "-File `"C:\Script\WindowsReset.ps1`""
}