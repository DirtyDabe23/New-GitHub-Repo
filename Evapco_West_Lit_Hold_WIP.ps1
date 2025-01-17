Clear-Host 
$process = "Evapco West Litigation Hold"
#Sets the PowerShell Window Title
$host.ui.RawUI.WindowTitle = $process
#Clears the Error Log
$error.clear()
#This WMI Query gets a ton of rich information about the endpoint
$computerInfo = Get-computerInfo -Property *  | select-object -Property *

#File Creation Objects
$shareLoc = "$env:Temp"
$logFileName = "$($process).txt"
$errorLogCSV = "$($process).csv"
$dateTime = Get-Date -Format yyyy.MM.dd.HH.mm
$exportPath = $shareLoc+$dateTime+"."+$logFileName
$errorExportPath = $shareLoc+$dateTime+"."+$errorLogCSV
Start-Transcript -Path $exportPath

#Error Logging
$errorLog = @()
$errorDetails = $null



#Log Timing For the Full Process Start
$allStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] | Starting"


######################################################### FUNCTIONS START HERE#######################################################
    #Log Timing For Individual Functions and their standard function
    $procStartTime = Get-Date 
    $currTime = Get-Date -format "HH:mm"
    $procProcess = "Applying Holds"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"

    #Standard Try Catch Block
    $allMailboxes = Get-Mailbox -Filter "(Office -eq 'EVAPCO West')" -ResultSize unlimited | select * | Sort-OBject -Property DisplayName
    foreach ($mailbox in $allMailboxes)
    {
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] Modifying: $($mailbox.DisplayName) / $($mailbox.guid)"
        If ($mailbox.isInactiveMailbox -eq $False)
        {
            try{
                Set-Mailbox -identity $mailbox.guid -LitigationHoldEnabled $True -ErrorAction Stop -whatif | Out-Null
            }
            catch{
                try{
                    New-ComplianceSearch -name "$($mailbox.guid)-LITHOLD" -exchangelocation ".$($mailbox.PrimarySmtpAddress)" -AllowNotFoundExchangeLocationsEnabled $true -IncludeUserAppContent $true -IncludeOrgContent $true -errorAction Stop -whatif | Out-Null
                }
                Catch
            {
                $errorDetails = $error[0] | Select *
                $currTime = Get-Date -format "HH:mm"
                $errorLog += [PSCustomObject]@{
                    processFailed                           = $procProcess
                    timeToFail                              = $currTime
                    emailFailed                             = $mailbox.PrimarySmtpAddress
                    emailGUID                               = $mailbox.GUID 
                    reasonFailed                            = $errorDetails
                }
                
            }
    
            }
        }
        else
        {
            try{
                Set-Mailbox -identity $mailbox.guid -LitigationHoldEnabled $True -ErrorAction Stop -whatif | Out-Null
            }
            catch{
                try{
                New-ComplianceSearch -name "$($mailbox.guid)-LITHOLD" -exchangelocation ".$($mailbox.PrimarySmtpAddress)" -AllowNotFoundExchangeLocationsEnabled $true -IncludeUserAppContent $true -IncludeOrgContent $true -errorAction Stop -whatif | Out-Null
                }
                Catch
            {
                $errorDetails = $error[0] | Select *
                $currTime = Get-Date -format "HH:mm"
                $errorLog += [PSCustomObject]@{
                    processFailed                           = $procProcess
                    timeToFail                              = $currTime
                    emailFailed                             = $mailbox.PrimarySmtpAddress
                    emailGUID                               = $mailbox.GUID 
                    reasonFailed                            = $errorDetails

   
                }
                
            }
    
            }
        }
    
    }
    
    #Function Ends
    $procEndTime = Get-Date
    $procNetTime = $procEndTime - $procStartTime
    $currTime = Get-Date -format "HH:mm"
    Write-Output "[$($currTime)] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"

######################################################### FUNCTIONS END HERE ########################################################

######################################################### NON TERMINATING ERROR CHECK ###############################################
$procStartTime = Get-Date 
$currTime = Get-Date -format "HH:mm"
$procProcess = "Error Review"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Starting"
if ($null -eq $errorDetails)
{
    if ($error.count -gt 0)
    {
        ForEach ($event in $error)
        {
            $errorDetails = $event| Select *
              $errorLog += [PSCustomObject]@{
                processFailed                           = $procProcess
                timeToFail                              = $currTime
                reasonFailed                            = $errorDetails 
                emailFailed                             = $mailbox.PrimarySmtpAddress
                emailGUID                               = $mailbox.GUID 
            }
        }
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] Non-Terminating Error Details Below:`n"
        Write-Output $errorLog
        $errorLog | Export-CSV -Path $errorExportPath
    }
    else
    {
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] There were No Errors!`n"
    }
}
Else{
        $currTime = Get-Date -format "HH:mm"
        Write-Output "[$($currTime)] | [$process] | [$procProcess] Error Details Below:`n"
        Write-Output $errorLog
        $errorLog | Export-CSV -Path $errorExportPath

}
$procEndTime = Get-Date
$procNetTime = $procEndTime - $procStartTime
$currTime = Get-Date -format "HH:mm"
Write-Output "[$($currTime)] | [$process] | [$procProcess] Completed in: $($procNetTime.hours) hours, $($procNetTime.minutes) minutes, $($procNetTime.seconds) seconds"


######################################################### FINAL END HERE ########################################################
$currTime = Get-Date -format "HH:mm"
$allEndTime = Get-Date 
$allNetTime = $allEndTime - $allStartTime
Write-Output "[$($currTime)] | [$process] | Time taken for [$process] Completed in: $($allNetTime.hours) hours, $($allNetTime.minutes) minutes, $($allNetTime.seconds) seconds"
Stop-Transcript
Write-Output "The Full Error Log is available as a csv at $errorExportPath"