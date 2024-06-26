Start-Transcript -Path "C:\"
Start-Sleep 300
$time = get-date -Format hh:mm:ss
while ($true) {
    if ((Get-ScheduledTask -TaskName "WindowsUpdate").state -eq "Ready"){
        Start-ScheduledTask -TaskName "WindowsUpdate"
        Write-Output "$time" "$((Get-ScheduledTask -TaskName "WindowsUpdate").state)" >> "C:\winup.txt"
    } elseif ((Get-ScheduledTask -TaskName "WindowsUpdate").state -eq "Running") {
        Write-Output "$time" "$((Get-ScheduledTask -TaskName "WindowsUpdate").state)" >> "C:\winup.txt"
    }
}