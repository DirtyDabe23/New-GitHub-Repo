$evapcoPrograms = Get-AppxPackage  | Where-Object {($_.publisher -like "*Evapco*")}
$installed = $false
ForEach ($evapcoProgram in $evapcoPrograms)
{
    Set-Location $evapcoProgram.installLocation
    If (Test-path ".\Copilot.exe")
    {
            $Installed = $true
            Write-Output "Detected CoPilot"
            IF ($evapcoProgram.Version -lt "1.2024.11106.101")
            {
            Write-Output "Version is Lower, removing."
            Remove-AppXPackage -Package $evapcoProgram 
                If(!(Test-Path "C:\Temp"))
                {
                    New-Item -Type Directory -Path "C:\Temp"
                }
                Else
                {
                    Write-Output "Temp Directory Exists"
                }
            
            While (Get-AppXPackage $evapcoProgram.Name)
            {
                Write-Output "Waiting for Removal"
                Start-Sleep -Seconds 5
            }
            
            Write-Output "Installing New Version"
            invoke-webrequest -uri "https://copilot.evapco.com/CoPilot.Client/CoPilot.Package.appinstaller" -OutFile C:\Temp\CoPilot.Package.AppInstaller
            Add-AppXPackage -AppInstallerFile "C:\Temp\CoPilot.Package.appinstaller" 
            Start-Sleep -seconds 10
            Write-Output "Updated"
            Start-Sleep -seconds 10
            }
    Else{
        Write-Output "Up to Date"
    }
    }

}

If (!($installed))
{
    Write-Output "Not installed but required"
    If(!(Test-Path "C:\Temp"))
    {
        New-Item -Type Directory -Path "C:\Temp"
    }
    Else
    {
        Write-Output "Temp Directory Exists"
    }
    Write-Output "Installing New Version"
    invoke-webrequest -uri "https://ci-copilot.evapco.com/CoPilot.Client/CoPilot.Package.appinstaller" -OutFile C:\Temp\CoPilot.Package.AppInstaller
    Add-AppXPackage -AppInstallerFile "C:\Temp\CoPilot.Package.appinstaller" 
    Start-Sleep -seconds 10
    Write-Output "Updated"
}
Exit 0
