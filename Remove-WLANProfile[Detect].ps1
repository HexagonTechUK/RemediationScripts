<#
.SYNOPSIS
	PowerShell script to detect PSN-Corp WLAN profile

.DESCRIPTION
	This script uses NETSH to determine if the PSN-Corp WLAN
    profile is present in the cache, and writes the exit code 1 if found.

.EXAMPLE
    .\Remove-WLANProfile[Detect].ps1

.NOTES
    Author: Paul Gosling, Persimmon Homes
    Last Edit: 2024-10-29
    Version: 1.0
#>

# Variables (complete these):
$deployType     = "Detect"    #-------------------------------------------------# Deployment type: Install, Upgrade, Removal
$productName    = "WlanProfile"   #---------------------------------------------# Application name for logfile
$logFileName    = Join-Path $env:ProgramData "PH\$deployType-$productName.log"  #---# Path to app logfile

# Start logging
Start-Transcript -Path $logFileName

# Check if the 'PSN-Corp' profile exists
$wifiProfile = netsh wlan show profiles | Select-String -Pattern "PSN-Corp"

if ($wifiProfile) {
    Write-Host "WiFi profile 'PSN-Corp' found."
    # Exit with code 1 to indicate that the profile was found
    exit 1
} else {
    Write-Host "WiFi profile 'PSN-Corp' not found."
    # Exit with code 0 to indicate no issue
    exit 0
}

# Conclude logging
Stop-Transcript