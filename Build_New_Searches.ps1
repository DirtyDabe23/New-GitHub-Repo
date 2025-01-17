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

$fieldName = Read-Host "Enter the name of the Field to review here"

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
        $fieldValues = Invoke-RestMethod -Method Get -Uri $uriTemplate -Headers $headers
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
    $reviewedFieldValues    
}
else
{
    Write-Output "Field Name not found"
}

$filterAPIURI = 'https://evapco.atlassian.net/rest/api/3/filter'
$Locations = ($reviewedFieldValues | Where-Object {($_.OptionID -eq $null)}).value
[PSCustomObject] $Filters = @()

ForEach ($location in $Locations)
{
    $nameDescription = "GHD - All $location Open Tickets"
    $JQL = "resolution = Unresolved AND (""Affected EVAPCO Locations[Select List (multiple choices)]"" = ""$location"" OR ""Office Location and Department[Select List (cascading)]"" = ""$location"") AND statusCategory != Done ORDER By Created Desc"
    
    $payload = @{
        "description" = ($nameDescription)
        "jql" = $JQL
        "name" = $nameDescription
    }
    
    
    
    $jsonPayload = $payload | ConvertTo-Json -Depth 10
    
    # Log payload for debugging
    Write-Output "Payload (JSON): $jsonPayload"
    
    
    
    # Make the PUT request
    $response = Invoke-RestMethod -Uri $filterAPIURI -Method POST -Body $jsonPayload -Headers $jiraHeaders
}





#Apply Permissions from a known good filter

$goodPermsFilter = $filterAPIURI+'/10928'
$response = Invoke-RestMethod -Uri $goodPermsFilter -Method GET -Headers $jiraHeaders
$perms = $response.sharePermissions


$filterAPIURI = 'https://evapco.atlassian.net/rest/api/3/filter'
$filterID = '10915'

$requestURI = $filterAPIURI + '/' + $filterID

$response = Invoke-RestMethod -Uri $requestURI -Method PUT -Headers $jiraHeaders