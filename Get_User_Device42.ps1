$TicketNum = "GHD-30790"


If ($null -eq $d42retrSecret)
{
    $d42retrSecret = Read-Host "Enter the Device42 API Secret" -MaskInput
}

#This pulls all the end users
$device42URL = 'https://itam.evapco.com'
$apiPath = '/api/1.0/endusers/'

# Convert the username and password to a Base64 string for Basic Authentication
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("GIT_API:$d42retrSecret")))

$device42Header = @{
    "Authorization" = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}

If ($null -eq $jiraRetrSecret)
{
    $jiraRetrSecret = Read-Host "Enter the API Key" -MaskInput
}
#Jira
$jiraText = "david.drosdick@evapco.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeaders = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}




#Pull Jira Ticket Info:
#Connecting to Jira and pulling ticketing information into variables
$Issue = Invoke-RestMethod -Method get -uri "https://evapco.atlassian.net/rest/api/2/issue/$TicketNum" -Headers $jiraHeaders
$jiraUser = $issue.fields.reporter.emailaddress
$specificUser = "?email=$jiraUser"
$device42APIURL = $device42URL+$apiPath+$specificUser


$device42EndUsers = Invoke-RestMethod -Uri $device42APIURL -Method Get -Headers $device42Header

[string]$d42UserID = $device42EndUsers.values.id 
$userAffectedObject= @{
    "appKey" = "com.device42"
    "originID" = "endusers$d42UserID"
    "serializedOrigin" =  "com.device42/endusers$device42UserID"
    "value" = "com.device42/endusers$device42UserID"
}


$payload = @{
    "update" = @{
        "customfield_10792" = @(@{
            "set" = @($userAffectedObject)
        })
    }
}


$jsonPayload = $payload | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$($ticketNum)?notifyUsers=false" -Method Put -Body $jsonPayload -Headers $jiraHeaders

$device42EndUsers = (Invoke-RestMethod -Uri $apiUrl -Method Get -Headers $headers).values
