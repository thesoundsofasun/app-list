# Requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host " Starting Advanced Setup Utility..." -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "1. Scanning PC for installed apps..." -ForegroundColor Yellow
$InstalledAppsString = & winget list --accept-source-agreements | Out-String

Write-Host "2. Checking for available app updates..." -ForegroundColor Yellow
$UpgradableAppsString = & winget upgrade --accept-source-agreements | Out-String
Write-Host "Scan complete! Opening User Interface..." -ForegroundColor Green

# 1. Define your list of applications here
$AppList = @(
    [pscustomobject]@{ Category = "Archivator"; Name = "NanaZip"; Id = "M2Team.NanaZip" }
    [pscustomobject]@{ Category = "Audio Redactors"; Name = "VCV Rack"; Id = "VCVRack.VCVRack" }
    [pscustomobject]@{ Category = "Browser"; Name = "Mozilla Firefox"; Id = "Mozilla.Firefox" }
    [pscustomobject]@{ Category = "Graphic Redactors"; Name = "Affinity Studio"; Id = "Canva.Affinity" }
    [pscustomobject]@{ Category = "Graphic Redactors"; Name = "GIMP"; Id = "GIMP.GIMP.3" }
    [pscustomobject]@{ Category = "3D Redactors"; Name = "Blender"; Id = "BlenderFoundation.Blender" }
    [pscustomobject]@{ Category = "Development"; Name = "Git"; Id = "Git.Git" }
    [pscustomobject]@{ Category = "Development"; Name = "Python 3"; Id = "Python.Python.3.11" }
    [pscustomobject]@{ Category = "Multimedia"; Name = "qView"; Id = "jurplel.qView" }
    [pscustomobject]@{ Category = "Office Suite"; Name = "OnlyOffice"; Id = "ONLYOFFICE.DesktopEditors" }
    [pscustomobject]@{ Category = "Screen Capture"; Name = "OBS Studio"; Id = "OBSProject.OBSStudio" }
    [pscustomobject]@{ Category = "Text Editor"; Name = "Sublime Text"; Id = "SublimeHQ.SublimeText.4" }
    [pscustomobject]@{ Category = "Utilities"; Name = "BleachBit"; Id = "BleachBit.BleachBit" }
    [pscustomobject]@{ Category = "Utilities"; Name = "Everything"; Id = "voidtools.Everything" }
    [pscustomobject]@{ Category = "Utilities"; Name = "KeePassXC"; Id = "KeePassXCTeam.KeePassXC" }
    [pscustomobject]@{ Category = "Utilities"; Name = "Local Send"; Id = "LocalSend.LocalSend" }
    [pscustomobject]@{ Category = "Utilities"; Name = "MSI Afterburner"; Id = "Guru3D.Afterburner" }
    [pscustomobject]@{ Category = "Utilities"; Name = "qBittorrent"; Id = "qBittorrent.qBittorrent" }
)

# Parse Winget Data into our AppList
foreach ($App in $AppList) {
    $App | Add-Member -MemberType NoteProperty -Name "IsInstalled" -Value ($InstalledAppsString -match [regex]::Escape($App.Id))
    $App | Add-Member -MemberType NoteProperty -Name "HasUpdate" -Value ($UpgradableAppsString -match [regex]::Escape($App.Id))
}

# --- DARK MODE COLORS & STYLES ---
$BgColor      = [System.Drawing.Color]::FromArgb(32, 32, 32)   
$CardBgColor  = [System.Drawing.Color]::FromArgb(45, 45, 48)   
$TextColor    = [System.Drawing.Color]::White
$NeutralBtn   = [System.Drawing.Color]::FromArgb(70, 70, 70)
$AnchorAll    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$AnchorBottom = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left

# 2. Setup the GUI Window (Slightly taller to fit the new button)
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Advanced Package Manager Utility"
$Form.ClientSize = New-Object System.Drawing.Size(850, 740) # Increased height
$Form.MinimumSize = New-Object System.Drawing.Size(600, 600)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = 'Sizable' 
$Form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$Form.BackColor = $BgColor     
$Form.ForeColor = $TextColor   

