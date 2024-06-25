$time = get-date -Format hh:mm 
while ($true) {
    if ((Get-ScheduledTask -TaskName "WindowsUpdate").state -eq "Ready"){
        Start-ScheduledTask -TaskName "WindowsUpdate"
    } elseif ((Get-ScheduledTask -TaskName "WindowsUpdate").state -eq "Running") {
        write-Host "$time" "$((Get-ScheduledTask -TaskName "WindowsUpdate").state)"
    }
}