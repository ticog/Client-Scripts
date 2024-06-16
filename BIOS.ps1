param (
    [switch]$UpdateBios = $false,
    [string]$Password
    )
Clear-Host
write-host
# ======================================================================================================================
# ----------------------------------------------------- Banner ---------------------------------------------------------
# ======================================================================================================================
"
##################===================================##################
##########====================================================#########
#########    _______________________________________________  #########
#######     |     < Adullam FAT Clients BIOS Script >       |   #######
#######     |     <                                  >      |   #######
#######     |     <              Mai 2024            >      |   #######
#######     |_______________________________________________|   #######
#########                                                     #########
##########====================================================#########
##################===================================##################
"
# ======================================================================================================================
# ----------------------------------------- Admin und Lenovo Check, falls nein -> exit 1 -------------------------------
# ======================================================================================================================
 
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Oh oh! Bist du Admin?" -ForegroundColor Red
    Stop-Transcript
    Set-ExecutionPolicy Default
    clear-history
    exit 1
}
 
$GetManufacturer = (get-computerinfo).CsManufacturer
if ($GetManufacturer -ne "LENOVO") {
    Write-Host "Der Hersteller: $GetManufacturer` wird bei diesem Script nicht unterstützt."
    Stop-Transcript
    Set-ExecutionPolicy Default
    clear-history
    exit 1
}
 
# ======================================================================================================================
# ----------------------------------------------------- LOG ------------------------------------------------------------
# ======================================================================================================================
 
$timestamp = Get-Date -Format "dd/MM/yy"
$LogFile = "D:\LOGS\$timestamp"+ "_" +  (Get-ComputerInfo).BiosSeralNumber + ".log"
Start-Transcript -Path $LogFile | out-null                                          # Transcript Init
Write-Host "["(Get-Date -Format "HH:MM:ss")"]" " Start des Scripts"
 
# =======================================================================================================================
# --------------------------------------------- BIOS Update Block -------------------------------------------------------
# =======================================================================================================================
 
if ($UpdateBios) {
    Write-Host "BIOS Update Flagge gesetzt. Pruefe nach Internet verbindung..." -ForegroundColor Yellow
    $Internet, $null = Test-Connection -ComputerName "google.com" -ErrorAction Stop -Quiet                      # Checkt ob google erreichbar ist
    if ($Internet) {
        $Format = (Get-Date -Format "HH:MM:ss")
        Write-Host "[$Format] [!] Internet verbindung wurde erfolgreich hergestellt..." -ForegroundColor Green
        Write-Host "[$Format] LSU Client wird nun installiert..." -ForegroundColor Yellow                      
        Install-Module -Name LSUClient -Confirm:$False -Force                                                   # LSU Client für BIOS Update
        sleep 5
        Install-PackageProvider -name NuGet -MinimumVersion 2.8.5.201 -Force
		sleep 5
		Import-Module LSUClient
        Write-Host "[$Format] Es wird nach Updates gesucht..." -ForegroundColor Yellow
        $Biosupdate = Get-LSUpdate | ? {                                                                        # Array mit den Updates, wobei es nur nach BIOS Updates gesucht wird
            $_.Type -eq "BIOS"
        }
        if ($Biosupdate) {                                                                                      # Gefundene Updates werden installiert
            Install-LSUpdate -Package $Biosupdate
            Stop-Transcript
            Set-ExecutionPolicy Default
            clear-history
            exit 1
        } else {
            Write-Host "[$Format] Es wurden keine neuen Updates gefunden`n`n" -ForegroundColor Yellow
            Stop-Transcript
            Set-ExecutionPolicy Default
            clear-history
            exit 1
        }
    } elseif (-not $Internet) {
        Write-Host "[$Format]`n[!] Verbindung zum Internet konnte nicht hergestellt werden.`nSomit kann auch kein BIOS Update statt finden." -ForegroundColor Red
        Stop-Transcript
        Set-ExecutionPolicy Default
        clear-history
        exit 1
    }
}
 
# =======================================================================================================================
# ------------------------------ Checkt ob das durchgegebene Passwort im BIOS richtig ist -------------------------------
# =======================================================================================================================
 
if ($Password) {
    $PasswortSettings = gwmi -Namespace root\wmi -Class Lenovo_BiosPasswordSettings
    if ($PasswortSettings.PasswordState -ne "0"){                                                           # Passwords States unter https://thinkdeploy.blogspot.com/2018/06/reporting-bios-password-states-on-think.html
        $checkPass = (gwmi -Class Lenovo_WmiOpcodeInterface -Namespace root\wmi).WmiOpcodeInterface("WmiOpcodePasswordAdmin:$Password")
        if ($checkPass.Return -ne "Success") {
            write-Host "Etwas ist schief gelaufen beim Passwort: " $checkPass.Return -ForegroundColor Red
            Stop-Transcript
            Set-ExecutionPolicy Default
            clear-history
            exit 1
        }
        Write-Host "`n[!] Passwort erfolgreich validiert." -ForegroundColor Green
        }
}
 
