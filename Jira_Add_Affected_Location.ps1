param(
    [string]$Reporter,
    [string]$Description,
    [string]$Key
)

# Example usage of the parameters
Write-Output "The Reporter is: $Reporter"
Write-Output "The Key is: $Key"
Write-Output "The description is: `n`n$Description`n`n`n"

Connect-MGGraph -Identity -NoWelcome



try {
    # Read from Azure Key Vault using managed identity
    $connection = Connect-AzAccount -Identity
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "US-TT-Vault" -Name "JiraAPI" -AsPlainText
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}

try{
    $jiraRetrSecret = Get-AzKeyVaultSecret -VaultName "US-TT-Vault" -Name "GITGraphAPI" -AsPlainText
}
catch {
    $errorMessage = $_
    Write-Output $errorMessage

    $ErrorActionPreference = "Stop"
}

#The Tenant ID from App Registrations
$graphTenantId = "9e228334-bae6-4c7e-8b7f-9b0824082151"

# Construct the authentication URL
$graphURI = "https://login.microsoftonline.com/$graphTenantId/oauth2/v2.0/token"
 
#The Client ID from App Registrations
$graphClientID = "56cb7f72-67ee-4531-96d7-39a4e2b53555"

If ($null -eq $retrGraphSecret)
{
    $retrGraphSecret = Read-Host -Prompt "Enter the Graph API Secret" -MaskInput
}
 
# Construct the body to be used in Invoke-WebRequest for the Authentication Token.
$graphAPIBody = @{
    client_id     = $graphClientID
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $retrGraphSecret
    grant_type    = "client_credentials"
}
 


#Jira
$jiraText = "david.drosdick@evapco.com:$jiraRetrSecret"
$jiraBytes = [System.Text.Encoding]::UTF8.GetBytes($jiraText)
$jiraEncodedText = [Convert]::ToBase64String($jiraBytes)
$headers = @{
    "Authorization" = "Basic $jiraEncodedText"
    "Content-Type" = "application/json"
}


# Fetch user information
Try{
    $user = Get-MGBetaUser -userid $Reporter -erroraction Stop
    }
    Catch{
        $regex = "[a-zA-Z][a-z0-9!#\$%&'*+/=?^_`{|}~-]*(?:\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
        $match = $description | Select-String -Pattern $regex
        If ($null -eq $match)
        {
            $searchUser = "smtp:"+$reporter
            $user = Get-MGBetaUser -search "proxyAddresses:$searchUser" -ConsistencyLevel eventual
        }
        Elseif ($null -ne $match)
        {
            $reporterExtracted = $match.matches.value
            try{
            Write-Output "No Match for $reporter. Reviewing the ticket details for a user to match to a location"
            $user = Get-MGBetaUser -userid $reporterExtracted -erroraction Stop
            }
            catch{
            # Get Authentication Token
            $tokenRequest = Invoke-WebRequest -Method Post -Uri $graphURI -ContentType "application/x-www-form-urlencoded" -Body $graphAPIBody -UseBasicParsing
            # Extract the Access Token
            $baseToken = ($tokenRequest.content | convertfrom-json).access_token
            $graphAPIHeader = @{
                "Authorization" = "Bearer $baseToken"
                "ConsistencyLevel" = "eventual"
            }
            $user = (Invoke-RestMethod -uri "https://graph.microsoft.com/v1.0/users?`$filter=proxyAddresses/any(x:x eq 'smtp:$reporterExtracted') OR proxyAddresses/any(x:x eq 'SMTP:$reporterExtracted')" -Headers $graphAPIHeader -Method Get -ContentType 'application/json').value
            }
        }
    }
    
    If ($null -eq $user)
    {
        Write-Output "User is null, unable to review or add an affected location"
        #Exit 1
    }
    
    If ($null -eq $user.officeLocation)
    {
        Write-Output "User Office Location is null, unable to review or add an affected location"
        #Exit 1
    }
    
    Write-Output "User is $($user.UserPrincipalName) and their Office Location is $($user.OfficeLocation)"

# Define a mapping from location names to OptionIDs
$locationMapping = @{
    "EVAPCO East" = "12034"
    "EVAPCO West" = "12035"
    "EVAPCO Midwest" = "12036"
    "EVAPCO Iowa" = "12037"
    "Refrigeration Vessels & Systems Corporation" = "12038"
    "EVAPCO Europe BVBA" = "12039"
    "EVAPCO (Milano) Europe, S.r.l." = "12040"
    "EVAPCO (Sondrio) Europe, S.r.l." = "12041"
    "EVAPCO (Beijing) Refrigeration Equipment Co., Ltd." = "12042"
    "EVAPCO (Shanghai) Refrigeration Equipment Co., Ltd." = "12043"
    "EVAPCO Australia (Pty.) Ltd." = "12044"
    "EvapTech, Inc." = "12045"
    "EVAPCO Dry Cooling, Inc." = "12046"
    "Tower Components, Inc." = "12047"
    "EVAPCO Europe A/S" = "12048"
    "EVAPCO Brasil" = "12049"
    "Fan TR" = "12050"
    "EVAPCO Alcoil, Inc." = "12051"
    "EVAPCO Air Cooling Systems (Jiaxing) Co., Ltd." = "12052"
    "EVAPCO Iowa Sales & Engineering" = "12053"
    "EVAPCO LMP" = "12054"
    "EVAPCO Select Tech" = "12055"
    "EVAPCO Europe GmbH" = "12056"
    "EvapTech Asia Pacific Sdn Bhd" = "12057"
    "EvapTech (Shanghai) Cooling Tower Co., Ltd." = "12058"
    "EVAPCO Middle East DMCC" = "12059"
    "EVAPCO S.A. (Pty.) Ltd." = "12060"
    "EVAPCO Newton" = "12061"
}

# Get user office locations as Jira option objects
$userLocation = @()  # Start with an empty array
foreach ($location in $user.OfficeLocation) {
    if ($locationMapping.ContainsKey($location)) {
        $userLocation += @{ "id" = $locationMapping[$location] }
    } else {
        Write-Warning "Location '$location' not found in mapping."
    }
}

# Debugging output to check user location
Write-Output "User Location: $userLocation"
$userLocation | ForEach-Object { Write-Output "Location ID: $($_.id)" }

# Ensure userLocation is an array, even if it contains only one item
if ($userLocation.Count -eq 1) {
    $userLocation = @($userLocation)
}

# Define the payload ensuring userLocation is an array of objects with IDs
$payload = @{
    "update" = @{
        "customfield_10923" = @(
            @{
                "set" = @($userLocation)  # Explicitly cast as an array
            }
        )
    }
}

# Debugging output for payload before JSON conversion
Write-Output "Payload (Hashtable): $payload"
$payload.update.customfield_10923[0].set | ForEach-Object { Write-Output "Set ID: $($_.id)" }

# Convert the payload to JSON
$jsonPayload = $payload | ConvertTo-Json -Depth 10

# Log payload for debugging
Write-Output "Payload (JSON): $jsonPayload"

# Make the PUT request
try {
    $response = Invoke-RestMethod -Uri "https://evapco.atlassian.net/rest/api/2/issue/$key" -Method Put -Body $jsonPayload -Headers $headers
    Write-Output "Response: $response"
} catch {
    Write-Error "Failed to update issue: $_"
    Write-Output "Payload: $jsonPayload"
}