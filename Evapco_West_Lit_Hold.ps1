$failedMailboxes = @()
$allMailboxes = Get-Mailbox -Filter "(Office -eq 'EVAPCO West')" -ResultSize unlimited | select *
foreach ($mailbox in $allMailboxes)
{
    If ($mailbox.isInactiveMailbox -eq $False)
    {
        try{
            Set-Mailbox -identity $mailbox.guid -LitigationHoldEnabled $True -ErrorAction Stop
        }
        catch{
            try{
            New-ComplianceSearch -sourceMailboxes $mailbox.guid -AllowNotFoundExchangeLocationsEnabled $true -IncludeUserAppContent $true -IncludeOrgContent $true
            }
            catch{
                $errorDeets = $error[0] | select *
                $failedMailboxes += [PSCustomObject]{
                    mailboxName = $mailbox.DisplayName
                    mailboxGUID = $mailbox.guid
                    error       = $errorDeets
                }
                
            }
        }
    }
    else
    {
        try{
            Set-Mailbox -identity $mailbox.guid -LitigationHoldEnabled $True -ErrorAction Stop
        }
        catch{
            try{
            New-ComplianceSearch -exchangelocation ".$($mailbox.PrimarySmtpAddress)" -AllowNotFoundExchangeLocationsEnabled $true -IncludeUserAppContent $true -IncludeOrgContent $true
            }
            catch{
                $errorDeets = $error[0] | select *
                $failedMailboxes += [PSCustomObject]{
                    mailboxName = $mailbox.DisplayName
                    mailboxGUID = $mailbox.guid
                    error       = $errorDeets
                }
                
            }
        }
    }

    }

}