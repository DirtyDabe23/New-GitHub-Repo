$dir = 'C:\_Windows_FU\packages'

mkdir $dir

$webClient = New-Object System.Net.WebClient

$url = 'https://go.microsoft.com/fwlink/?linkid=2171764'

$file = "$($dir)\Win11Upgrade.exe"

$webClient.DownloadFile($url,$file)

Start-Process -FilePath $file -ArgumentList '/quiet', '/auto upgrade', '/EULA accept', '/copylogs $dir'