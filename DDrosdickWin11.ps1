Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
#This script downloads and runs a file process determined by the url variable.

#Variable Declaration
#$URL= Download Link
$url = "https://go.microsoft.com/fwlink/?linkid=2165884"

$Path = "C:\Scripts"
$output = "C:\Scripts\USMTADK.exe"
$start_time = Get-Date

if (!(Test-Path $Path))
{
New-Item -itemType Directory -Path C:\ -Name Scripts
}
else
{
write-host "Folder already exists"
}


#Downloads the file specified
Write-Output "Time Of Process Start: $start_time"
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
Invoke-WebRequest -Uri $url -OutFile $output
Write-Output "Time taken for Download: $((Get-Date).Subtract($start_time).Seconds) second(s)"
$start_time=Get-Date

#Runs the utility from Downlaod
start-process $output -ArgumentList "/features optionid.userstatemigrationtool" , "/q"

Write-Output "Time taken to Install USMT: $((Get-Date).Subtract($start_time).Seconds) second(s)"


# Restore the Classic Taskbar in Windows 11
# Disable Taskbar / Cortana Search Box on Windows 11
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -PropertyType DWord -Value "00000000";
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value "00000000";
# Ungroup Taskbar Icons / Enable Text Labels in Windows 11
New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoTaskGrouping" -PropertyType DWord -Value "00000001";
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoTaskGrouping" -Value "00000001";

#Sets Icon Size to Small
Set-Location -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
New-ItemProperty -Path ".\" -Name "TaskBarSi" -value "0" -PropertyType 'DWORD' -Force




#Fixes Error with Windows Start
New-ItemProperty -Path ".\" -Name "EnableXamlStartMenu" -value "0" -PropertyType 'DWORD' -Force
winget install powertoys --ID XP89DCG3K6VLD --accept-package-agreements --accept-source-agreements -h
winget install "classic shell"
winget install "brave"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name TaskbarAl -Type 'DWORD' -Value '0'
mkdir C:\Scripts\BackupMenu -Force
mkdir C:\Scripts\BackupMenu\Current -Force
mkdir C:\Scripts\BackupMenu\Old -Force

Invoke-WebRequest -Uri "https://drive.google.com/uc?id=1xtNbi_ypQiBJqy23Egh29mbZl2S45Ba5&export=download"  -OutFile C:\Win11Setup.zip
Expand-Archive -Path C:\Win11setup.zip -DestinationPath C:\


Start-Process -FilePath "C:\Program Files\Classic Shell\ClassicExplorerSettings.exe" -ArgumentList "-backup C:\Scripts\BackupMenu\Old\ExplorerSettings.xml"
Start-Process -FilePath "C:\Program Files\Classic Shell\ClassicStartMenu.exe" -ArgumentList "-backup C:\Scripts\BackupMenu\Old\StartMenuSettings.xml"


Start-Process -FilePath "C:\Program Files\Classic Shell\ClassicExplorerSettings.exe" -ArgumentList "-xml C:\Scripts\BackupMenu\Current\ExplorerSettings.xml"
Start-Process -FilePath "C:\Program Files\Classic Shell\ClassicStartMenu.exe" -ArgumentList "-xml C:\Scripts\BackupMenu\Current\StartMenuSettings.xml"

New-Item "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
New-Item "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
Set-ItemProperty -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Name "(Default)" -Value $null



#Makes changes Live
Get-Process explorer | Stop-Process

#Installs PS7
Invoke-WebRequest  "https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/PowerShell-7.2.4-win-x64.msi" -Outfile C:\Scripts\PS7.msi
Start-Process C:\Scripts\PS7.msi -ArgumentList "/qn"

#Updates all applications compatible with WinGet
winget upgrade --all

#Runs Windows Updates
Install-Module -Name PSWindowsUpdate -Force
Install-WindowsUpdate -AcceptAll -Download -Install -AutoReboot
