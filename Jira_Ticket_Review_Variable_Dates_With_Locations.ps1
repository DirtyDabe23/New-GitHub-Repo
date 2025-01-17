Clear-Host 
$process = "GIT Service Desk & Infrastructure Ticket Review"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process



#Connection to the Jira API after getting the token from the Key Vault
$vaultName = 'JiraAPI'
$apiVersion = "2020-06-01"
$resource = "https://vault.azure.net"
$endpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$resource,$apiVersion
$jiraSecretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $endpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $wwwAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($wwwAuthHeader -match "Basic realm=.+")
    {
        $jiraSecretFile = ($wwwAuthHeader -split "Basic realm=")[1]
    }
}
$jiraSecret = Get-Content -Raw $jiraSecretFile
$response = Invoke-WebRequest -Method GET -Uri $endpoint -Headers @{Metadata='True'; Authorization="Basic $jiraSecret"} -UseBasicParsing
if ($response)
{
    $jiraToken = (ConvertFrom-Json -InputObject $response.Content).access_token
}

$jiraRetrSecret = (Invoke-RestMethod -Uri "https://us-tt-vault.vault.azure.net/secrets/$($vaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $jiraToken"}).value

#Jira via the API or by Read-Host 
If ($null -eq $jiraRetrSecret)
{
    $jiraRetrSecret = Read-Host "Enter the API Key" -MaskInput
}
else {
    $null
}

#Jira Header
$jiraText = "david.drosdick@evapco.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}

[int] $numberofDays = Read-Host "Enter the number of days to review"
[int] $backDate = $numberofDays * -1
$allStartTime = Get-Date 
$backDateDate = (Get-Date).addDays($backDate)
$backDateForm = Get-Date $backDateDate -format yyyy-MM-dd
$currDate = Get-Date -format yyyy-MM-dd
Write-Output "Reviewing Days between $backDateForm and $currDate"

$pageCount = 1
# Initialize variables
$ticketsMatching = @()
$uriTemplate = "https://evapco.atlassian.net/rest/api/2/search?jql=project%20in%20(CYOPS,GHD)%20AND%20created%20%3E%3D%20$($backDate)d&startAt={0}"
# Retrieve total issue count
$total = (Invoke-RestMethod -Method Get -Uri ($uriTemplate -f 0) -Headers $headers).total
$totalPages = $total/50
If (($totalPages%1) -gt 0)
    {
    $totalPages +=1-($totalPages % 1)
    }


