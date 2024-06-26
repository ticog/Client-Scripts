write-host "[!] Update History:`n"
while ($true) {
    ((Get-WUHistory) | Select-Object -Last 10 Title, Result, Date) | Format-Table -AutoSize
    Start-Sleep 5
    Clear-Host
}