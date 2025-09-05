[CmdletBinding()]
param(
    [string] $jmeterVersion = '5.6.3',
    [string] $jdkVersion = '17.0.10+7',
    [string] $installDrive = 'C'
)

# --- Script Configuration ---
$ErrorActionPreference = "Stop"
Set-PSDebug -Strict
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- Installation Paths ---
$installRoot = "${installDrive}:\"
$jmeterInstallDir = Join-Path $installRoot "apache-jmeter-${jmeterVersion}"
$jdkInstallDir = Join-Path $installRoot "openjdk"

# --- Main Execution Block ---
try {
    Write-Host "Starting JMeter installation process..."

    # --- 1. Install OpenJDK (Prerequisite) ---
    Write-Host "Installing OpenJDK version $jdkVersion..."

    # Construct OpenJDK Download URL
    $jdkMajorVersion = ($jdkVersion.Split('.'))[0]
    $jdkUrlVersion = $jdkVersion.Replace('+', '%2B')
    $jdkFileNameVersion = $jdkVersion.Replace('+', '_')
    $jdkDownloadUrl = "https://github.com/adoptium/temurin${jdkMajorVersion}-binaries/releases/download/jdk-${jdkUrlVersion}/OpenJDK${jdkMajorVersion}U-jdk_x64_windows_hotspot_${jdkFileNameVersion}.zip"
    $jdkZipPath = Join-Path $env:TEMP "openjdk.zip"

    # Download and Extract OpenJDK
    Write-Host "Downloading OpenJDK from $jdkDownloadUrl"
    Invoke-WebRequest -Uri $jdkDownloadUrl -OutFile $jdkZipPath
    Write-Host "Extracting OpenJDK to $jdkInstallDir"
    Expand-Archive -Path $jdkZipPath -DestinationPath $jdkInstallDir -Force
    $jdkExtractedFolder = (Get-ChildItem -Path $jdkInstallDir | Select-Object -First 1).FullName
    
    # Set JAVA_HOME environment variable
    Write-Host "Setting JAVA_HOME environment variable to $jdkExtractedFolder"
    [System.Environment]::SetEnvironmentVariable('JAVA_HOME', $jdkExtractedFolder, 'Machine')
    
    # --- 2. Install Apache JMeter ---
    Write-Host "Installing Apache JMeter version $jmeterVersion..."

    # Construct JMeter Download URL
    $jmeterDownloadUrl = "https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${jmeterVersion}.zip"
    $jmeterZipPath = Join-Path $env:TEMP "jmeter.zip"

    # Download and Extract JMeter
    Write-Host "Downloading JMeter from $jmeterDownloadUrl"
    Invoke-WebRequest -Uri $jmeterDownloadUrl -OutFile $jmeterZipPath
    Write-Host "Extracting JMeter to $installRoot"
    Expand-Archive -Path $jmeterZipPath -DestinationPath $installRoot -Force

    # --- 3. Update System Path ---
    Write-Host "Updating system Path environment variable..."
    $jmeterBinPath = Join-Path $jmeterInstallDir "bin"
    $jdkBinPath = Join-Path $jdkExtractedFolder "bin"
    
    $currentPath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $newPath = "$($currentPath);$($jdkBinPath);$($jmeterBinPath)"
    [System.Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine')
    
    # --- 4. Create Desktop Shortcut ---
    Write-Host "Creating JMeter desktop shortcut..."
    $shell = New-Object -ComObject WScript.Shell
    $shortcutPath = Join-Path ([System.Environment]::GetFolderPath('CommonDesktopDirectory')) 'JMeter.lnk'
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = Join-Path $jmeterBinPath "jmeter.bat"
    $shortcut.IconLocation = Join-Path $jmeterBinPath "jmeter.ico"
    $shortcut.Description = "Launch Apache JMeter"
    $shortcut.Save()

    Write-Host "`nSUCCESS: The artifact was applied successfully."

}
catch {
    Write-Host "ERROR: An error occurred during installation."
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}