# =======================================================================================================================
# -------------------------------------- Hier werden die Einstellungen eingestellt --------------------------------------
# =======================================================================================================================
 
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("TrackPoint,Disable") | ForEach-Object {
    Write-Host "TrackPoint:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("SpeedStep,Enable") | ForEach-Object {
    Write-Host "SpeedStep:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("AdaptiveThermalManagementAC,Balanced") | ForEach-Object {
    Write-Host "AdaptiveThermalManagementAC:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("AdaptiveThermalManagementBattery,Balanced") | ForEach-Object {
    Write-Host "AdaptiveThermalManagementBattery:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("LockBIOSSetting,Enable") | ForEach-Object {
    Write-Host "LockBIOSSetting:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("MinimumPasswordLength,10") | ForEach-Object {
    Write-Host "MinimumPasswordLength:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("BIOSPasswordAtBootDeviceList,Enable") | ForEach-Object {
    Write-Host "BIOSPasswordAtBootDeviceList:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("BIOSUpdateByEndUsers,Disable") | ForEach-Object {
    Write-Host "BIOSUpdateByEndUsers:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("BluetoothAccess,Disable") | ForEach-Object {
    Write-Host "BluetoothAccess:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("MicrophoneAccess,Disable") | ForEach-Object {
    Write-Host "MicrophoneAccess:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("FingerprintReaderAccess,Disable") | ForEach-Object {
    Write-Host "FingerprintReaderAccess:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("ThunderboltAccess,Enable") | ForEach-Object {
    Write-Host "ThunderboltAccess:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("Allow3rdPartyUEFICA,Enable") | ForEach-Object {
    Write-Host "Allow3rdPartyUEFICA:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("ThinkShieldPasswordlessPowerOnAuthentication,Disable") | ForEach-Object {
    Write-Host "ThinkShieldPasswordlessPowerOnAuthentication:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("BootDeviceListF12Option,Disable") | ForEach-Object {
    Write-Host "BootDeviceListF12Option:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("BootOrder,NVMe0") | ForEach-Object {
    Write-Host "BootOrder:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("BootOrderLock,Enable") | ForEach-Object {
    Write-Host "BootOrderLock:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("LenovoCloudServices,Disable") | ForEach-Object {
    Write-Host "LenovoCloudServices:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("StrongPassword,Enable") | ForEach-Object {
    Write-Host "StrongPassword:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("KeyboardLayout,Swiss") | ForEach-Object {
    Write-Host "KeyboardLayout:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting('PCIeTunneling,Disable') | ForEach-Object {
    Write-Host "PCIeTunneling:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting('UserDefinedAlarmMonday,Enable') | ForEach-Object {
    Write-Host "UserDefinedAlarmMonday:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting('UserDefinedAlarmTuesday,Enable') | ForEach-Object {
    Write-Host "UserDefinedAlarmTuesday:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting('UserDefinedAlarmWednesday,Enable') | ForEach-Object {
    Write-Host "UserDefinedAlarmWednesday:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting('UserDefinedAlarmThursday,Enable') | ForEach-Object {
    Write-Host "UserDefinedAlarmThursday:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting('UserDefinedAlarmFriday,Enable') | ForEach-Object {
    Write-Host "UserDefinedAlarmFriday:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting('UserDefinedAlarmTime,07:00:00') | ForEach-Object {
    Write-Host "UserDefinedAlarmTime:" $_.return -ForegroundColor Yellow
}
$null = (gwmi -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting('WakeUponAlarm,UserDefined') | ForEach-Object {
    Write-Host "UserDefinedAlarmTime:" $_.return -ForegroundColor Yellow
}
 
# =======================================================================================================================
# ----------------------------------------- Einstellungen werden hier gespeichert ---------------------------------------
# =======================================================================================================================
 
(gwmi -Class Lenovo_WmiOpcodeInterface -Namespace root\wmi).WmiOpcodeInterface("WmiOpcodePasswordAdmin:$Password") | out-null
$SettingsSaved = gwmi -class Lenovo_SaveBiosSettings -namespace root\wmi
 
$SettingsSaved.SaveBiosSettings() | ForEach-Object {
    if ($_.return -eq "Success") {
    Write-Host "Einstellungen wurden erfolgreich gespeichert" -ForegroundColor Green
    Write-Host "`nNach einem Neustart werden sie uebernommen."
} else {
    Write-Host "Einstellungen konnten nicht gespeichert werden`n`nBIOS Passwort (richtig) eingegeben?" -ForegroundColor Red
    }
}
 
<#
======================================================================
                        ↓ AUF KEINEN FALL ÄNDERN! ↓
            Setzt die ExecutionPolicy Einstellung wieder auf Default,
                  damit Powershell scripts nicht ausführbar
                          gemacht werden können.
======================================================================
#>
 
Set-ExecutionPolicy Default
clear-history
$ExecPolicy = Get-ExecutionPolicy
Write-Host "Current ExecutionPolicy: $ExecPolicy" -ForegroundColor DarkRed
Uninstall-Module LSUClient

try {Stop-Transcript} catch {"`r"}