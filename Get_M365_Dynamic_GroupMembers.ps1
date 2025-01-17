Connect-MgGraph

$members = Get-MGGroupMember -groupID "08f0abc3-5a60-45fc-9191-ffc7546b7b32" -All -ConsistencyLevel eventual

$readableMembers = @()


ForEach ($member in $members)
{
    $readableMembers +=   Get-MGUser -userid $member.ID | select-object -Property "DisplayName","UserPrincipalName","Department","OfficeLocation" 
}

$readableMembers | Sort-Object -Property "DisplayName" | Export-CSV -path "C:\Temp\2024_05_01_Midwest_Office_Members.csv"