param(
    [string] $reporter,
    [string] $accountNumber,
    [string] $ghdKey,
    [string] $procKey   
)

try {
    # Read from Azure Key Vault using managed identity
    $connection = Connect-AzAccount -Identity
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "US-TT-Vault" -Name "JiraAPI" -AsPlainText | Out-Null
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}


#Jira
$jiraText = "david.drosdick@evapco.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$jiraHeaders = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}


#GHD Ticket for Data Retrieval
$Issue = Invoke-RestMethod -Method get -uri "https://evapco.atlassian.net/rest/api/2/issue/$ghdKey" -Headers $jiraHeaders

$officeLocation = $issue.fields.customfield_10787.value
$officeLocationID =  [int]$issue.fields.customfield_10787.id 
$department = $issue.fields.customfield_10787.child.value
$departmentID = [int]$issue.fields.customfield_10787.child.id 


$ttProduction = "Assembly" `
, "Cage/Inventory" `
, "Coil - Non-Welder" `
, "Coil - Welder" `
, "Control Panel" `
, "Electrical" `
, "Evaporator" `
, "Evaporator Coil" `
, "Evaporator Support" `
, "High Side Custom Engineering" `
, "Low Side Assembly" `
, "Low Side Custom Engineering" `
, "Maintenance, Machinery, & Equipment" `
, "Manufacturing Engineering" `
, "Materials" `
, "Operator Associate" `
, "Parts" `
, "Plant Management" `
, "Production" `
, "Production Control" `
, "Quality - Office" `
, "Quality - Shop" `
, "Research & Development" `
, "Safety - Office" `
, "Safety - Shop" `
, "Sheet Metal" `
, "Shop Office" `
, "Stockroom, Warehouse, Part Order, Shipping" `
,"Sub-Assembly & Support","Traffic","Welding"

$validAccountNumber = "6680-01-01" `
, "6680-01-02"`
, "6680-01-03"`
, "6680-01-04"`
, "6680-01-05"`
, "6680-01-06"`
, "6680-01-07"`
, "6680-01-09"`
, "6680-01-12"`
, "6680-01-13"`
, "6680-01-14"`
, "6680-01-16"`
, "6680-02-00"`
, "6680-02-20"`
, "6680-03-00"`
, "6680-06-00"`
, "1310-01-00"`
, "1345-01-00"`
, "1346-01-00"`
, "1355-01-00"`
, "1380-01-00"`
, "1398-01-00"`
, "1554-01-00"`
, "1557-01-00"`
, "6850-01-00"`
, "1335-01-00"`
, "2600-03-00"`
, "1325-01-00"`
, "1318-01-00"







