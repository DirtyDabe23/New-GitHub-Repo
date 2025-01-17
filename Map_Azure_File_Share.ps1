$keyPathLSA = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"

Set-ItemProperty -Path $keyPathLSA -Name 'lmcompatibilitylevel' -Value '3' -Type 'DWord' -Force

$connectTestResult = Test-NetConnection -ComputerName ttprodfileshare.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Mount the drive
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\\ttprodfileshare.file.core.windows.net\ttprodfileshare" -Persist
} else {
    Write-Error -Message "Unable to reach the Azure storage account via port 445. Check to make sure your organization or ISP is not blocking port 445, or use Azure P2S VPN, Azure S2S VPN, or Express Route to tunnel SMB traffic over a different port."
}