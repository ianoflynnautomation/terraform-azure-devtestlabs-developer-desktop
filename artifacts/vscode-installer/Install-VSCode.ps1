# This script downloads and installs the latest VS Code System Installer

$sourceUrl = "https://update.code.visualstudio.com/latest/win32-x64-user/stable"
$downloadPath = "$env:TEMP\VSCodeSetup.exe"

Write-Host "Downloading Visual Studio Code..."
Invoke-WebRequest -Uri $sourceUrl -OutFile $downloadPath

Write-Host "Installing Visual Studio Code silently..."
# /VERYSILENT and /MERGETASKS are standard flags for Inno Setup installers.
# The tasks enable 'Add to PATH' and context menu integration.
$installArgs = '/VERYSILENT /MERGETASKS="!runcode,addtopath,addcontextmenufiles,addcontextmenufolders,associatewithfiles"'
Start-Process -FilePath $downloadPath -ArgumentList $installArgs -Wait

Write-Host "Visual Studio Code installation complete."
Remove-Item -Path $downloadPath