$Trigger = New-ScheduledTaskTrigger -AtLogOn -User 'dcc-dt01\ddros' # Specify the trigger settings

$User = "dcc-dt01\ddros" # Specify the account to run the script

$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-NonInteractive -WindowStyle Hidden -File D:\Scripts\Personal\Endpoint\Win11\OneDrive\stop_OneDrive.ps1"

Register-ScheduledTask -TaskName "Stop OneDrive" -Trigger $Trigger -User $User -Action $Action -RunLevel Highest –Force