# This script downloads and installs the latest IntelliJ IDEA Community Edition

$sourceUrl = "https://download.jetbrains.com/idea/ideaIC.exe"
$downloadPath = "$env:TEMP\ideaIC.exe"

Write-Host "Downloading IntelliJ IDEA Community Edition..."
Invoke-WebRequest -Uri $sourceUrl -OutFile $downloadPath

Write-Host "Installing IntelliJ IDEA silently... This may take a few minutes."
# The /S flag enables a silent (quiet) installation.
Start-Process -FilePath $downloadPath -ArgumentList "/S" -Wait

Write-Host "IntelliJ IDEA installation complete."
Remove-Item -Path $downloadPath