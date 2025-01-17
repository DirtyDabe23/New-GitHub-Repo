$logName = Read-Host "Enter the LogName to review"
$ID = Read-Host "Enter the ID to review" 
get-winevent -logname $logName | Where-Object {($_.ID -eq $ID)} | select * | more
