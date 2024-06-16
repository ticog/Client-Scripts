# necessary registry keys to run "Invoke-WebRequest" without errors
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name 'IE5_UA_Backup_Flag' -Value 5
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -Name 'User Agent' -Value 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3'
# Installiert winget, welches verwendet wird um Git zu installieren
$path = "C:\Windows\Temp"
$URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
$URL = (Invoke-WebRequest -UseBasicParsing -Uri $URL).Content | ConvertFrom-Json |
        Select-Object -ExpandProperty "assets" |
        Where-Object "browser_download_url" -Match '.msixbundle' |
        Select-Object -ExpandProperty "browser_download_url"

Invoke-WebRequest -Uri $URL -OutFile "$path\winget-setup.msix" -UseBasicParsing
Add-AppxPackage -Path "$path\winget-setup.msix"
Remove-Item "$path\winget-setup.msix"
# Installiert git durch winget
Start-Process "winget.exe" -ArgumentList "install --id Git.Git -e --source winget --verbose"
# Kontrolliert ob git installiert ist
if (git --version | findstr.exe ".*git version"){
    Write-Host "[+] Git wurde installiert durch winget" -ForegroundColor Green
} else {
    Write-Host "[!] Git konnte nicht installiert werden" -ForegroundColor Red
}

Write-Host "[!] Git Repo wird nun kopiert auf $path" -ForegroundColor Green
git clone "https://github.com/ticog/Client-Scripts.git" "$path\Client-Scripts"
Write-Host "[!] Es wird nun mit Windows Updates fortgefahren, bitte schalte das Geraet NICHT ab!" -ForegroundColor Green
powershell.exe -File "$path\Client-Scripts\WindowsUpdate.ps1"