If ($null -eq $accountNumber)
{
    If ($officeLocation -eq 'Evapco East')
    {
        if ($department -eq 'Marketing Refrigeration')
        {
            $accountNumber = "6680-01-01"
            $budgetOwner = "63ed1d03fcb584bb67287bd2"
        }
        if ($department -eq 'Marketing HVAC')
        {
            $accountNumber = "6680-01-02"
            $budgetOwner = "63eceaa2333d0e2ec16ee915"
        }
        if ($department -eq 'Product Development - HVAC')
        {
            $accountNumber = "6680-01-03"
            $budgetOwner = "63ed1bbd07df05aa82765836"
        }
        if ($department -in $ttProduction)
        {
            $accountNumber = "6680-01-04"
            $budgetOwner = "63ed1a2a3030fa7db80962d5"
        }
        if ($department -eq 'Finance')
        {
            $accountNumber = "6680-01-05"
            $budgetOwner = "63ed1a28c06f89566cb2f3da"
        }
        if ($department -eq 'Executive')
        {
            $accountNumber = "6680-01-06"
            $budgetOwner = "557058:d027e984-46df-4610-a32f-d3025371edd7"
        }
        if ($department -eq 'Product Development')
        {
            $accountNumber = "6680-01-07"
            $budgetOwner = "712020:23df15de-306f-4394-8ca3-3e07106fce4f"
        }
        if ($department -eq 'Product Development')
        {
            $accountNumber = "6680-01-07"
            $budgetOwner = "712020:23df15de-306f-4394-8ca3-3e07106fce4f"
        }
        if ($department -eq 'Product Development - Refrigeration')
        {
            $accountNumber = "6680-01-09"
            $budgetOwner = "63ed1a2a3030fa7db80962d6"
        }
        if ($department -eq 'Evapcold')
        {
            $accountNumber = "6680-01-12"
            $budgetOwner = "63ed1e92333d0e2ec16f016f"
        }
        if ($department -eq 'Water Systems')
        {
            $accountNumber = "6680-01-13"
            $budgetOwner = "63ed1e762661cde223377518"
        }
        if ($department -eq 'People Operations')
        {
            $accountNumber = "6680-01-14"
            $budgetOwner = "63ed1ad7af665dfde890fbd1"
        }
        if ($department -eq 'Global Information Technology')
        {
            $accountNumber = "6680-01-16"
            $budgetOwner = "557058:d027e984-46df-4610-a32f-d3025371edd7"
        }
        if ($department -eq 'Customer Solutions')
        {
            $accountNumber = "Unknown"
            $budgetOwner = "Unknown"
        }
    }
    If ($officeLocation -eq 'EVAPCO Alcoil, Inc.')
    {
        $accountNumber = "1398-01-00"
        $budgetOwner = "70121:a34a1f62-7a13-4954-8aea-48fc711eec85"
    }
    If ($officeLocation -eq 'EVAPCO Australia (Pty.) Ltd.')
    {
        $accountNumber = "1335-01-00"
        $budgetOwner = "63ed225beaf0b28dfd1b88a9"
    }
    If ($officeLocation -eq 'EVAPCO Dry Cooling, Inc.')
    {
        $accountNumber = "1346-01-00"
        $budgetOwner = "63ed1e91333d0e2ec16f016e"
    }
    If ($officeLocation -eq 'EVAPCO Europe BVBA')
    {
        $accountNumber = "1310-01-00"
        $budgetOwner = "63ed1aead4dc4e35db10d11a"
    }
    If ($officeLocation -eq 'EVAPCO Iowa')
    {
        $accountNumber = "6680-06-00"
        $budgetOwner = "63ed1a15c06f89566cb2f3cb"
    }
    If ($officeLocation -eq 'EVAPCO LMP')
    {
        $accountNumber = "1554-01-00"
        $budgetOwner = "63ed2187af665dfde890ff24"
    }
    If ($officeLocation -eq 'EVAPCO Midwest')
    {
        $accountNumber = "6680-02-00"
        $budgetOwner = "63ed1a2ec06f89566cb2f3e2"
    }
    If ($officeLocation -eq 'EVAPCO Iowa')
    {
        $accountNumber = "6680-06-00"
        $budgetOwner = "63ed1a15c06f89566cb2f3cb"
    }
    If ($officeLocation -eq 'EVAPCO Newton')
    {
        $accountNumber = "6680-02-20"
        $budgetOwner = "63ed1a2ec06f89566cb2f3e2"
    }
    If ($officeLocation -eq 'EVAPCO Select Tech')
    {
        $accountNumber = "1557-01-00"
        $budgetOwner = "63ebddd5c06f89566cb275d7"
    }
    If ($officeLocation -eq 'EVAPCO West')
    {
        $accountNumber = "6680-03-00"
        $budgetOwner = "712020:b2da4372-6f6f-41f2-9453-850ad353119c"
    }
    If ($officeLocation -eq 'EvapTech, Inc.')
    {
        $accountNumber = "1345-01-00"
        $budgetOwner = "712020:41a71daf-df65-4198-b3d3-dab7a335d49e"
    }
    If ($officeLocation -eq 'Refrigeration Vessels & Systems Corporation')
    {
        $accountNumber = "1380-01-00"
        $budgetOwner = "63ed225beaf0b28dfd1b88a9"
    }
    If ($officeLocation -eq 'Tower Components, Inc.')
    {
        $accountNumber = "1355-01-00"
        $budgetOwner = "63ed1ad13030fa7db8096339"
    }
}

