while ($true){
    Start-Sleep 1
    if ((Get-ScheduledTask -TaskName WindowsUpdate).State){
        continue
        write-host "[+] WindowsUpdate Task is Running" -ForegroundColor Green
    } else {
        write-host "[+] WindowsUpdate Task isn't Running" -ForegroundColor Red
    }
}