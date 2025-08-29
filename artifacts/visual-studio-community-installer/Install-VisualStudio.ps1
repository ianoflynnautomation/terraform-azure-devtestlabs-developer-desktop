param (
    # Parameter to accept a space-separated string of workload IDs
    [string]$Workloads = "Microsoft.VisualStudio.Workload.ManagedDesktop"
)

# The official download link for the VS 2022 Community bootstrapper
$sourceUrl = "https://aka.ms/vs/17/release/vs_community.exe"
$downloadPath = "$env:TEMP\vs_community.exe"

Write-Host "Downloading the Visual Studio 2022 Community installer..."
Invoke-WebRequest -Uri $sourceUrl -OutFile $downloadPath

$baseArgs = "--quiet --wait --norestart"

$workloadArgs = ""
$Workloads.Split(' ') | ForEach-Object {
    if (-not [string]::IsNullOrWhiteSpace($_)) {
        $workloadArgs += " --add $_"
    }
}

$finalArgs = "$baseArgs$workloadArgs --includeRecommended"

Write-Host "Starting Visual Studio installation with the following workloads: $Workloads"
Write-Host "This will take a significant amount of time. Please be patient."
Write-Host "Executing: $downloadPath $finalArgs"

Start-Process -FilePath $downloadPath -ArgumentList $finalArgs -Wait

Write-Host "Visual Studio 2022 Community installation is complete."
Remove-Item -Path $downloadPath