$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Select applications to manage (Responsive Grid Layout):"
$Label.Location = New-Object System.Drawing.Point(20, 10)
$Label.Size = New-Object System.Drawing.Size(400, 25)
$Form.Controls.Add($Label)

# ==========================================
# RESPONSIVE GRID LAYOUT FOR CATEGORIES
# ==========================================
$FlowPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$FlowPanel.Location = New-Object System.Drawing.Point(20, 40)
$FlowPanel.Size = New-Object System.Drawing.Size(810, 465)
$FlowPanel.Anchor = $AnchorAll
$FlowPanel.AutoScroll = $true
$FlowPanel.WrapContents = $true
$FlowPanel.FlowDirection = 'LeftToRight'
$Form.Controls.Add($FlowPanel)

$script:AppCheckboxes = @() # Array to hold all checkbox objects

$Categories = $AppList | Select-Object -ExpandProperty Category -Unique | Sort-Object
foreach ($Cat in $Categories) {
    
    $GroupBox = New-Object System.Windows.Forms.GroupBox
    $GroupBox.Text = "📂 $Cat"
    $GroupBox.ForeColor = [System.Drawing.Color]::Cyan
    $GroupBox.Width = 250
    $GroupBox.AutoSize = $true
    $GroupBox.MinimumSize = New-Object System.Drawing.Size(250, 50)
    $GroupBox.Margin = New-Object System.Windows.Forms.Padding(5, 5, 10, 10)

    $InnerFlow = New-Object System.Windows.Forms.FlowLayoutPanel
    $InnerFlow.FlowDirection = 'TopDown'
    $InnerFlow.AutoSize = $true
    $InnerFlow.WrapContents = $false
    $InnerFlow.Dock = 'Fill'
    $InnerFlow.Padding = New-Object System.Windows.Forms.Padding(5, 10, 5, 5)

    $SelectAllChk = New-Object System.Windows.Forms.CheckBox
    $SelectAllChk.Text = "Select All in Category"
    $SelectAllChk.ForeColor = [System.Drawing.Color]::Gold
    $SelectAllChk.AutoSize = $true
    $SelectAllChk.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
    $InnerFlow.Controls.Add($SelectAllChk)
    
    $SelectAllChk.Add_Click({
        $Sender = $this
        $ParentFlow = $Sender.Parent
        foreach ($Ctrl in $ParentFlow.Controls) {
            if ($Ctrl -is [System.Windows.Forms.CheckBox] -and $Ctrl -ne $Sender) {
                $Ctrl.Checked = $Sender.Checked
            }
        }
    })

    $AppsInCat = $AppList | Where-Object Category -eq $Cat | Sort-Object Name
    foreach ($App in $AppsInCat) {
        $Chk = New-Object System.Windows.Forms.CheckBox
        if ($App.HasUpdate) {
            $Chk.Text = "⬆️ " + $App.Name
            $Chk.ForeColor = [System.Drawing.Color]::LightGreen
        } elseif ($App.IsInstalled) {
            $Chk.Text = "✅ " + $App.Name
            $Chk.ForeColor = [System.Drawing.Color]::White
        } else {
            $Chk.Text = "❌ " + $App.Name
            $Chk.ForeColor = [System.Drawing.Color]::Silver
        }
        $Chk.Tag = $App
        $Chk.AutoSize = $true
        $Chk.Margin = New-Object System.Windows.Forms.Padding(3, 3, 3, 3)
        
        $InnerFlow.Controls.Add($Chk)
        $script:AppCheckboxes += $Chk
    }

    $GroupBox.Controls.Add($InnerFlow)
    $FlowPanel.Controls.Add($GroupBox)
}

# ==========================================
# HELPER FUNCTIONS
# ==========================================
function Get-SelectedApps {
    $Selected = @()
    foreach ($Chk in $script:AppCheckboxes) {
        if ($Chk.Checked) { $Selected += $Chk.Tag }
    }
    return $Selected
}

