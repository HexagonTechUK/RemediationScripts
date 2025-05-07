function Get-Shortcuts ($shortcut) {
    if ($shortcut.Icon) {
        $icon = Test-Path $shortcut.Icon
        #Write-Host $shortcut.Icon
        }
    if ($shortcut.Path) {
        $path = Test-Path $shortcut.Path
        #Write-Host $shortcut.Path
        }
        

    if (-not $icon -or -not $path) {
        Write-Output "At least one icon or URL missing."
        exit 1 
    }
    
}

$urlShortcuts = @(
    @{Path="C:\Users\Public\Desktop\Access.url"; 				 URL="https://persimmonhomes-hr.accessacloud.com/SelectHR/Login.aspx?useSso=n"; 	Icon="C:\Windows\icons\AccessHR.ico"},
    @{Path="C:\Users\Public\Desktop\IT Self Service Portal.url"; URL="https://live.hornbill.com/persimmonhomes"; 									Icon="C:\Windows\icons\Hornbill.ico"},
    @{Path="C:\Users\Public\Desktop\My Persimmon.url"; 			 URL="https://mypersi.persimmonhomes.com";	 										Icon="C:\Windows\icons\intranet.ico"},
    @{Path="C:\Users\Public\Desktop\COINS ERP+.url"; 			 URL="https://persimmonhomes.coinscloud.com/env/live/wologin.p?type=token&idp=aad";	Icon="C:\Windows\icons\AccessCoins.ico"},
    @{Path="C:\Users\Public\Desktop\Soils Register.url"; 		 URL="https://soilsregister.persimmonhomes.com"; 									Icon="C:\Windows\icons\SoilsRegister.ico"},
    @{Path="C:\Users\Public\Desktop\Document Management.url"; 	 URL="https://docs.persimmonhomes.com"; 											Icon="C:\Windows\icons\DocMgmt.ico"}
)

$appShortcuts = @(
    @{Path="C:\Users\Public\Desktop\Excel.lnk";	  Target="C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"; 	Icon="C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"},
    @{Path="C:\Users\Public\Desktop\Word.lnk";	  Target="C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"; Icon="C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"},
    @{Path="C:\Users\Public\Desktop\Outlook.lnk"; Target="C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"; Icon="C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"}
)

foreach ($url in $urlShortcuts) {
    Get-Shortcuts($url)
}
foreach ($app in $appShortcuts) {
    Get-Shortcuts($app)
}

Write-Output "All icons and URLs present."
exit 0