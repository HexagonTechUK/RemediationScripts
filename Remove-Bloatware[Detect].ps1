# Define the log file path
$LogFolderPath = "C:\ProgramData\PH\"
$LogFilePath = "C:\ProgramData\PH\bloatwareremoval_detection.log"

# Ensure the log folder exists; if not, create it
If (-not (Test-Path -Path $LogFolderPath)) {
    New-Item -Path $LogFolderPath -ItemType Directory | Out-Null
}

# List of built-in apps to remove
$UninstallPackages = @(
    "AD2F1837.HPJumpStarts"
    "AD2F1837.HPPCHardwareDiagnosticsWindows"
    "AD2F1837.HPPowerManager"
    "AD2F1837.HPPrivacySettings"
    "AD2F1837.HPSupportAssistant"
    "AD2F1837.HPSureShieldAI"
    "AD2F1837.HPQuickDrop"
    "AD2F1837.HPWorkWell"
    "AD2F1837.myHP"
    "AD2F1837.HPDesktopSupportUtilities"
    "AD2F1837.HPQuickTouch"
    "AD2F1837.HPEasyClean"
    "AD2F1837.HPSystemInformation"
    "Microsoft.Windows.DevHome",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.OneConnect",
    "Microsoft.SkypeApp",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"
)

# List of programs to uninstall
$UninstallPrograms = @(
    "HP Client Security Manager"
	"HP Smart"		  
    "HP Connection Optimizer"
    "HP Documentation"
    "HP MAC Address Manager"
    "HP Notifications"
    "HP Security Update Service"
    "HP System Default Settings"
    "HP Sure Click"
    "HP Sure Click Security Browser"
    "HP Sure Run"
    "HP Sure Recover"
    "HP Sure Sense"
    "HP Sure Sense Installer"
    "HP Wolf Security"
    "HP Wolf Security Application Support for Sure Sense"
    "HP Wolf Security Application Support for Windows"
)

$HPidentifier = "AD2F1837"

# Detection logic for Appx packages and programs
$InstalledPackages = Get-AppxPackage -AllUsers | Where-Object {
    ($UninstallPackages -contains $_.Name) -or ($_.Name -match "^$HPidentifier")
}

$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object {
    ($UninstallPackages -contains $_.DisplayName) -or ($_.DisplayName -match "^$HPidentifier")
}

$InstalledPrograms = Get-Package | Where-Object {
    $UninstallPrograms -contains $_.Name
}

# Check and log each type of bloatware detected
if ($InstalledPackages -or $ProvisionedPackages -or $InstalledPrograms) {
        
    if ($InstalledPackages) {
        $InstalledPackages | ForEach-Object { Write-Host "`t$($_.Name)" }
    }
    
    if ($ProvisionedPackages) {
        $ProvisionedPackages | ForEach-Object { Write-Host "`t$($_.DisplayName)" }
    }

    if ($InstalledPrograms) {
        $InstalledPrograms | ForEach-Object { Write-Host "`t$($_.Name)" }
    }

    Write-Host "Bloatware detected, running remediation."
    Exit 1 # Exit with error code to indicate detection
} else {
    Write-Host "No bloatware detected."
    Stop-Transcript
    Exit 0 # Exit with no error code to indicate no detection
}
