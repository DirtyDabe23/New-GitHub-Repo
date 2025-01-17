Invoke-WebRequest  "https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/PowerShell-7.2.4-win-x64.msi" -Outfile C:\Scripts\PS7.msi
Start-Process C:\Scripts\PS7.msi -ArgumentList "/qn"