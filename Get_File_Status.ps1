cls
while (!(Test-Path "C:\Temp\")){
    Write-Output "Waiting for C:\Temp"
    Start-Sleep -Seconds 5
}

while (!(Test-Path "C:\Temp\CoPilot.Package.AppInstaller"))
{
    Write-Output "Waiting for CoPilot.Package.AppInstaller"
    Start-Sleep -Seconds 5
}
Get-Item "C:\Temp\CoPilot.Package.AppInstaller" | select "*Time*"