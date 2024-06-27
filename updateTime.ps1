Start-Transcript -Path "C:\"
Start-Sleep 300
$time = get-date -Format hh:mm:ss
$user = whoami.exe

while ($true) {
    if ($user -like "*system*"){
        exit 1
    }
    if ((Get-ScheduledTask -TaskName "WindowsUpdate").state -eq "Ready"){
        Start-ScheduledTask -TaskName "WindowsUpdate"
        Write-Output "$time" "$((Get-ScheduledTask -TaskName "WindowsUpdate").state)" >> "C:\winup.txt"
    } elseif ((Get-ScheduledTask -TaskName "WindowsUpdate").state -eq "Running") {
        Write-Output "$time" "$((Get-ScheduledTask -TaskName "WindowsUpdate").state)" >> "C:\winup.txt"
    }
}