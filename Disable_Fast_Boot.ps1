$fastBootKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"

$fastBootKey = Get-ItemProperty -Path $fastBootKeyPath

if ($fastbootkey.hiberbootEnabled -eq '0')
{
    Write-Output "Already Disabled"
}
Else
{
    Set-ItemProperty -Path $fastBootKeyPath -Name hiberbootEnabled -Value "0" -Type DWORD
}