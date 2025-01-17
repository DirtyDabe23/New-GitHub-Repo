function Get-EvapcoUser{
    <#
    .SYNOPSIS
    This function will allow you to search a local domain, graph, or both, for the user information.
    
    .DESCRIPTION
    This function will allow you to search a local domain, graph, or both, for the user information.
    
    .PARAMETER Graph
    Requires runnning Connect-MgGraph and the permissions for User.Read.All
    It will search the graph tenant by UPN to look for the user.
    
    .PARAMETER LocalAD
    Requires a connection to a local domain, used to review the user as they exist on the specified domain controller.
    
    .PARAMETER UserPrincipalName
    The user's UserPrincipalName
    
    .EXAMPLE
    #Get the User Data from Graph
    Get-EvapcoUser -UserPrincipalName "David.Drosdick@evapco.com" -Graph
   
    .EXAMPLE 
    #Get the User Data from the Local Domain 'Evapco.com'
    Get-EvapcoUser -UserPrincipalName "David.Drosdick@evapco.com" -LocalAD -Domain "Evapco.com"
    
    .EXAMPLE 
    #Get the User Data from the Local Domain 'Evapco.com' and from Graph
    Get-EvapcoUser -UserPrincipalName "David.Drosdick@evapco.com" -Full -Domain "Evapco.com" 
    
    .NOTES
    General notes
    #>
    [CmdletBinding(DefaultParameterSetName = 'Full')]
    param(
        #This Parameter is available to all sets
        [Parameter(Mandatory = $True,Position = 0)]
        [string]$UserPrincipalName,
        #This Parameter is available only the the Graph Set
        [Parameter(ParameterSetName = 'Graph',Position = 1,Mandatory)]
        [switch]$Graph,
        #This Parameter is available only to the Domain Set
        [Parameter(ParameterSetName = 'Domain',Position = 1,Mandatory)]
        [switch]$LocalAD,
        [Parameter(ParameterSetName = 'Full', Position = 1)]
        [switch]$Full,
        #This Parameter is only available to the All and Domain Set
        [Parameter(ParameterSetName = 'Full',Mandatory = $True, Position = 2)]
        [Parameter(ParameterSetName = 'Domain',Mandatory = $True, Position = 2)]
        [string]$Domain
    )
    switch ($PSCmdlet.ParameterSetName){
        'Graph' {
            Get-MgUser -userid $UserPrincipalName | Select-Object *
        }
        'LocalAD'{
            Get-ADUser -Filter "UserPrincipalName -eq '$UserPrincipalName'" -properties * -Server $Domain -erroraction SilentlyContinue
        }
        'Full'{
            Get-ADUser -Filter "UserPrincipalName -eq '$UserPrincipalName'" -properties * -Server $Domain -erroraction SilentlyContinue
            Get-MgUser -userid $UserPrincipalName | Select-Object *
        }
    }
}
