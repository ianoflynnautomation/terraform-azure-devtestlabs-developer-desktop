[CmdletBinding()]
param (
    # Optional: The immutable ID of a Data Collection Rule to associate with the agent.
    [string]$dataCollectionRuleId
)

# --- Script Configuration ---
$ErrorActionPreference = "Stop"
$sourceUrl = "https://aka.ms/AzureMonitorAgent-Win"
$downloadPath = Join-Path $env:TEMP "AzureMonitorAgent.msi"

# --- Main Execution Block ---
try {
    # Check if the agent is already installed to provide better logging
    if (Get-Package -Name "Azure Monitor Agent" -ErrorAction SilentlyContinue) {
        Write-Host "Azure Monitor Agent is already installed. The installer will perform an update if a newer version is available."
    } else {
        Write-Host "Azure Monitor Agent not found. Starting fresh installation."
    }

    # 1. Download the agent installer
    Write-Host "Downloading the Azure Monitor Agent installer from $sourceUrl..."
    Invoke-WebRequest -Uri $sourceUrl -OutFile $downloadPath

    # 2. Install the agent silently
    Write-Host "Installing the agent... This might take a few minutes."
    $msiArgs = @(
        "/i", "`"$downloadPath`"",
        "/qn" # Quiet mode, no UI
    )
    Start-Process msiexec.exe -ArgumentList $msiArgs -Wait -PassThru

    Write-Host "Agent installation process completed."

    # 3. (Optional) Associate with a Data Collection Rule
    if (-not [string]::IsNullOrWhiteSpace($dataCollectionRuleId)) {
        Write-Host "Associating agent with Data Collection Rule ID: $dataCollectionRuleId"
        
        $configToolPath = "C:\Program Files\AzureConnectedMachineAgent\AzureMonitorAgentExtension\AzureMonitorAgentExtension.exe"
        if (Test-Path $configToolPath) {
            & $configToolPath config --dcr-id $dataCollectionRuleId
            Write-Host "Successfully initiated DCR association."
        } else {
            Write-Warning "Configuration tool not found at '$configToolPath'. Skipping DCR association."
        }
    }

    Write-Host "`nSUCCESS: The Azure Monitor Agent artifact was applied successfully."

} catch {
    Write-Error "An error occurred during the installation process: $_"
    # Exit with a non-zero code to indicate failure to DevTest Labs
    exit 1
} finally {
    # Clean up the downloaded installer file
    if (Test-Path $downloadPath) {
        Write-Host "Cleaning up installer file..."
        Remove-Item -Path $downloadPath -Force
    }
}