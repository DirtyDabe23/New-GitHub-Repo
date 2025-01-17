if(!(Get-AppXPackage -name Microsoft.DesktopAppInstaller)){Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe}
if (!(Get-PackageProvider -Name PowerShellGet)){Install-PackageProvider WinGet -Force}
$wingetPackages = Get-WinGetPAckage
$devProgs = "Microsoft.WindowsTerminal" , "Microsoft.VisualStudioCode" , "Microsoft.VisualStudio.2022.Enterprise"
$missingProgs = @()
forEach ($devProg in $devProgs){if ($devProg -notin $wingetPackages.id){winget install --id $devProg}}
$reqExtensions = @("github.codespaces",`
"github.vscode-pull-request-github",`
"dillonchanis.midnight-city",`
"ms-python.debugpy",`
"ms-python.python",`
"ms-python.python",`
"ms-python.python",`
"ms-python.python",`
"ms-python.vscode-pylance",`
"ms-toolsai.jupyter",`
"ms-toolsai.jupyter-keymap",`
"ms-toolsai.jupyter-renderers",`
"ms-toolsai.vscode-jupyter-cell-tags",`
"ms-toolsai.vscode-jupyter-slideshow",`
"ms-vscode-remote.remote-wsl",`
"ms-vscode.notepadplusplus-keybindings",`
"ms-vscode.powershell",`
"ms-vscode.vscode-github-issue-notebooks")
$currentExtensions = code --list-extensions
ForEach($reqExtension in $reqExtensions){if ($reqExtension -notin $currentExtensions){code --install-extension $reqExtension}}