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
$allStartTime = Get-Date
# Initialize variables
$ticketsMatching = @()

[int]$numberOfDays = Read-Host -Prompt "Enter the number of days back to check"
$uriTemplate = "https://evapco.atlassian.net/rest/api/2/search?jql=project%20IN%20(%22GIT%20Cyber%20Ops%20Agile%20Board%22%2C%22GIT%20Help%20Desk%22%2C%22GIT%20Procurement%22)%20and%20resolutiondate%20%3E%3D%20startOfDay(-$numberofDays)%20and%20resolutiondate%20%3C%3D%20now()&startAt={0}"
[int]$pageCount = "1"

# Retrieve total issue count
$total = (Invoke-RestMethod -Method Get -Uri ($uriTemplate -f 0) -Headers $headers).total
$totalPages = $total/50
If (($totalPages%1) -gt 0)
    {
    $totalPages +=1-($totalPages % 1)
    }


# Process issues in batches
for ($count = 0; $count -lt $total; $count += 50) {
    $uri = $uriTemplate -f $count
    $issues = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    $issuePageStartTime = Get-Date 

    foreach ($issue in $issues.issues) {
                    $ticketsMatching += [PSCustomObject]@{
                        DateCreated  = $issue.fields.created
                        TicketNumber = $issue.key
                        Labels       = $issue.fields.labels
                        issueType    = $issue.fields.issuetype.name
                        Status       = $issue.fields.status.name 
                        Summary      = $issue.fields.summary
                        Description  = $issue.fields.description
                        Assignee     = $issue.fields.assignee.displayname
                        assignEmail  = $issue.fields.assignee.emailaddress
                        reporterDisplayName = $issue.fields.reporter.displayName
                        reporterEmailAddress = $issue.fields.reporter.emailaddress
                        DateFinished   = $issue.fields.resolutiondate
                        AffectedEvapcoLocation = $issue.fields.customfield_10923.value
                    }

    }
    $issuePageEndTime = Get-Date
    $issuePageNetTime = $issuePageEndTime - $issuePageStartTime
    $currTime = Get-Date -format "HH:mm"
    $issuePageProcess = "Jira Issue Page Review"
    Write-Output "[$($currTime)] | [Total Issuge Pages: $($totalPages)] | Time taken for [$issuePageProcess : Page $pageCount] to complete: $($issuePageNetTime.hours) hours, $($issuePageNetTime.minutes) minutes, $($issuePageNetTime.seconds) seconds"
    $pagecount++
}

# Export the results
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | Time taken for [Infrastructure Ticket Audit] to complete: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
$exportPath = "\\evapcousers\departments\public\Tech-Items\scriptLogs\$(get-date -format YYYY-MM-DD)-cyops-ghd-last-$numberOfDays-days-tickets.csv"
If (Test-Path -Path $exportPath)
{
$ticketsMatching | Export-Csv -Path $exportPath -NoTypeInformation
}
$assignees = $ticketsMatching | Sort-Object -Property Assignee -Unique | Select-Object -Property Assignee


$assigneeTicketCount = @()

ForEach ($assignee in $assignees)
{
   #strip the Office Location value down to the base element
   $gName = $assignee.Assignee
   #Get the user count for the individual Given Name  
   $gNameCount = ($ticketsMatching | Where-Object {($_.Assignee -eq $gName) -and $($_.DateFinished -ne $null)}).count
   #Add it into the PSCustomObject 
   $assigneeTicketCount += [PSCustomObject]@{
        Assignee       = $gName 
        CompletedTickets = $gNameCount
        }
     

}
Write-Output "The list for all tickets completed in the past $numberOfDays days:`n"

$assigneeTicketCount | sort-object -Property CompletedTickets -Descending

$badLabels = "QuarantineRelease","PhishingReport","SecurityEvent","Incident, PhishingReport"
$standardTickets = $ticketsMatching | Where-Object {($_.Labels -notin $badLabels)}
$assignees = $standardTickets  | Sort-Object -Property Assignee -Unique | Select-Object -Property Assignee


$standardAssigneeTicketCount = @()

ForEach ($assignee in $assignees)
{
   #strip the Office Location value down to the base element
   $gName = $assignee.Assignee
   #Get the user count for the individual Given Name  
   $gNameCount = ($standardTickets | Where-Object {($_.Assignee -eq $gName) -and $($_.DateFinished -ne $null)}).count
   #Add it into the PSCustomObject 
   $standardAssigneeTicketCount += [PSCustomObject]@{
        Assignee       = $gName 
        CompletedTickets = $gNameCount
        }
     

}
Write-Output "`n`nAll Completed Non-Security Tickets in the past $numberOfDays days:`n`n"
$standardAssigneeTicketCount | sort-object -Property CompletedTickets -Descending


# Export the results
$exportPath = "\\evapcousers\departments\public\Tech-Items\scriptLogs\$(get-date -format YYYY-MM-DD)-non-security-cyops-ghd-last-$numberOfDays-days-tickets.csv"
If (Test-Path -Path $exportPath)
{
$ticketsMatching | Export-Csv -Path $exportPath -NoTypeInformation
}
