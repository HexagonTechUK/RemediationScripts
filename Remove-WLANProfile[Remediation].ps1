<#
.SYNOPSIS
	PowerShell script to remove PSN-Corp WLAN profile

.DESCRIPTION
	This script uses NETSH to remove  the PSN-Corp WLAN
    profile from cache.

.EXAMPLE
    .\Remove-WLANProfile[Remediation].ps1

.NOTES
    Author: Paul Gosling, Persimmon Homes
    Last Edit: 2024-10-29
    Version: 1.0
#>

# Variables (complete these):
$deployType     = "Remove"    #-------------------------------------------------# Deployment type: Install, Upgrade, Removal
$productName    = "WlanProfile"   #---------------------------------------------# Application name for logfile
$logFileName    = Join-Path $env:ProgramData "PH\$deployType-$productName.log"  #---# Path to app logfile

# Start logging
Start-Transcript -Path $logFileName

# Attempt to remove the 'PSN-Corp' profile
netsh wlan delete profile name="PSN-Corp"

# Conclude logging
Stop-Transcript