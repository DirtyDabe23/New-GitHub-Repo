$isFinished = $False
Do{
cls
Write-Output "Welcome $($env:USERNAME) to the EVAPCO User Renamer!"
$exoConnection = Get-ConnectionInformation -erroraction SilentlyContinue
If (($exoConnection -eq $null) -OR ($exoConnection.State -ne "Connected"))
{
    Connect-ExchangeOnline -ShowBanner:$false
}


$userExists = $false
$usertoModify = $null
$scopes = $null
$exoConnection = $null
$graphOrLocal = Read-Host -Prompt "Enter 1 to change a Graph User, 2 for Local AD"

If ($graphOrLocal -eq 2)
{
    do{
        $currentUserName = Read-Host -Prompt "Enter the UPN of the user to fix"
        $userToModify = Get-ADUser -Filter "UserPrincipalName -eq '$currentUserName'" -properties * -erroraction SilentlyContinue
        if ($userToModify -ne $null)
        {
            $userExists = $true
            Write-Output "User Mapped. Proceeding"
        }
        Else
        {
            Write-Output "No user found with Username: $currentUserName Please try again`n`n`n"
        }
    } While ($userExists -eq $false)


    Write-Output "User Information is as follows:"
    Write-Output "User's UPN: $($usertoModify.UserPrincipalName)"
    Write-Output "User's Aliases: $($usertoModify.proxyAddresses)"
    Write-Output "User's SAM Account Name: $($usertoModify.SamAccountName)"

    $firstName = $userToModify.GivenName
    $firstName = $firstName.trim()
    $lastName = $usertoModify.Surname
    $lastName = $lastName.trim()
    $oldSAM = $userToModify.SamAccountName
    $oldUPN = $userToModify.UserPrincipalName
    $currentAliases = $usertomodify.proxyAddresses
    $newAlias = "smtp:"+$oldUPN
    $upnSuffix = "@$($userToModify.userPrincipalName.split('@')[1])"


            #This is to handle last names with a space or hyphen
            If ($firstName -match " ")
                {
                    Write-Output "First Name is: $firstName"
                        Write-Output "This has a space"
                    $firstName = $firstName.split(" ")
                    Write-Output "Post Split it is $firstName"
                    $firstName = $firstName[0].substring(0,1).toUpper()+$firstName[0].substring(1).toLower()+" "+$firstName[1].substring(0,1).toUpper()+$firstName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $firstName"
                    $firstName = $firstName.Trim()
                    Write-Output "Post Trim First Name is $firstName"
                    $firstNameUPN = $firstName.Replace(" ","").Trim()
                    Write-Output "First Name for UPN is $firstNameUPN"
                    }


            ElseIf($firstName -match "-")
                {
                        Write-Output "This is hyphenated"
                    $firstName = $firstName.split("-")
                    Write-Output "Post Split it is $firstName"
                    $firstName = $firstName[0].substring(0,1).toUpper()+$firstName[0].substring(1).toLower()+"-"+$firstName[1].substring(0,1).toUpper()+$firstName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $firstName"
                    $firstName = $firstName.Trim()
                    Write-Output "Post Trim First Name is $firstName"
                    $firstNameUPN = $firstName.trim()
                    Write-Output "Last Name for UPN is $firstNameUPN"
                    }
            #If their First Name is not Hyphenated or does not contain a space, it does not get modified.
            Else
            {
            $firstNameUPN = $firstName.SubString(0,1) +$FirstName.SubString(1).ToLower()
            }


            $lastName = $lastName.trim()
            #This is to handle last names with a space or hyphen
            If ($lastName -match " ")
                {
                    Write-Output "Last Name is: $lastName"
                        Write-Output "This has a space"
                    $lastName = $lastName.split(" ")
                    Write-Output "Post Split it is $lastName"
                    $lastName = $lastName[0].substring(0,1).toUpper()+$lastName[0].substring(1).toLower()+" "+$lastName[1].substring(0,1).toUpper()+$lastName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $lastName"
                    $lastName = $lastName.Trim()
                    Write-Output "Post Trim Last Name is $lastName"
                    $lastNameUPN = $lastName.Replace(" ","").Trim()
                    Write-Output "Last Name for UPN is $lastNameUPN"
                    }


            ElseIf($lastName -match "-")
                {
                        Write-Output "This is hyphenated"
                    $lastName = $lastName.split("-")
                    Write-Output "Post Split it is $lastName"
                    $lastName = $lastName[0].substring(0,1).toUpper()+$lastName[0].substring(1).toLower()+"-"+$lastName[1].substring(0,1).toUpper()+$lastName[1].substring(1).toLower()
                    Write-Output "Post Edits it is $lastName"
                    $lastName = $lastName.Trim()
                    Write-Output "Post Trim Last Name is $lastName"
                    $lastNameUPN = $lastName.trim()
                    Write-Output "Last Name for UPN is $lastNameUPN"
                    }
            Else
            {
            $lastNameUPN = $lastName.SubString(0,1) +$lastName.SubString(1).ToLower()
            }

            $newUPN = $firstNameUPN + "." +$lastNameUPN + $upnSuffix

            $mailNN = $firstnameUPN + "."+$lastNameUPN
            $mailNN = $mailNN.trim()
            If ($mailNN.length -gt 20)
            {
                $acctSAMName = $mailNN.substring(0,20)
            }

            Else
            {
                $acctSAMName = $mailNN
            }

            Write-Output "`n`n`n`nUser Information POST CHANGES WILL BE as follows:"
            Write-Output "User's NEW UPN: $newUPN"
            Write-Output "User's ADDED Aliases: $newAlias"
            Write-Output "User's NEW SAM Account Name: $acctSAMName"

            $confirmation = Read-Host "`n`nWould you like to process these changes? Y for Yes, N, for No, E to Edit Manually"

            If ($confirmation.substring(0,1) -eq 'Y')
            {
                If ($newAlias -in $currentAliases)
                {
                    Write-Output "`n`nAlias is already applied"
                }
                Else
                {
                    set-aduser $usertoModify -add @{"proxyAddresses"="smtp:$($usertoModify.UserPrincipalName)"}
                }
                Set-ADUser $usertoModify -userprincipalname $newUPN -SamAccountName $acctSAMName -emailAddress $newUPN
                $userChanged = Get-ADUser $acctSAMNAme -properties *
                Write-Output "`n`n`n`nUser Information POST CHANGES are as follows:"
                Write-Output "User's UPN: $($userChanged.UserPrincipalName)"
                Write-Output "User's Aliases: $($userChanged.proxyAddresses)"
                Write-Output "User's SAM Account Name: $($userChanged.SamAccountName)"

                $userDataPath = "\\evapcousers\users\$oldSAM"
                $newUserPath = "\\evapcousers\users\$acctSAMName"
                If (Test-Path $userDataPath)
                {
                    Write-Output "Legacy User Drive Detected, renaming"
                    Rename-Item -Path $userDataPath -NewName $newUserPath
                    Write-Output "Verify $($userchanged.displayNAme) can access $newUserPath"

                }
                try{
                Invoke-Command -ComputerName US-TT-VS-AADC01 -ScriptBlock {Start-AdSyncSyncCycle -PolicyType Delta} -ErrorAction Stop
                }
                catch{
                    Write-Output "Failed to run the sync"
                    Start-Sleep -Seconds 900
                }
            }
            If ($confirmation.substring(0,1) -eq 'N')
            {
                Write-Output "Aborting Changes."
            }
            If ($confirmation.substring(0,1) -eq 'E')
            {
                $newUPN = Read-Host "Enter the New UPN"
                $acctSAMNAme = $newUPN.split('@')[0]
                Set-ADUser $usertoModify -userprincipalname $newUPN -SamAccountName $acctSAMName -emailAddress $newUPN
                set-aduser $usertoModify -add @{"proxyAddresses"="smtp:$($usertoModify.UserPrincipalName)"}
                $userChanged = Get-ADUser $acctSAMNAme -properties *
                Write-Output "`n`n`n`nUser Information POST CHANGES are as follows:"
                Write-Output "User's UPN: $($userChanged.UserPrincipalName)"
                Write-Output "User's Aliases: $($userChanged.proxyAddresses)"
                Write-Output "User's SAM Account Name: $($userChanged.SamAccountName)"
            }
            ElseIf (($confirmation.substring(0,1) -ne 'E') -and ($confirmation.substring(0,1) -ne 'Y') -and ($confirmation.substring(0,1) -ne 'N'))
            {
                Write-Output "Invalid Selection, Aborting Changes"
            }
}

If ($graphOrLocal -eq 1)
{
    $contexts = Get-MGContext
    If ($contexts -eq $null)
    {
    Connect-MGGRaph -NoWelcome
    }
    $scopes = Get-MGcontext | Select -ExpandProperty Scopes
    If ($scopes -notcontains 'User.ReadWrite.All')
    {
        Write-Output 'Insufficient privileges. Please PIM, use a different account, or contact GHD'
    }
    Else
    {

        $exoConnection = Get-ConnectionInformation
        If (($exoConnection -eq $null) -OR ($exoConnection.State -ne "Connected"))
        {
            Connect-ExchangeOnline -ShowBanner:$false
        }


        do{
            $currentUserName = Read-Host -Prompt "Enter the UPN of the user to fix"
            $userToModify = Get-MGBetaUser -userid "$currentUserName" -property * -erroraction SilentlyContinue
            if ($userToModify -ne $null)
            {
                $userExists = $true
                Write-Output "User Mapped. Proceeding"
            }
            Else
            {
                Write-Output "No user found with Username: $currentUserName Please try again`n`n`n"
            }
        } While ($userExists -eq $false)


        Write-Output "User Information is as follows:"
        Write-Output "User's UPN: $($usertoModify.UserPrincipalName)"
        Write-Output "User's Aliases: $($usertoModify.proxyAddresses)"

        $firstName = $userToModify.GivenName
        $firstName = $firstName.trim()
        $lastName = $usertoModify.Surname
        $lastName = $lastName.trim()
        $oldUPN = $userToModify.UserPrincipalName
        $currentAliases = $usertomodify.proxyAddresses
        $newAlias = "smtp:"+$oldUPN
        $upnSuffix = "@$($userToModify.userPrincipalName.split('@')[1])"


                #This is to handle last names with a space or hyphen
                If ($firstName -match " ")
                    {
                        Write-Output "First Name is: $firstName"
                        Write-Output "This has a space"
                        $firstName = $firstName.split(" ")
                        Write-Output "Post Split it is $firstName"
                        $firstName = $firstName[0].substring(0,1).toUpper()+$firstName[0].substring(1).toLower()+" "+$firstName[1].substring(0,1).toUpper()+$firstName[1].substring(1).toLower()
                        Write-Output "Post Edits it is $firstName"
                        $firstName = $firstName.Trim()
                        Write-Output "Post Trim First Name is $firstName"
                        $firstNameUPN = $firstName.Replace(" ","").Trim()
                        Write-Output "First Name for UPN is $firstNameUPN"
                    }


                ElseIf($firstName -match "-")
                    {
                        Write-Output "This is hyphenated"
                        $firstName = $firstName.split("-")
                        Write-Output "Post Split it is $firstName"
                        $firstName = $firstName[0].substring(0,1).toUpper()+$firstName[0].substring(1).toLower()+"-"+$firstName[1].substring(0,1).toUpper()+$firstName[1].substring(1).toLower()
                        Write-Output "Post Edits it is $firstName"
                        $firstName = $firstName.Trim()
                        Write-Output "Post Trim First Name is $firstName"
                        $firstNameUPN = $firstName.trim()
                        Write-Output "Last Name for UPN is $firstNameUPN"
                    }
                #If their First Name is not Hyphenated or does not contain a space, it does not get modified.
                Else
                {
                $firstNameUPN = $firstName.SubString(0,1) +$FirstName.SubString(1).ToLower()
                }


                $lastName = $lastName.trim()
                #This is to handle last names with a space or hyphen
                If ($lastName -match " ")
                    {
                        Write-Output "Last Name is: $lastName"
                        Write-Output "This has a space"
                        $lastName = $lastName.split(" ")
                        Write-Output "Post Split it is $lastName"
                        $lastName = $lastName[0].substring(0,1).toUpper()+$lastName[0].substring(1).toLower()+" "+$lastName[1].substring(0,1).toUpper()+$lastName[1].substring(1).toLower()
                        Write-Output "Post Edits it is $lastName"
                        $lastName = $lastName.Trim()
                        Write-Output "Post Trim Last Name is $lastName"
                        $lastNameUPN = $lastName.Replace(" ","").Trim()
                        Write-Output "Last Name for UPN is $lastNameUPN"
                    }


                ElseIf($lastName -match "-")
                    {c
                        Write-Output "This is hyphenated"
                        $lastName = $lastName.split("-")
                        Write-Output "Post Split it is $lastName"
                        $lastName = $lastName[0].substring(0,1).toUpper()+$lastName[0].substring(1).toLower()+"-"+$lastName[1].substring(0,1).toUpper()+$lastName[1].substring(1).toLower()
                        Write-Output "Post Edits it is $lastName"
                        $lastName = $lastName.Trim()
                        Write-Output "Post Trim Last Name is $lastName"
                        $lastNameUPN = $lastName.trim()
                        Write-Output "Last Name for UPN is $lastNameUPN"
                    }
                Else
                {
                $lastNameUPN = $lastName.SubString(0,1) +$lastName.SubString(1).ToLower()
                }

                $newUPN = $firstNameUPN + "." +$lastNameUPN + $upnSuffix

                $mailNN = $firstnameUPN + "."+$lastNameUPN
                $mailNN = $mailNN.trim()
                Write-Output "`n`n`n`nUser Information POST CHANGES WILL BE as follows:"
                Write-Output "User's NEW UPN: $newUPN"
                Write-Output "User's ADDED Aliases: $newAlias"

                $confirmation = Read-Host "`n`nWould you like to process these changes? Y for Yes, N, for No, E to Edit Manually"

                If ($confirmation.substring(0,1) -eq 'Y')
                {
                    If ($newAlias -in $currentAliases)
                    {
                        Write-Output "`n`nAlias is already applied"
                    }
                    Else
                    {
                        Set-Mailbox $userToModify -emailAddresses @{Add=$newAlias}
                    }
                    Update-MGBetaUser -UserId $usertoModify -userprincipalname $newUPN
                    $userChanged = Get-ADUser $acctSAMNAme -properties *
                    Write-Output "`n`n`n`nUser Information POST CHANGES are as follows:"
                    Write-Output "User's UPN: $($userChanged.UserPrincipalName)"
                    Write-Output "User's Aliases: $($userChanged.proxyAddresses)"
                    Write-Output "User's SAM Account Name: $($userChanged.SamAccountName)"
                }
                ElseIf ($confirmation.substring(0,1) -eq 'N')
                {
                    Write-Output "Aborting Changes."
                }
                ElseIf ($confirmation.substring(0,1) -eq 'E')
                {
                    $newUPN = Read-Host "Enter the New UPN"
                    $acctSAMNAme = $newUPN.split('@')[0]
                    Update-MGBetaUser -userid $usertoModify -userprincipalname $newUPN
                    Set-Mailbox $userToModify -emailAddresses @{Add=$newAlias}
                    $userChanged = Get-MGBetaUser -userid $newUPN -properties *
                    Write-Output "`n`n`n`nUser Information POST CHANGES are as follows:"
                    Write-Output "User's UPN: $($userChanged.UserPrincipalName)"
                    Write-Output "User's Aliases: $($userChanged.proxyAddresses)"
                }
                ElseIf (($confirmation.substring(0,1) -ne 'E') -and ($confirmation.substring(0,1) -ne 'Y') -and ($confirmation.substring(0,1) -ne 'N'))
                {
                    Write-Output "Invalid Selection, Aborting Changes"
                }
    }
}

Elseif (($graphOrLocal -ne 1) -and ($graphOrLocal -ne 2))
{
    Write-Output 'Invalid Selection'
}

            $inputFinished = Read-Host "Would you like to rerun the script? Y for Yes, N, or any other Letter, for No"

            If ($inputFinished.substring(0,1) -eq 'Y')
            {
                $isFinished = $False
            }
            Else
            {
                $isFinished = $True
            }

}
while ($isFinished -ne $True)