function Select-GlobalNodes ($Condition) {
    foreach ($Chk in $script:AppCheckboxes) {
        $App = $Chk.Tag
        if ($Condition -eq "None") { $Chk.Checked = $false } 
        elseif ($Condition -eq "Missing") { $Chk.Checked = -not $App.IsInstalled } 
        elseif ($Condition -eq "Installed") { $Chk.Checked = $App.IsInstalled } 
        elseif ($Condition -eq "Updates") { $Chk.Checked = $App.HasUpdate }
    }
}


# ==========================================
# AUTO-SELECTION BUTTONS (ANCHORED BOTTOM)
# ==========================================
$BtnSelectMissing = New-Object System.Windows.Forms.Button
$BtnSelectMissing.Text = "Select Missing"
$BtnSelectMissing.Location = New-Object System.Drawing.Point(20, 520)
$BtnSelectMissing.Size = New-Object System.Drawing.Size(195, 30)
$BtnSelectMissing.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnSelectMissing.BackColor = $NeutralBtn
$BtnSelectMissing.Anchor = $AnchorBottom
$BtnSelectMissing.Add_Click({ Select-GlobalNodes "Missing" })
$Form.Controls.Add($BtnSelectMissing)

$BtnSelectInstalled = New-Object System.Windows.Forms.Button
$BtnSelectInstalled.Text = "Select Installed"
$BtnSelectInstalled.Location = New-Object System.Drawing.Point(225, 520)
$BtnSelectInstalled.Size = New-Object System.Drawing.Size(195, 30)
$BtnSelectInstalled.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnSelectInstalled.BackColor = $NeutralBtn
$BtnSelectInstalled.Anchor = $AnchorBottom
$BtnSelectInstalled.Add_Click({ Select-GlobalNodes "Installed" })
$Form.Controls.Add($BtnSelectInstalled)

$BtnSelectUpdates = New-Object System.Windows.Forms.Button
$BtnSelectUpdates.Text = "Select Updates"
$BtnSelectUpdates.Location = New-Object System.Drawing.Point(430, 520)
$BtnSelectUpdates.Size = New-Object System.Drawing.Size(195, 30)
$BtnSelectUpdates.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnSelectUpdates.BackColor = $NeutralBtn
$BtnSelectUpdates.Anchor = $AnchorBottom
$BtnSelectUpdates.Add_Click({ Select-GlobalNodes "Updates" })
$Form.Controls.Add($BtnSelectUpdates)

$BtnClearAll = New-Object System.Windows.Forms.Button
$BtnClearAll.Text = "Clear All"
$BtnClearAll.Location = New-Object System.Drawing.Point(635, 520)
$BtnClearAll.Size = New-Object System.Drawing.Size(195, 30)
$BtnClearAll.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnClearAll.BackColor = $NeutralBtn
$BtnClearAll.Anchor = $AnchorBottom
$BtnClearAll.Add_Click({ Select-GlobalNodes "None" })
$Form.Controls.Add($BtnClearAll)


# ==========================================
# ACTION ROW 1: INSTALL / UNINSTALL
# ==========================================
$InstallButton = New-Object System.Windows.Forms.Button
$InstallButton.Text = "Install Selected"
$InstallButton.Location = New-Object System.Drawing.Point(20, 560)
$InstallButton.Size = New-Object System.Drawing.Size(400, 35)
$InstallButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$InstallButton.BackColor = [System.Drawing.Color]::SeaGreen
$InstallButton.Anchor = $AnchorBottom
$InstallButton.Add_Click({
    $Form.Hide()
    $AppsToInstall = Get-SelectedApps
    Write-Host "`n=== Starting Installation ===" -ForegroundColor Cyan
    foreach ($App in $AppsToInstall) {
        Write-Host ">>> Installing $($App.Name)..." -ForegroundColor Yellow
        & winget install --id $App.Id --exact --silent --accept-package-agreements --accept-source-agreements
        if ($LastExitCode -eq 0) { Write-Host "[SUCCESS] Installed!" -ForegroundColor Green } 
    }
    Write-Host "=== Process Complete ===" -ForegroundColor Cyan
    $Form.Close()
})
$Form.Controls.Add($InstallButton)

