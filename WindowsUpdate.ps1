Install-Module PSWindowsUpdate -Force -Confirm:$false
import-module PSWindowsUpdate

$Update = (Get-WindowsUpdate -Title ".*23H2").KB

if ($Update) {
    write-host "[+] 23H2 Update wurde gefunden`n" -ForegroundColor Green
    write-host "[+] Wird nun installiert...`n" -ForegroundColor Green
    Install-WindowsUpdate -KBArticleID $Update -Hide -ForceInstall -IgnoreReboot
}