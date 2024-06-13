Clear-Host
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Oh oh! Bist du Admin?" -ForegroundColor Red
    exit 1
}

# Macht sicher dass es die TLS version 1.2 verwendet
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Geht auf den folgenden Pfad
$Path = "C:" + $env:HOMEPATH + "\Desktop"
Set-Location -Path $Path
# Fügt den Pfad, in der Umgebungsvariable zu den Paths (damit die ausserhalb der Pfade ebenfalls ausgeführt werden können)
$env:Path += ";C:\Program Files\WindowsPowerShell\Scripts"
# bla bla das kennen wir
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
# Selbsterklärend
Install-Script -Name Get-WindowsAutopilotInfo -Force
# Generiert somit die CSV Datei und Speichert sie als {$NAME} in $Path
$serialnumber = (Get-ComputerInfo).BiosSeralNumber
$filename = $serialnumber + ".csv"
$null = Get-WindowsAutopilotInfo -OutputFile "$filename"

if (Get-ChildItem -Path $Path | findstr.exe $filename) {
    Write-Host "`n[+] Die Datei befindet sich unter $Path\$filename" -ForegroundColor Green -BackgroundColor Black
}