if ($env:OneDrive)
{
$chromeAppDataSize =(Get-ChildItem "$env:LocalAppData\Google\Chrome" -Recurse -Force | Measure-Object -Sum Length).sum/1MB
If($chromeAppDataSize)
{
Get-ITem "$env:LocalAppData\Google\Chrome" | Copy-ITem -Destination $env:OneDrive -Recurse -Force
}
Else
{
Write-Output "Chrome is not used"
}
}
Else
{
Write-Output "OneDrive is not set up"
}