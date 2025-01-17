$NewAcl = Get-Acl -Path (Read-Host -Prompt "Enter the path of the ACL to copy")
# Set properties
$identity = (Get-ADGroup (Read-Host -Prompt "Enter the group name to apply their rights")).sid
$fileSystemRights = "ReadAndExecute" , "Synchronize"
$type = "Allow"
# Create new rule
$fileSystemAccessRuleArgumentList = $identity, $fileSystemRights, $type
$fileSystemAccessRule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $fileSystemAccessRuleArgumentList
# Apply new rule
$NewAcl.SetAccessRule($fileSystemAccessRule)
Set-Acl -Path (Read-Host -Prompt "Enter the path of the file to apply the New ALC") -AclObject $NewAcl