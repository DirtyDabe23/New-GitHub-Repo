function Get-EvapcoUser{
    <#
    .SYNOPSIS
    Short description
    
    .DESCRIPTION
    Long description
    
    .PARAMETER Graph
    Parameter description
    
    .PARAMETER LocalAD
    Parameter description
    
    .PARAMETER UserPrincipalName
    Parameter description
    
    .EXAMPLE
    An example
    
    .NOTES
    General notes
    #>
    [CmdletBinding()]
    param(
        [bool]$Graph=$true,
        [bool]$LocalAD=$true,
        [Parameter(Mandatory)]
        [string]$UserPrincipalName
    )
    If($graph)
    {
        Get-MgUser -userid $UserPrincipalName | Select-Object *
    }
    if ($localAD)
    {
        Get-ADUser -Filter "UserPrincipalName -eq '$UserPrincipalName'" -properties * -erroraction SilentlyContinue
    }
    Else
    {
        Write-Output "No Valid Selection"
    }
}