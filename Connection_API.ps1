#Connection to the Jira API after getting the token from the Key Vault
$connectionVaultName = 'ConnectionAPI'
$connectionAPIVersion = "2020-06-01"
$connectionResource = "https://vault.azure.net"
$connectionEndpoint = "{0}?resource={1}&api-version={2}" -f $env:IDENTITY_ENDPOINT,$connectionResource,$connectionAPIVersion
$connectionSecretFile = ""
try
{
    Invoke-WebRequest -Method GET -Uri $connectionEndpoint -Headers @{Metadata='True'} -UseBasicParsing
}
catch
{
    $connectionWWWAuthHeader = $_.Exception.Response.Headers["WWW-Authenticate"]
    if ($connectionWWWAuthHeader -match "Basic realm=.+")
    {
        $connectionSecretFile = ($connectionWWWAuthHeader -split "Basic realm=")[1]
    }
}
$connectionSecret = Get-Content -Raw $connectionSecretFile
$connectionResponse = Invoke-WebRequest -Method GET -Uri $connectionEndpoint -Headers @{Metadata='True'; Authorization="Basic $connectionSecret"} -UseBasicParsing
if ($connectionResponse)
{
    $connectionToken = (ConvertFrom-Json -InputObject $connectionResponse.Content).access_token
}

$connectionRetrSecret = (Invoke-RestMethod -Uri "https://us-tt-vault.vault.azure.net/secrets/$($connectionVaultName)?api-version=2016-10-01" -Method GET -Headers @{Authorization="Bearer $connectionToken"}).value

#Jira via the API or by Read-Host 
If ($null -eq $connectionRetrSecret)
{
    $connectionRetrSecret = Read-Host "Enter the API Key" -MaskInput
}
else {
    $null
}

#Jira


$connectionAuthURI = "https://api.webqa.moredirect.com/service/rest/auth/oauth2?grant_type=PASSWORD&password=$connectionRetrSecret&username=GIT-CYOPS-Technical%40evapco.com"

# Get Authentication Token
$connectionToken = (Invoke-Restmethod -uri $connectionAuthURI).access_token | ConvertTo-SecureString -AsPlainText -force


$connectionText = "GIT-CYOPS-Technical@evapco.com@evapco.com:$connectionRetrSecret"
$connectionBytes = [System.Text.Encoding]::UTF8.GetBytes($connectionText)
$connectionEncodedText = [Convert]::ToBase64String($connectionBytes)
$connectionHeader = @{
    "Authorization" = "Token $connectionEncodedText"
    "Content-Type" = "application/json"
}

Invoke-RestMethod -uri "https://api.webqa.moredirect.com/service/rest/listing/assets" -Headers $connectionHeader -Token $connectionToken -Method Get