Else
{
   If ($accountNumber -notin $validAccountNumber)
    {
        Write-Output "Account Number is Invalid. Reverting to Office Location and Department."
        If ($officeLocation -eq 'Evapco East')
        {
            if ($department -eq 'Marketing Refrigeration')
            {
                $accountNumber = "6680-01-01"
                $budgetOwner = "63ed1d03fcb584bb67287bd2"
            }
            if ($department -eq 'Marketing HVAC')
            {
                $accountNumber = "6680-01-02"
                $budgetOwner = "63eceaa2333d0e2ec16ee915"
            }
            if ($department -eq 'Product Development - HVAC')
            {
                $accountNumber = "6680-01-03"
                $budgetOwner = "63ed1bbd07df05aa82765836"
            }
            if ($department -in $ttProduction)
            {
                $accountNumber = "6680-01-04"
                $budgetOwner = "63ed1a2a3030fa7db80962d5"
            }
            if ($department -eq 'Finance')
            {
                $accountNumber = "6680-01-05"
                $budgetOwner = "63ed1a28c06f89566cb2f3da"
            }
            if ($department -eq 'Executive')
            {
                $accountNumber = "6680-01-06"
                $budgetOwner = "557058:d027e984-46df-4610-a32f-d3025371edd7"
            }
            if ($department -eq 'Product Development')
            {
                $accountNumber = "6680-01-07"
                $budgetOwner = "712020:23df15de-306f-4394-8ca3-3e07106fce4f"
            }
            if ($department -eq 'Product Development')
            {
                $accountNumber = "6680-01-07"
                $budgetOwner = "712020:23df15de-306f-4394-8ca3-3e07106fce4f"
            }
            if ($department -eq 'Product Development - Refrigeration')
            {
                $accountNumber = "6680-01-09"
                $budgetOwner = "63ed1a2a3030fa7db80962d6"
            }
            if ($department -eq 'Evapcold')
            {
                $accountNumber = "6680-01-12"
                $budgetOwner = "63ed1e92333d0e2ec16f016f"
            }
            if ($department -eq 'Water Systems')
            {
                $accountNumber = "6680-01-13"
                $budgetOwner = "63ed1e762661cde223377518"
            }
            if ($department -eq 'People Operations')
            {
                $accountNumber = "6680-01-14"
                $budgetOwner = "63ed1ad7af665dfde890fbd1"
            }
            if ($department -eq 'Global Information Technology')
            {
                $accountNumber = "6680-01-16"
                $budgetOwner = "557058:d027e984-46df-4610-a32f-d3025371edd7"
            }
            if ($department -eq 'Customer Solutions')
            {
                $accountNumber = "Unknown"
                $budgetOwner = "Unknown"
            }
        }
        If ($officeLocation -eq 'EVAPCO Alcoil, Inc.')
        {
            $accountNumber = "1398-01-00"
            $budgetOwner = "70121:a34a1f62-7a13-4954-8aea-48fc711eec85"
        }
        If ($officeLocation -eq 'EVAPCO Australia (Pty.) Ltd.')
        {
            $accountNumber = "1335-01-00"
            $budgetOwner = "63ed225beaf0b28dfd1b88a9"
        }
        If ($officeLocation -eq 'EVAPCO Dry Cooling, Inc.')
        {
            $accountNumber = "1346-01-00"
            $budgetOwner = "63ed1e91333d0e2ec16f016e"
        }
        If ($officeLocation -eq 'EVAPCO Europe BVBA')
        {
            $accountNumber = "1310-01-00"
            $budgetOwner = "63ed1aead4dc4e35db10d11a"
        }
        If ($officeLocation -eq 'EVAPCO Iowa')
        {
            $accountNumber = "6680-06-00"
            $budgetOwner = "63ed1a15c06f89566cb2f3cb"
        }
        If ($officeLocation -eq 'EVAPCO LMP')
        {
            $accountNumber = "1554-01-00"
            $budgetOwner = "63ed2187af665dfde890ff24"
        }
        If ($officeLocation -eq 'EVAPCO Midwest')
        {
            $accountNumber = "6680-02-00"
            $budgetOwner = "63ed1a2ec06f89566cb2f3e2"
        }
        If ($officeLocation -eq 'EVAPCO Iowa')
        {
            $accountNumber = "6680-06-00"
            $budgetOwner = "63ed1a15c06f89566cb2f3cb"
        }
        If ($officeLocation -eq 'EVAPCO Newton')
        {
            $accountNumber = "6680-02-20"
            $budgetOwner = "63ed1a2ec06f89566cb2f3e2"
        }
        If ($officeLocation -eq 'EVAPCO Select Tech')
        {
            $accountNumber = "1557-01-00"
            $budgetOwner = "63ebddd5c06f89566cb275d7"
        }
        If ($officeLocation -eq 'EVAPCO West')
        {
            $accountNumber = "6680-03-00"
            $budgetOwner = "712020:b2da4372-6f6f-41f2-9453-850ad353119c"
        }
        If ($officeLocation -eq 'EvapTech, Inc.')
        {
            $accountNumber = "1345-01-00"
            $budgetOwner = "712020:41a71daf-df65-4198-b3d3-dab7a335d49e"
        }
        If ($officeLocation -eq 'Refrigeration Vessels & Systems Corporation')
        {
            $accountNumber = "1380-01-00"
            $budgetOwner = "63ed225beaf0b28dfd1b88a9"
        }
        If ($officeLocation -eq 'Tower Components, Inc.')
        {
            $accountNumber = "1355-01-00"
            $budgetOwner = "63ed1ad13030fa7db8096339"
        }
    }
   else 
   {
        switch ($accountNumber) {
            "6680-01-01"{$BudgetOwner = "63ed1d03fcb584bb67287bd2"}
            "6680-01-02"{$BudgetOwner = "63eceaa2333d0e2ec16ee915"}
            "6680-01-03"{$BudgetOwner = "63ed1bbd07df05aa82765836"}
            "6680-01-04"{$BudgetOwner = "63ed1a2a3030fa7db80962d5"}
            "6680-01-05"{$BudgetOwner = "63ed1a28c06f89566cb2f3da"}
            "6680-01-06"{$BudgetOwner = "557058:d027e984-46df-4610-a32f-d3025371edd7"}
            "6680-01-07"{$BudgetOwner = "712020:23df15de-306f-4394-8ca3-3e07106fce4f"}
            "6680-01-09"{$BudgetOwner = "63ed1a2a3030fa7db80962d6"}
            "6680-01-12"{$BudgetOwner = "63ed1e92333d0e2ec16f016f"}
            "6680-01-13"{$BudgetOwner = "63ed1e762661cde223377518"}
            "6680-01-14"{$BudgetOwner = "63ed1ad7af665dfde890fbd1"}
            "6680-01-16"{$BudgetOwner = "557058:d027e984-46df-4610-a32f-d3025371edd7"}
            "6680-02-00"{$BudgetOwner = "63ed1a2ec06f89566cb2f3e2"}
            "6680-02-20"{$BudgetOwner = "63ed1a2ec06f89566cb2f3e2"}
            "6680-03-00"{$BudgetOwner = "712020:b2da4372-6f6f-41f2-9453-850ad353119c"}
            "6680-06-00"{$BudgetOwner = "63ed1a15c06f89566cb2f3cb"}
            "1310-01-00"{$BudgetOwner = "63ed1aead4dc4e35db10d11a"}
            "1345-01-00"{$BudgetOwner = "712020:41a71daf-df65-4198-b3d3-dab7a335d49e"}
            "1346-01-00"{$BudgetOwner = "63ed1e91333d0e2ec16f016e"}
            "1355-01-00"{$BudgetOwner = "63ed1ad13030fa7db8096339"}
            "1380-01-00"{$BudgetOwner = "63ed225beaf0b28dfd1b88a9"}
            "1398-01-00"{$BudgetOwner = "70121:a34a1f62-7a13-4954-8aea-48fc711eec85"}
            "1554-01-00"{$BudgetOwner = "63ed2187af665dfde890ff24"}
            "1557-01-00"{$BudgetOwner = "63ebddd5c06f89566cb275d7"}
            "6850-01-00"{$BudgetOwner = "Comcast"}
            " 1335-01-00"{$BudgetOwner = "63ed225beaf0b28dfd1b88a9"}
            "2600-03-00"{$BudgetOwner = "712020:b2da4372-6f6f-41f2-9453-850ad353119c"}
            "1325-01-00"{$BudgetOwner = "712020:7319d2fc-1479-49cf-9aeb-180f6e9dc4df"}
            "1318-01-00"{$BudgetOwner = "63ed1c4240d0fe709074ad64"}
        }
   } 

}


If (($null -eq $accountNumber) -and ($null -eq $budgetOwner))
{
    Write-Output "Not valid. Please contact GIT for Assistance"
    Exit 1 
}
else {
    
switch ($departmentID) {
    $null { 
        $payload = @{
            "update" = @{
                "customfield_10787" = @(
                @{"set" = @{"id" = $officeLocationID}})
                "customfield_10872" = @(
                    @{"set" = @{"id" = "$budgetOwner"}})
                "customfield_10721" = @(
                @{"set" = "$accountNumber"})
            }
        }
    }
    Default {
        $payload = @{
            "update" = @{
                "customfield_10787" = @(
                @{"set" = @{
                    "id" = $officeLocationID
                    "child" = @{"id" = $departmentID}}})
                "customfield_10872" = @(
                @{"set" = @{"id" = "$budgetOwner"}})
                "customfield_10721" = @(
                @{"set" = "$accountNumber"})
                }
            }   
    }
}

   $jsonPayload = $payload | ConvertTo-Json -Depth 10
   
   
   Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$($procKey)" -Method Put -Body $jsonPayload -Headers $jiraHeaders

}

