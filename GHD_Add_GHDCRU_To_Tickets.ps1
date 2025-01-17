$allStartTime = Get-Date 
$pageCount = 1

#Jira
$jiraText = "david.drosdick@evapco.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeaders = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}



# Initialize variables
$ticketsMatching = @()
$uriTemplate = "https://evapco.atlassian.net/rest/api/2/search?jql=project=GHD&startAt={0}"

# Retrieve total issue count
$total = (Invoke-RestMethod -Method Get -Uri ($uriTemplate -f 0) -Headers $jiraHeaders).total

# Process issues in batches
for ($count = 0; $count -lt $total; $count += 50) {
    $uri = $uriTemplate -f $count
    $issues = Invoke-RestMethod -Method Get -Uri $uri -Headers $jiraHeaders
    $issuePageStartTime = Get-Date 

    foreach ($issue in $issues.issues) {
        $ticketNum = $issue.key
        $form = Invoke-RestMethod -Method Get -Uri "https://evapco.atlassian.net/rest/api/2/issue/$ticketNum" -Headers $jiraHeaders
        If ($null -eq $form.fields.customfield_10002.requesttype.name)
        {
            $GHDCRT = "Null"
        }
        Elseif ($form.fields.customfield_10002.requesttype.name.contains(" "))
        {
            $GHDCRT = ($form.fields.customfield_10002.requesttype.name).replace(" ","-")
 
        }
        else{
            $GHDCRT = ($form.fields.customfield_10002.requesttype.name)   
        }
        $payload = @{
        "update" = @{
            "customfield_10945" = @(@{
                "add" = "$GHDCRT"
            })
        }
    }
    $jsonPayload = $payload | ConvertTo-Json -Depth 10

    Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$($ticketNum)?notifyUsers=false" -Method Put -Body $jsonPayload -Headers $jiraHeaders
    }
    $issuePageEndTime = Get-Date
    $issuePageNetTime = $issuePageEndTime - $issuePageStartTime
    $currTime = Get-Date -format "HH:mm"
    $issuePageProcess = "Jira Issue Page Review"
    Write-Output "[$($currTime)] | Time taken for [$issuePageProcess : Page $pageCount] to complete: $($issuePageNetTime.hours) hours, $($issuePageNetTime.minutes) minutes, $($issuePageNetTime.seconds) seconds"
    $pagecount++
}

# Export the results
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | Time taken for [GHD Customer Request Type Adds] to complete: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
