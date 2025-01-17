#$Path is the containing folder for the process.
$Path = "C:\Scripts"
if (!(Test-Path $Path))
{
New-Item -itemType Directory -Path C:\ -Name Scripts
}
else
{
write-host "Folder already exists"
}


If (Get-Module -Name "PSWindowsUpdate")
{
Write-Host "Module already installed! Beginning job."
}

else 
{
$start_time=Get-Date
Write-Host "Module not yet installed. Installing Module."
install-module pswindowsupdate -force -allowclobber | Out-File -FilePath C:\Scripts\InstalledModule.txt

}


$start_time=Get-Date
Write-Host "Time Of Windows Update Start: $start_time"

Get-WindowsUpdate
Get-WindowsUpdate | Out-File -FilePath C:\Scripts\AvailUpdates.txt
Get-WindowsUpdate | Write-Host
install-windowsupdate -acceptall -ignorereboot -NotCategory 'Driver' , 'Tool', 'Feature Pack', 'Feature Update' | Out-File -FilePath C:\Scripts\UpdateLog.txt
Write-Host "Time taken for Windows Update to Complete: $((Get-Date).Subtract($start_time).Seconds) second(s)"
$start_time=Get-Date
Write-Host "Job Completed at $start_time" 



$start_time=Get-Date
Write-Host "Starting 3rd Party Update at: $start_time" 
WinGet List | WinGet Upgrade --All --Force --Accept-Package-Agreements --Accept-Source-Agreements --Silent | Out-File C:\Scripts\WinGetStatus.txt
Write-Host "Time taken for 3rd Party Updates to Complete: $((Get-Date).Subtract($start_time).Seconds) second(s)"