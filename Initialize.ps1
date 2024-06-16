$path = "C:\Windows\Temp"

Invoke-WebRequest -uri "https://github.com/ticog/Client-Scripts/archive/refs/heads/main.zip" -OutFile "$path\Client-Scripts.zip"
Expand-Archive "$path\Client-Scripts.zip" "$path"



Write-Host "[!] Es wird nun mit Windows Updates fortgefahren, bitte schalte das Geraet NICHT ab!" -ForegroundColor Green
powershell.exe -File "$path\Client-Scripts-main\WindowsUpdate.ps1"
