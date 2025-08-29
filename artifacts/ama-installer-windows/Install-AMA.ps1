# This script downloads and installs the Azure Monitor Agent for Windows.

$sourceUrl = "https://aka.ms/AzureMonitorAgent-Win"
$downloadPath = "$env:TEMP\AzureMonitorAgent.msi"

Write-Host "Downloading the Azure Monitor Agent for Windows..."
Invoke-WebRequest -Uri $sourceUrl -OutFile $downloadPath

Write-Host "Installing the Azure Monitor Agent silently..."
# /qn flag ensures a quiet, no-UI installation.
Start-Process msiexec.exe -ArgumentList "/i `"$downloadPath`" /qn" -Wait

Write-Host "Azure Monitor Agent installation complete."
Remove-Item -Path $downloadPath