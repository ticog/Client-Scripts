<#
 ____   _____  ____   _____  _____ 
|  _ \ | ____|/ ___| | ____||_   _|
| |_) ||  _|  \___ \ |  _|    | |  
|  _ < | |___  ___) || |___   | |  
|_| \_\|_____||____/ |_____|  |_|   

#>

# Aus Debug gründen, bevor ich mein eigenes Gerät komplett zurücksetze :)
Clear-Host
$seconds = 1
while ($seconds -lt 6) {
    [console]::beep(1000, 100)
    Write-Host "[!] Du versuchst nun dieses Geraet zu reseten, du hast 5 Sekunden Zeit um abzubrechen (CTRL+C)...`n" -ForegroundColor Black -BackgroundColor Red
    write-host $seconds
    Start-Sleep 1
    Clear-Host
    $seconds += 1
}
$user = whoami.exe
if ($user -like "*tico*") {
    exit 1
} elseif (-not (Get-ChildItem | findstr.exe "PSexec.exe")){
    write-host "[!] PSexec.exe ist nicht im gleichen Verzeichnis`nrtfm..." -ForegroundColor Red
}

$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_RemoteWipe"  
$methodName = "doWipeMethod"
 
$session = New-CimSession
 
$params = New-Object Microsoft.Management.Infrastructure.CimMethodParametersCollection
$param = [Microsoft.Management.Infrastructure.CimMethodParameter]::Create("param", "", "String", "In")
$params.Add($param)
 
$instance = Get-CimInstance -Namespace $namespaceName -ClassName $className -Filter "ParentID='./Vendor/MSFT' and InstanceID='RemoteWipe'"
$session.InvokeMethod($namespaceName, $instance, $methodName, $params)

