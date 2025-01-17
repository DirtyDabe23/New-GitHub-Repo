#Set the AliasName to what you want to name the alias
$aliasName = "alias:brave"

#Set the aliasItemPath Variable to the EXE or command you want to call 
$aliasItemPath = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"

Set-Item -Path $AliasName -Value $aliasItemPath