$UninstallButton = New-Object System.Windows.Forms.Button
$UninstallButton.Text = "Uninstall Selected"
$UninstallButton.Location = New-Object System.Drawing.Point(430, 560)
$UninstallButton.Size = New-Object System.Drawing.Size(400, 35)
$UninstallButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$UninstallButton.BackColor = [System.Drawing.Color]::IndianRed
$UninstallButton.Anchor = $AnchorBottom
$UninstallButton.Add_Click({
    $Form.Hide()
    $AppsToUninstall = Get-SelectedApps
    Write-Host "`n=== Starting Uninstallation ===" -ForegroundColor Cyan
    foreach ($App in $AppsToUninstall) {
        Write-Host ">>> Uninstalling $($App.Name)..." -ForegroundColor Yellow
        & winget uninstall --id $App.Id --exact --silent
        if ($LastExitCode -eq 0) { Write-Host "[SUCCESS] Uninstalled!" -ForegroundColor Green } 
    }
    Write-Host "=== Process Complete ===" -ForegroundColor Cyan
    $Form.Close()
})
$Form.Controls.Add($UninstallButton)


# ==========================================
# ACTION ROW 2: UPGRADES
# ==========================================
$UpgradeSelectedButton = New-Object System.Windows.Forms.Button
$UpgradeSelectedButton.Text = "Upgrade Selected"
$UpgradeSelectedButton.Location = New-Object System.Drawing.Point(20, 600)
$UpgradeSelectedButton.Size = New-Object System.Drawing.Size(400, 35)
$UpgradeSelectedButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$UpgradeSelectedButton.BackColor = [System.Drawing.Color]::SteelBlue
$UpgradeSelectedButton.Anchor = $AnchorBottom
$UpgradeSelectedButton.Add_Click({
    $Form.Hide()
    $AppsToUpgrade = Get-SelectedApps
    Write-Host "`n=== Upgrading Selected Apps ===" -ForegroundColor Cyan
    foreach ($App in $AppsToUpgrade) {
        Write-Host ">>> Upgrading $($App.Name)..." -ForegroundColor Yellow
        & winget upgrade --id $App.Id --exact --silent --accept-package-agreements --accept-source-agreements
        if ($LastExitCode -eq 0) { Write-Host "[SUCCESS] Upgraded!" -ForegroundColor Green } 
        else { Write-Host "[NO UPDATE FOUND / FAILED]" -ForegroundColor DarkGray }
    }
    Write-Host "=== Process Complete ===" -ForegroundColor Cyan
    $Form.Close()
})
$Form.Controls.Add($UpgradeSelectedButton)

$UpgradeAllButton = New-Object System.Windows.Forms.Button
$UpgradeAllButton.Text = "Upgrade ALL PC Apps"
$UpgradeAllButton.Location = New-Object System.Drawing.Point(430, 600)
$UpgradeAllButton.Size = New-Object System.Drawing.Size(400, 35)
$UpgradeAllButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$UpgradeAllButton.BackColor = [System.Drawing.Color]::MediumPurple
$UpgradeAllButton.Anchor = $AnchorBottom
$UpgradeAllButton.Add_Click({
    $Form.Hide()
    Write-Host "`n=== Upgrading EVERY App on your PC ===" -ForegroundColor Cyan
    & winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown
    Write-Host "`n=== Upgrade Process Complete ===" -ForegroundColor Cyan
    $Form.Close()
})
$Form.Controls.Add($UpgradeAllButton)


