#Connection to the Jira API after getting the token from the Key Vault
$jiraVaultName = 'JiraAPI'
$jiraAPIVersion = "2020-06-01"
$jiraResource = "https://vault.azure.net"
$jiraEndpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$jiraResource,$jiraAPIVersion
$jiraSecretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $jiraEndpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $jiraWWWAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($jiraWWWAuthHeader -match "Basic realm=.+")
    {
        $jiraSecretFile = ($jiraWWWAuthHeader -split "Basic realm=")[1]
    }
}
$jiraSecret = Get-Content -Raw $jiraSecretFile
$jiraResponse = Invoke-WebRequest -Method GET -Uri $jiraEndpoint -Headers @{Metadata='True'; Authorization="Basic $jiraSecret"} -UseBasicParsing
if ($jiraResponse)
{
    $jiraToken = (ConvertFrom-Json -InputObject $jiraResponse.Content).access_token
}

$jiraRetrSecret = (Invoke-RestMethod -Uri "https://us-tt-vault.vault.azure.net/secrets/$($jiraVaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $jiraToken"}).value

#Jira via the API or by Read-Host 
If ($null -eq $jiraRetrSecret)
{
    $jiraRetrSecret = Read-Host "Enter the API Key" -MaskInput
}
else {
    $null
}

#Jira
$jiraText = "david.drosdick@evapco.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

$Fields = Invoke-RestMethod -Method get -uri "https://evapco.atlassian.net/rest/api/2/field" -Headers $headers

$fieldName = "Office Location and Department"

$foundField = $fields | Where-Object {($_.Name -eq $fieldName)}


If ($foundField -ne $null)
{
    $reviewingField = $fields | Where-Object {($_.Name -eq $fieldName)}

    $reviewingFieldContextsAndDefaultValues = Invoke-RestMethod -Method get -uri "https://evapco.atlassian.net/rest/api/2/field/$($reviewingField.ID)/context/defaultValue" -Headers $headers


    $reviewingFieldValues = Invoke-RestMethod -Method get -uri "https://evapco.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option" -Headers $headers

    $reviewedFieldValues = @()

    If ($reviewingFieldValues.Total -ge 100)
    {
        $uriTemplate = "https://evapco.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option?&startAt={0}"

        for ($count = 0; $count -lt $reviewingFieldValues.Total; $count += 100) 
        {
            $uri = $uriTemplate -f $count
            $fieldValues = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
            ForEach ($fieldValue in $fieldValues.values)
            {
                $reviewedFieldValues += [PSCustomObject]@{
                    FieldName   = $fieldName
                    ID          = $fieldValue.ID
                    Value       = $fieldValue.Value
                    OptionID    = $fieldValue.optionID
                    Disabled    = $fieldValue.Disabled
                }
            }
        }

    }
    else 
    {
        $uriTemplate = "https://evapco.atlassian.net/rest/api/2/field/$($reviewingField.id)/context/$($reviewingFieldContextsAndDefaultValues.values.contextID)/option"
        $fieldValues = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
        ForEach ($fieldValue in $fieldValues.values)
            {
                $reviewedFieldValues+= [PSCustomObject]@{
                    FieldName   = $fieldName
                    ID          = $fieldValue.ID
                    Value       = $fieldValue.Value
                    OptionID    = $fieldValue.optionID
                    Disabled    = $fieldValue.Disabled
                }
            }
    }
}
else
{
    Write-Output "Field Name not found"
}



$userObject = @()   


$allUsers = Get-MGBetaUser -All -ConsistencyLevel eventual | Where-Object {($_.UserType -eq "member") -and ($_.AccountEnabled -eq $true) -and ($_.CompanyName -ne "Not Affiliated")} | select-object -Property "OnPremisesSyncEnabled", "ID", "DisplayName","UserPrincipalName", "CompanyName", "Country", "OfficeLocation", "Department", "Manager", "BusinessPhones", "UsageLocation"| Sort-Object -Property DisplayName

ForEach ($user in $allUsers)
{
    $userOfficeLocationFieldData = $reviewedFieldValues | Where-Object {($_.Value -eq $($user.OfficeLocation))}
    $userOfficeLocationCompliantDepartments = $reviewedFieldValues | Where-Object {($_.OptionID -eq $($userOfficeLocationFieldData.id))}
    If ($user.Department -notin $($userOfficeLocationCompliantDepartments.value))
    {
        try
        {
            $managerID = Get-MGBetaUserManager -userid $user.Id -ErrorAction Stop
            $manager = Get-MGBetaUser -userid $managerID.ID -ErrorAction Stop
            $managerOfficeLocationFieldData = $reviewedFieldValues | Where-Object {($_.Value -eq $($manager.OfficeLocation))}
            $managerOfficeLocationCompliantDepartments = $reviewedFieldValues | Where-Object {($_.OptionID -eq $($managerOfficeLocationFieldData.id))}
            If ($manager.Department -in $($managerOfficeLocationCompliantDepartments.value))
            {
                $Compliant = $True
            }
            Else 
            {
                $Compliant = $False
            }
            $userObject += [PSCustomObject]@{
                SynchingLocal               = $user.OnPremisesSyncEnabled
                ID                          = $user.ID
                DisplayName                 = $user.DisplayName
                Department                  = $user.Department
                UserPrincipalName           = $user.UserPrincipalName
                CompanyName                 = $user.CompanyName
                Country                     = $user.Country
                UsageLocation               = $user.UsageLocation
                OfficeLocation              = $user.OfficeLocation
                BusinessPhones              = $user.BusinessPhones[0]
                ManagerDisplayName          = $manager.DisplayName
                ManagerID                   = $manager.ID
                ManagerUserPrincipalName    = $manager.UserPrincipalName
                ManagerOfficeLocation       = $manager.OfficeLocation
                ManagerDepartment           = $manager.Department 
                ManagerCompliant            = $Compliant
                }   
    
        }
    catch
        {
         
        $userObject += [PSCustomObject]@{
            SynchingLocal               = $user.OnPremisesSyncEnabled
            ID                          = $user.ID
            DisplayName                 = $user.DisplayName
            Department                  = $user.Department
            UserPrincipalName           = $user.UserPrincipalName
            CompanyName                 = $user.CompanyName
            Country                     = $user.Country
            UsageLocation               = $user.UsageLocation
            OfficeLocation              = $user.OfficeLocation
            BusinessPhones              = $user.BusinessPhones[0]
            ManagerDisplayName          = "No Manager"
            ManagerID                   = "No Manager"
            ManagerUserPrincipalName    = "No Manager"
            ManagerOfficeLocation       = "No Manager"
            ManagerDepartment           = "No Manager"
            ManagerCompliant            = "No Manager"
            }


        }    
    }
    Else
    {
       $null
    }
}
