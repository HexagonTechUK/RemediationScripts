# Define the log file path
$LogFolderPath = "C:\ProgramData\PH\"
$LogFilePath = "C:\ProgramData\PH\bloatwareremoval.log"

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

$InstalledPackages = Get-AppxPackage -AllUsers `
            | Where-Object {($UninstallPackages -contains $_.Name) -or ($_.Name -match "^$HPidentifier")}

$ProvisionedPackages = Get-AppxProvisionedPackage -Online `
            | Where-Object {($UninstallPackages -contains $_.DisplayName) -or ($_.DisplayName -match "^$HPidentifier")}

$InstalledPrograms = Get-Package | Where-Object {$UninstallPrograms -contains $_.Name}

# Removal process
ForEach ($ProvPackage in $ProvisionedPackages) {
    Write-Host -Object "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."
    Try {
        $Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction SilentlyContinue
        Write-Host -Object "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
    }
    Catch {
        Write-Warning -Message "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"
    }
}

ForEach ($AppxPackage in $InstalledPackages) {
    Write-Host -Object "Attempting to remove Appx package: [$($AppxPackage.Name)]..."
    Try {
        $Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction SilentlyContinue
        Write-Host -Object "Successfully removed Appx package: [$($AppxPackage.Name)]"
    }
    Catch {
        Write-Warning -Message "Failed to remove Appx package: [$($AppxPackage.Name)]"
    }
}

$InstalledPrograms | ForEach-Object {
    Write-Host -Object "Attempting to uninstall: [$($_.Name)]..."
    Try {
        $Null = $_ | Uninstall-Package -AllVersions -Force -ErrorAction SilentlyContinue
        Write-Host -Object "Successfully uninstalled: [$($_.Name)]"
    }
    Catch {
        Write-Warning -Message "Failed to uninstall: [$($_.Name)]"
    }
}
Write-Host "Attempting to remove bloatware."
    Exit 1 # Exit with no error code to indicate no detection
# Fallback attempts to remove HP Wolf Security using msiexec are removed as per your instructions