# ==========================================
# ACTION ROW 3: LIST APPS & VST BATCH SCRIPT
# ==========================================
$ListAppsButton = New-Object System.Windows.Forms.Button
$ListAppsButton.Text = "List Installed Apps"
$ListAppsButton.Location = New-Object System.Drawing.Point(20, 640)
$ListAppsButton.Size = New-Object System.Drawing.Size(400, 35)
$ListAppsButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$ListAppsButton.BackColor = [System.Drawing.Color]::Teal
$ListAppsButton.Anchor = $AnchorBottom
$ListAppsButton.Add_Click({
    $ListForm = New-Object System.Windows.Forms.Form
    $ListForm.Text = "Currently Installed Applications (Winget)"
    $ListForm.Size = New-Object System.Drawing.Size(850, 500)
    $ListForm.StartPosition = "CenterParent"
    $ListForm.BackColor = $BgColor
    $ListForm.ForeColor = $TextColor

    $TextBox = New-Object System.Windows.Forms.TextBox
    $TextBox.Multiline = $true
    $TextBox.Dock = [System.Windows.Forms.DockStyle]::Fill
    $TextBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
    $TextBox.BackColor = $CardBgColor
    $TextBox.ForeColor = $TextColor
    $TextBox.ReadOnly = $true
    $TextBox.WordWrap = $false
    $TextBox.Font = New-Object System.Drawing.Font("Consolas", 10) 
    $TextBox.Text = $InstalledAppsString
    
    $ListForm.Controls.Add($TextBox)
    $ListForm.ShowDialog() | Out-Null
})
$Form.Controls.Add($ListAppsButton)


# ---> YOUR CUSTOM BATCH SCRIPT BUTTON <---
$RunBatButton = New-Object System.Windows.Forms.Button
$RunBatButton.Text = "Run VST Updater (.bat)"
$RunBatButton.Location = New-Object System.Drawing.Point(430, 640)
$RunBatButton.Size = New-Object System.Drawing.Size(400, 35)
$RunBatButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$RunBatButton.BackColor = [System.Drawing.Color]::Chocolate
$RunBatButton.Anchor = $AnchorBottom
$RunBatButton.Add_Click({
    $Form.Hide()
    Write-Host "`n=== Running Custom Batch Script ===" -ForegroundColor Cyan
    
    # We define your batch script contents inside this @" "@ block
    $BatchCode = @"
@echo off
echo Starting the VST Plugin Update Process...

:: PASTE YOUR BATCH SCRIPT CODE EXACTLY AS IT IS BELOW THIS LINE:
@echo off
setlocal

:: Your exact path to the binary inside the VST3 bundle
set "TARGET_DIR=C:\Program Files\Common Files\VST3\Airwindows\Airwindows Consolidated.vst3\Contents\x86_64-win"
set "OUTPUT_FILE=%TARGET_DIR%\Airwindows Consolidated.vst3"

:: GitHub API URL for the latest raw Win64 binary
set "URL=https://github.com"

echo Updating Airwindows Consolidated...

:: Ensure curl overwrites the exact binary file in your custom path
curl -L -o "%OUTPUT_FILE%" "%URL%"

if %ERRORLEVEL% equ 0 (
    echo.
    echo [SUCCESS] Overwrite complete. Plugin updated to the latest version.
) else (
    echo.
    echo [ERROR] Update failed. Ensure your DAW is completely closed so the file isn't locked.
)

pause
endlocal
:: STOP PASTING BATCH SCRIPT HERE
"@

    # Create a temporary bat file, run it, and delete it!
    $TempBatFile = Join-Path $env:TEMP "vst_updater_temp.bat"
    $BatchCode | Set-Content -Path $TempBatFile -Encoding ASCII
    
    # Execute the batch file in the current console
    & cmd.exe /c $TempBatFile
    
    # Clean up the file so nothing is left behind on the PC
    Remove-Item -Path $TempBatFile -Force

    Write-Host "`n=== Custom Batch Script Finished ===" -ForegroundColor Cyan
    $Form.Close()
})
$Form.Controls.Add($RunBatButton)


# ==========================================
# ACTION ROW 4: CANCEL / EXIT
# ==========================================
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Text = "Cancel / Exit"
$CancelButton.Location = New-Object System.Drawing.Point(20, 680)
$CancelButton.Size = New-Object System.Drawing.Size(810, 35) # Made full width
$CancelButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$CancelButton.BackColor = [System.Drawing.Color]::DimGray
$CancelButton.Anchor = $AnchorBottom
$CancelButton.Add_Click({
    $Form.Close()
})
$Form.Controls.Add($CancelButton)


# Show the GUI
[void]$Form.ShowDialog()