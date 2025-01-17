$evapcoPrograms = Get-AppxPackage  | Where-Object {($_.publisher -like "*Evapco*")}
$installed = $false 
ForEach ($evapcoProgram in $evapcoPrograms)
{
    Set-Location $evapcoProgram.installLocation
    If (Test-path ".\Copilot.exe"){
        $installed = $true
        Write-Output "Detected CoPilot"
        IF ($evapcoProgram.Version -lt "1.2024.11106.101"){
        Write-Output "Version is Lower"
        #Exit 1
        }
        Else{
            Write-Output "Up to Date"
        }
    }
    }
   

If (!($installed))
{
Write-Output "Not Detected"
#Exit 1
}

Else{
    Write-Output "Installed and up to date"
    #Exit 0
}
