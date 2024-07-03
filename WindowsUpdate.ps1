<# 
Script:         WindowsUpdate.ps1
Beschreibung:   Dieser Script automatisiert das updaten des Windows auf die version 23H2
Autor:          Sebastian Mihut Masis
#>
$GetOSVersion = (Get-ComputerInfo).OSDisplayVersion

# Link für PSexec
$PSexecLink = "https://download.sysinternals.com/files/PSTools.zip"

# Log
Start-Transcript -Path C:\WindowsUpdate.log

# Liest von der oberigen Variable $GegOSVersion den wert ab. Liegt dieser nicht bei 23H2 machts folgendes:
if ($GetOSVersion -ne "23H2") {
    # Installiert PSWindowsupdate Modul
    Write-Host "[!] PSWindowsUpdate Modul wird installiert..." -ForegroundColor Yellow
    Install-Module PSWindowsUpdate -Force -Confirm:$false
    # Checkt ob PSWindowsUpdate installiert wurde
    try {
        Import-module PSWindowsUpdate -ErrorAction Stop
        Write-Host "[!] PSWindowsupdate Modul wurde installiert" -ForegroundColor Green
    } catch {
        write-Host "[!] PSWindowsUpdate Modul konnte nicht installiert werden" -ForegroundColor Red
    }
    Start-Sleep 5
    # Installiert die notwendigen Updates, vor 23H2
    Install-WindowsUpdate -AcceptAll -IgnoreReboot -Confirm:$false
    
    if ((Get-WURebootStatus -silent) -eq "True"){
        Stop-Transcript
        Restart-Computer
    }

    # Unendlicher Loop, bis "23H2" in der Datei C:\Updates.txt gefunden wurde. Wenn nicht 5 Minuten warten und nochmal von vorne
    while ($true) {
        Get-WUList > C:\Updates.txt
        if ((Get-Content C:\Updates.txt | Select-String "23H2").Matches.Value -eq "23H2"){ 
            Write-Host "[!] 23H2 gefunden!" 
            $kb = ((Get-Content C:\Updates.txt | Select-String ".*23H2").Matches.Value | Select-String "KB[0-9]+").Matches.Value # Liest die KB ID für das 23H2
            write-host "[+] Updates werden nun installiert...`n" -ForegroundColor Green
            Install-WindowsUpdate -KBArticleID $kb -ForceInstall -Confirm:$false -AutoReboot
            break
        } else { 
            Start-Sleep 300
        }
    }

    if ((Get-WURebootStatus -silent) -eq "True"){
        Stop-Transcript
        Restart-Computer
    }

# Falls die Windows Version 23H2 entspricht, wird das Gerät zurückgesetzt.
} elseif ($GetOSVersion -eq "23H2") {
    Invoke-WebRequest -UseBasicParsing -Uri $PSexecLink -OutFile "C:\Windows\Temp\psexec.zip"
    Expand-Archive "C:\Windows\Temp\psexec.zip" "C:\Script\"
    Start-Process -FilePath "C:\Script\psexec.exe" -ArgumentList "-accepteula", "-S powershell.exe", "-File `"C:\Script\WindowsReset.ps1`""
}