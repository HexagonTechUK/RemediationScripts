<#
.SYNOPSIS
    Automates installation of AZ modules, connects to Azure and dowloads files from the storage container.

.DESCRIPTION
    This script checks for and installs necessary PowerShell modules required for interacting with Azure services. It goes on to retrieve
    files from the Azure storage container and downloads them to the local system.

.EXAMPLE
    .\Set-ScreensaverSlideshow[Remediation].ps1

.NOTES
    Author: Neil Knight, Persimmon Homes
    Last Edit: 2025-02-12
    Version: 1.3
#>

# Define Variables (complete these)

$deployType  = "Set" # Deployment type: Install, Upgrade, Removal
$productName = "ScreensaverSlideshow-Remediation" # Application name for logfile and installation
$logFileName = Join-Path $env:ProgramData "PH\$deployType-$productName.log" # Define path for logging

# Start logging

Start-Transcript -Path $logFileName

# Function to get logged-on users
function Get-LoggedOnUsers {
    [CmdletBinding()]
    param(
        # If $server is not specified, runs against the local machine
        $server
    )

    $header = @('USERNAME', 'SESSIONNAME', 'ID', 'STATE', 'IDLE TIME', 'LOGON TIME')

    try {
        $result = if ($server) { query user /server:$server } else { query user }

        # Determine column indexes dynamically
        $indexes = $header | ForEach-Object { ($result[0]).IndexOf(" $_") }

        # Process each row to a PS object, skipping the header
        for ($row = 1; $row -lt $result.Count; $row++) {
            $obj = New-Object psobject

            for ($i = 0; $i -lt $header.Count; $i++) {
                $begin = $indexes[$i]
                $end = if ($i -lt $header.Count - 1) { $indexes[$i+1] } else { $result[$row].length }

                $obj | Add-Member NoteProperty $header[$i] ($result[$row].substring($begin, $end-$begin)).Trim()
            }

            Write-Output $obj
        }
    }
    catch {
        # Handle query failure
        if ($_.Exception.Message -ne 'No User exists for *') {
            Write-Error $_.Exception.Message
        }
    }
}

# Set working directory to script root
Set-Location -Path $PSScriptRoot

# Obtain install command line
$productName = "ScreensaverSlideshow[Remediation]"

# Get information about logged-on user
$userInfo = Get-LoggedOnUsers
$username = $userInfo.USERNAME

# Check if $env:HomeDrive or $username are null or empty
if (-not $env:HomeDrive) {
    Write-Host "Error: HomeDrive is null or empty."
}

if (-not $username) {
    Write-Host "Error: Username is null or empty."
}

# If both variables are not null or empty, proceed with Join-Path
if ($env:HomeDrive -and $username) {
    $userProfilePath = Join-Path -Path ($env:HomeDrive, "users", $username) -ChildPath "\"
}

$loggedOnUser = Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\SessionData\$($userInfo.ID)" -Name LoggedOnUser -ErrorAction SilentlyContinue 

# Output user profile path and logged-on user name
Write-Host $userProfilePath
Write-Host $loggedOnUser

<# Check if NuGet is installed, if not, install it
Register-PackageSource -Name NuGet.org -Location https://www.nuget.org/api/v2/ -ProviderName NuGet -Trusted -Force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Define required modules
$requiredModules = @("Az.Accounts", "Az.Storage", "AzureAD")

# Install required modules if not already installed
foreach ($module in $requiredModules) {
    if (-not (Get-Module -Name $module -ListAvailable)) {
        Install-Module -Name $module -Force -Confirm:$false -Scope AllUsers
        Import-Module -Name $module -Force
    }
}#>

# Define credentials
$securePassword = ConvertTo-SecureString -String "" -AsPlainText -Force
$tenantId = ''
$subscriptionID = ''
$applicationId = ''
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationId, $securePassword

# Connect to Azure
Connect-AzAccount -ServicePrincipal -TenantId $tenantId -SubscriptionID $subscriptionID -Credential $credential

# Define variables
$destFolder = "C:\ProgramData\PH\Screensavers"
$storageAccountName = "staprdopspubfilesuks001"
$resourceGroupName = "RG-PRD-OPS-PUBLICFILES-UKS-001"
$containerName = "images"
$blobPrefix = "Screensavers/"

# Create destination folder if it doesn't exist
if (-not (Test-Path $destFolder)) {
    New-Item -ItemType Directory -Path $destFolder -Verbose
}

# Get storage context
$context = Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName -Verbose |
           Select-Object -ExpandProperty Context

# Function to update screensavers
function UpdateScreensavers {
    # Delete the Screensavers folder and recreate a new one.
    Remove-Item -Path $destFolder -Recurse -Force -Verbose
    New-Item -ItemType Directory -Path $destFolder -Verbose
    
    # Get list of blobs
    $blobs = Get-AzStorageBlob -Container $containerName -Context $context -Prefix $blobPrefix

    # Process each blob
    foreach ($blob in $blobs) {
        $blobName = $blob.Name.Substring($blob.Name.LastIndexOf('/') + 1)

        # Download the blob
        $localFilePath = Join-Path -Path $destFolder -ChildPath $blobName
        Get-AzStorageBlobContent -Blob $blob.Name -Container $containerName -Context $context -Destination $localFilePath -Verbose
        Write-Output "Downloaded: $blobName"        
    }
}

# Call the function to update screensavers
UpdateScreensavers

# Conclude logging
Stop-Transcript