# Process issues in batches
for ($count = 0; $count -lt $total; $count += 50) {
    $issuePageStartTime = Get-Date 
    $uri = $uriTemplate -f $count
    $issues = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers
    foreach ($issue in $issues.issues) {
                    $ticketsMatching += [PSCustomObject]@{
                        DateCreated     = $issue.fields.created
                        TicketNumber    = $issue.key
                        Labels          = $issue.fields.labels
                        issueType       = $issue.fields.issuetype.name
                        requestType     = $issue.fields.customfield_10002.requestType.name
                        Status          = $issue.fields.status.name 
                        Summary         = $issue.fields.summary
                        Description     = $issue.fields.description
                        Assignee        = $issue.fields.assignee.displayname
                        assignEmail     = $issue.fields.assignee.emailaddress
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
$exportPath = "C:\Users\david.drosdick\Evapco, Inc\GIT IT Support - General\Reports\$(get-date -format yyyy-MM-dd)-cyops-ghd-tickets.csv"
$ticketsMatching | Export-Csv -Path $exportPath -NoTypeInformation



$AffectedEVAPCOLocations = $ticketsMatching | Sort-Object -Property AffectedEVAPCOLocation -Unique | Select-Object -Property AffectedEVAPCOLocation

$AffectedEVAPCOLocations =  $AffectedEVAPCOLocations.AffectedEVAPCOLocation | Select-Object -Unique | Sort-Object

$AffectedEVAPCOLocationsTicketCount = @()

ForEach ($AffectedEVAPCOLocation in $AffectedEVAPCOLocations)
{
   #strip the Office Location value down to the base element
   $AffectedEVAPCOLocationName = $AffectedEVAPCOLocation
   #Get the user count for the individual Given Name  
   $AffectedEVAPCOLocationNameCount = ($ticketsMatching | Where-Object {($_.AffectedEVAPCOLocation -contains $AffectedEVAPCOLocationName)}).count
   $AffectedEVAPCOLocationNameTickets = $ticketsMatching | Where-Object {($_.AffectedEVAPCOLocation -contains $AffectedEVAPCOLocationName)}

   $affectedEVAPCOLocationNameTicketsCustomerRequestTypes = $AffectedEVAPCOLocationNameTickets| Sort-Object -Property requestType -Unique | Select-Object -Property requestType
   
   ForEach ($affectedEVAPCOLocationNameTicketsCustomerRequestType in $affectedEVAPCOLocationNameTicketsCustomerRequestTypes.RequestType)
   {
        $AffectedEvapcoLocationNameTicketCustomerRequestTypeAssignees = $AffectedEVAPCOLocationNameTickets | Where-Object {($_.RequestType)} | Sort-Object -Property Assignee -Unique | Select-Object -Property Assignee

        ForEach ($AffectedEvapcoLocationNameTicketCustomerRequestTypeAssignee in $AffectedEvapcoLocationNameTicketCustomerRequestTypeAssignees.Assignee)
        {
            
                #Write-Output "Affected EVAPCO Location Name:$AffectedEVAPCOLocationName `nRequest Type: $affectedEVAPCOLocationNameTicketsCustomerRequestType `nAssignee:  $AffectedEvapcoLocationNameTicketCustomerRequestTypeAssignee"
                $AELNTCRTA = $TicketsMatching | Where-Object {($_.AffectedEvapcoLocation -contains $AffectedEVAPCOLocationName) -and ($_.RequestType -eq $affectedEVAPCOLocationNameTicketsCustomerRequestType) -and ($_.Assignee -eq $AffectedEvapcoLocationNameTicketCustomerRequestTypeAssignee)}
                

                
                Switch ($AffectedEVAPCOLocationName){
                $null{
                $AffectedEVAPCOLocationName = "Unknown"
                }
                }

                Switch ($affectedEVAPCOLocationNameTicketsCustomerRequestType){
                        $null{
                        $affectedEVAPCOLocationNameTicketsCustomerRequestType = "SubTask"
                        }
                        }
                
                Switch ($affectedEVAPCOLocationNameTicketsCustomerRequestType){
                $null{
                $affectedEVAPCOLocationNameTicketsCustomerRequestType = "SubTask"
                }
                }

                $AELNTCRTACount = $AELNTCRTA.Count
                Switch ($AELNTCRTACount){
                        $null{
                            $AELNTCRTACount = 0
                        }
                        }
                
                Switch ($AffectedEvapcoLocationNameTicketCustomerRequestTypeAssignee){
                        $null{
                        $AffectedEvapcoLocationNameTicketCustomerRequestTypeAssignee = "Automation for Jira"
                        }
                        }
                        
                
                If ($AELNTCRTACount -ne 0)
                {
                #Add it into the PSCustomObject 
                $AffectedEVAPCOLocationsTicketCount += [PSCustomObject]@{
                        LocationName       = $AffectedEVAPCOLocationName
                        RequestType        =  $affectedEVAPCOLocationNameTicketsCustomerRequestType
                        Assignee = $AffectedEvapcoLocationNameTicketCustomerRequestTypeAssignee
                        AssigneeCount = $AELNTCRTACount
                        }
                }


        }
   


   }
     

}
Write-Output "The list of all tickets created by Affected EVAPCO Location, by Assignee, By Count, in the past $numberofDays days:`n"
$AffectedEVAPCOLocationsTicketCount = $AffectedEVAPCOLocationsTicketCount | sort-object -Property  @{Expression = "AssigneeCount"; Descending = $True}, @{Expression = "LocationName"; Descending = $True} , @{Expression = "Assignee"; Descending = $False} , @{Expression = "RequestType"; Descending = $False}
$AffectedEVAPCOLocationsTicketCount| Out-Host


$evapcoLocations = $ticketsMatching | Sort-Object -Property AffectedEVAPCOLocation -Unique | Select-Object -Property AffectedEVAPCOLocation

$baseAffectedEVAPCOLocations =  $evapcoLocations.AffectedEVAPCOLocation | Select-Object -Unique | Sort-Object

$locationTicketCount = @()


ForEach ($baseAffectedEVAPCOLocations in $baseAffectedEVAPCOLocations)
{
   #strip the Office Location value down to the base element
   $baseAffectedEVAPCOLocationsName = $baseAffectedEVAPCOLocations
   #Get the user count for the individual Given Name  
   $AffectedEVAPCOLocationNameCount = ($ticketsMatching | Where-Object {($_.AffectedEVAPCOLocation -contains $baseAffectedEVAPCOLocationsName)}).count
   #Add it into the PSCustomObject 
   Switch ($AffectedEVAPCOLocationName){
   $null{
    $AffectedEVAPCOLocationName = "Unknown"
    }
    }
   $locationTicketCount += [PSCustomObject]@{
        AffectedLocationName        = $baseAffectedEVAPCOLocationsName 
        Count                       = $AffectedEVAPCOLocationNameCount
        }
     

}
Write-Output "The list of all tickets created by EVAPCO Location in the past $numberofDays days:`n"
$locationTicketCount = $locationTicketCount | sort-object -Property Count -Descending 
$locationTicketCount | Out-Host



$assignees = $ticketsMatching | Sort-Object -Property Assignee -Unique | Select-Object -Property Assignee


$assigneeTicketCount = @()

ForEach ($assignee in $assignees)
{
   #strip the Office Location value down to the base element
   $gName = $assignee.Assignee
   #Get the user count for the individual Given Name  
   $gNameCount = ($ticketsMatching | Where-Object {($_.Assignee -eq $gName) -and $($_.DateFinished -ne $null)}).count
   #Add it into the PSCustomObject
   Switch ($gName){
    $null{
     $gName = "Automation for Jira"
     }
     } 
   $assigneeTicketCount += [PSCustomObject]@{
        Assignee       = $gName 
        CompletedTickets = $gNameCount
        }
     

}
Write-Output "The list for all tickets created within the past $numberofDays days that were closed:`n"
$assigneeTicketCount = $assigneeTicketCount | sort-object -Property CompletedTickets -Descending 
$assigneeTicketCount | Out-Host


#Filtering out for Security Tickets.
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
   Switch ($gName){
    $null{
     $gName = "Automation for Jira"
     }
     }
   $standardAssigneeTicketCount += [PSCustomObject]@{
        Assignee       = $gName 
        CompletedTickets = $gNameCount
        }
     

}
Write-Output "The list for all non-security tickets created in the past $numberofDays days that were closed:`n"
$standardAssigneeTicketCount = $standardAssigneeTicketCount | sort-object -Property CompletedTickets -Descending
$standardAssigneeTicketCount | Out-Host



$requestTypes = $ticketsMatching | Sort-Object -Property requestType -Unique | Select-Object -Property requestType


$requestTypeTicketCount = @()

ForEach ($requestType in $requestTypes)
{
   #strip the Office Location value down to the base element
   $requestTypeName = $requestType.requestType
   #Get the user count for the individual Given Name  
   $requestTypeNameCount = ($ticketsMatching | Where-Object {($_.requestType -eq $requestTypeName)}).count
   #Add it into the PSCustomObject 
   Switch ($requestTypeName){
   $null{
    $requestTypeName = "Sub-Task"
    }
    }
   $requestTypeTicketCount += [PSCustomObject]@{
        RequestType       = $requestTypeName 
        Count = $requestTypeNameCount
        }
     

}
Write-Output "The list of all tickets created by Request Type:`n"
$requestTypeTicketCount = $requestTypeTicketCount | sort-object -Property Count -Descending 
$requestTypeTicketCount| Out-Host




$requestTypeTicketCountCompleted = @()

ForEach ($requestType in $requestTypes)
{
   #strip the Office Location value down to the base element
   $requestTypeName = $requestType.requestType
   #Get the user count for the individual Given Name  
   $requestTypeNameCount = ($ticketsMatching | Where-Object {($_.requestType -eq $requestTypeName) -and $($_.DateFinished -ne $null)}).count
   #Add it into the PSCustomObject
   Switch ($requestTypeName){
    $null{
     $requestTypeName = "Sub-Task"
     }
     } 
   $requestTypeTicketCountCompleted += [PSCustomObject]@{
        RequestType       = $requestTypeName 
        Count = $requestTypeNameCount
        }
     

}
Write-Output "The list for all tickets created in the past $numberofDays days that were closed:`n"
$requestTypeTicketCountCompleted =  $requestTypeTicketCountCompleted | sort-object -Property Count -Descending 
$requestTypeTicketCountCompleted | Out-Host

Write-Output "Your CSV of the total ticket overview is located at: $exportPath"