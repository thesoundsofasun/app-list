# Requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Write-Host "`nScanning your PC to detect already installed apps. This will take a few seconds..." -ForegroundColor Yellow

# 1. Define your list of applications here
$AppList = @(
    [pscustomobject]@{ Category = "Archivator"; Name = "NanaZip"; Id = "M2Team.NanaZip" }
    [pscustomobject]@{ Category = "Audio Redactors/DAW"; Name = "VCV Rack"; Id = "VCVRack.VCVRack" }
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

# --- SCAN FOR INSTALLED APPS ---
$InstalledAppsOutput = & winget list --accept-source-agreements
$InstalledAppsString = $InstalledAppsOutput -join " "

# Add true/false status to our AppList
foreach ($App in $AppList) {
    if ($InstalledAppsString -match [regex]::Escape($App.Id)) {
        $App | Add-Member -MemberType NoteProperty -Name "IsInstalled" -Value $true
    } else {
        $App | Add-Member -MemberType NoteProperty -Name "IsInstalled" -Value $false
    }
}

# --- DARK MODE COLORS ---
$BgColor      = [System.Drawing.Color]::FromArgb(32, 32, 32)   
$ListBgColor  = [System.Drawing.Color]::FromArgb(45, 45, 48)   
$TextColor    = [System.Drawing.Color]::White
$NeutralBtn   = [System.Drawing.Color]::FromArgb(70, 70, 70)

# 2. Setup the GUI Window
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "My Custom App Utility"
$Form.Size = New-Object System.Drawing.Size(450, 620) 
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = 'FixedDialog'
$Form.MaximizeBox = $false
$Form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$Form.BackColor = $BgColor     
$Form.ForeColor = $TextColor   

# Add Title Label
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Select the applications you want to manage:"
$Label.Location = New-Object System.Drawing.Point(20, 20)
$Label.Size = New-Object System.Drawing.Size(400, 25)
$Form.Controls.Add($Label)

# Add Checked List Box for Apps
$CheckedListBox = New-Object System.Windows.Forms.CheckedListBox
$CheckedListBox.Location = New-Object System.Drawing.Point(20, 50)
$CheckedListBox.Size = New-Object System.Drawing.Size(395, 330) # Made slightly shorter to fit new buttons
$CheckedListBox.CheckOnClick = $true
$CheckedListBox.BackColor = $ListBgColor   
$CheckedListBox.ForeColor = $TextColor     
$CheckedListBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

# Populate the list box with the Check/X Marks
foreach ($App in $AppList) {
    if ($App.IsInstalled) {
        $DisplayString = "✅ [$($App.Category)] $($App.Name)"
    } else {
        $DisplayString = "❌ [$($App.Category)] $($App.Name)"
    }
    $CheckedListBox.Items.Add($DisplayString) | Out-Null
}
$Form.Controls.Add($CheckedListBox)

# ==========================================
# AUTO-SELECTION BUTTONS (NEW)
# ==========================================
$BtnSelectInstalled = New-Object System.Windows.Forms.Button
$BtnSelectInstalled.Text = "Select Installed"
$BtnSelectInstalled.Location = New-Object System.Drawing.Point(20, 390)
$BtnSelectInstalled.Size = New-Object System.Drawing.Size(125, 30)
$BtnSelectInstalled.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnSelectInstalled.BackColor = $NeutralBtn
$BtnSelectInstalled.Add_Click({
    for ($i = 0; $i -lt $CheckedListBox.Items.Count; $i++) {
        if ($CheckedListBox.Items[$i] -match "✅") { $CheckedListBox.SetItemChecked($i, $true) }
    }
})
$Form.Controls.Add($BtnSelectInstalled)

$BtnSelectMissing = New-Object System.Windows.Forms.Button
$BtnSelectMissing.Text = "Select Missing"
$BtnSelectMissing.Location = New-Object System.Drawing.Point(155, 390)
$BtnSelectMissing.Size = New-Object System.Drawing.Size(125, 30)
$BtnSelectMissing.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnSelectMissing.BackColor = $NeutralBtn
$BtnSelectMissing.Add_Click({
    for ($i = 0; $i -lt $CheckedListBox.Items.Count; $i++) {
        if ($CheckedListBox.Items[$i] -match "❌") { $CheckedListBox.SetItemChecked($i, $true) }
    }
})
$Form.Controls.Add($BtnSelectMissing)

$BtnClearAll = New-Object System.Windows.Forms.Button
$BtnClearAll.Text = "Clear Selection"
$BtnClearAll.Location = New-Object System.Drawing.Point(290, 390)
$BtnClearAll.Size = New-Object System.Drawing.Size(125, 30)
$BtnClearAll.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnClearAll.BackColor = $NeutralBtn
$BtnClearAll.Add_Click({
    for ($i = 0; $i -lt $CheckedListBox.Items.Count; $i++) {
        $CheckedListBox.SetItemChecked($i, $false)
    }
})
$Form.Controls.Add($BtnClearAll)


# ==========================================
# BUTTON 1: INSTALL SELECTED
# ==========================================
$InstallButton = New-Object System.Windows.Forms.Button
$InstallButton.Text = "Install Selected"
$InstallButton.Location = New-Object System.Drawing.Point(20, 435)
$InstallButton.Size = New-Object System.Drawing.Size(190, 35)
$InstallButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$InstallButton.BackColor = [System.Drawing.Color]::SeaGreen
$InstallButton.Add_Click({
    $Form.Hide()
    Write-Host "`n=== Starting Installation ===" -ForegroundColor Cyan
    foreach ($Item in $CheckedListBox.CheckedItems) {
        $App = $AppList | Where-Object { 
            $prefix = if ($_.IsInstalled) { "✅ " } else { "❌ " }
            "$prefix[$($_.Category)] $($_.Name)" -eq $Item 
        }
        if ($App) {
            Write-Host ">>> Installing $($App.Name)..." -ForegroundColor Yellow
            & winget install --id $App.Id --exact --silent --accept-package-agreements --accept-source-agreements
            if ($LastExitCode -eq 0) { Write-Host "[SUCCESS] Installed!" -ForegroundColor Green } 
        }
    }
    Write-Host "=== Process Complete ===" -ForegroundColor Cyan
    $Form.Close()
})
$Form.Controls.Add($InstallButton)


# ==========================================
# BUTTON 2: UNINSTALL SELECTED
# ==========================================
$UninstallButton = New-Object System.Windows.Forms.Button
$UninstallButton.Text = "Uninstall Selected"
$UninstallButton.Location = New-Object System.Drawing.Point(225, 435)
$UninstallButton.Size = New-Object System.Drawing.Size(190, 35)
$UninstallButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$UninstallButton.BackColor = [System.Drawing.Color]::IndianRed
$UninstallButton.Add_Click({
    $Form.Hide()
    Write-Host "`n=== Starting Uninstallation ===" -ForegroundColor Cyan
    foreach ($Item in $CheckedListBox.CheckedItems) {
        $App = $AppList | Where-Object { 
            $prefix = if ($_.IsInstalled) { "✅ " } else { "❌ " }
            "$prefix[$($_.Category)] $($_.Name)" -eq $Item 
        }
        if ($App) {
            Write-Host ">>> Uninstalling $($App.Name)..." -ForegroundColor Yellow
            & winget uninstall --id $App.Id --exact --silent
            if ($LastExitCode -eq 0) { Write-Host "[SUCCESS] Uninstalled!" -ForegroundColor Green } 
        }
    }
    Write-Host "=== Process Complete ===" -ForegroundColor Cyan
    $Form.Close()
})
$Form.Controls.Add($UninstallButton)


# ==========================================
# BUTTON 3: UPGRADE SELECTED
# ==========================================
$UpgradeSelectedButton = New-Object System.Windows.Forms.Button
$UpgradeSelectedButton.Text = "Upgrade Selected"
$UpgradeSelectedButton.Location = New-Object System.Drawing.Point(20, 480)
$UpgradeSelectedButton.Size = New-Object System.Drawing.Size(190, 35)
$UpgradeSelectedButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$UpgradeSelectedButton.BackColor = [System.Drawing.Color]::SteelBlue
$UpgradeSelectedButton.Add_Click({
    $Form.Hide()
    Write-Host "`n=== Upgrading Selected Apps ===" -ForegroundColor Cyan
    foreach ($Item in $CheckedListBox.CheckedItems) {
        $App = $AppList | Where-Object { 
            $prefix = if ($_.IsInstalled) { "✅ " } else { "❌ " }
            "$prefix[$($_.Category)] $($_.Name)" -eq $Item 
        }
        if ($App) {
            Write-Host ">>> Upgrading $($App.Name)..." -ForegroundColor Yellow
            & winget upgrade --id $App.Id --exact --silent --accept-package-agreements --accept-source-agreements
            if ($LastExitCode -eq 0) { Write-Host "[SUCCESS] Upgraded!" -ForegroundColor Green } 
            else { Write-Host "[NO UPDATE FOUND / FAILED]" -ForegroundColor DarkGray }
        }
    }
    Write-Host "=== Process Complete ===" -ForegroundColor Cyan
    $Form.Close()
})
$Form.Controls.Add($UpgradeSelectedButton)


# ==========================================
# BUTTON 4: UPGRADE ALL (EVERYTHING ON PC)
# ==========================================
$UpgradeAllButton = New-Object System.Windows.Forms.Button
$UpgradeAllButton.Text = "Upgrade All PC Apps"
$UpgradeAllButton.Location = New-Object System.Drawing.Point(225, 480)
$UpgradeAllButton.Size = New-Object System.Drawing.Size(190, 35)
$UpgradeAllButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$UpgradeAllButton.BackColor = [System.Drawing.Color]::MediumPurple
$UpgradeAllButton.Add_Click({
    $Form.Hide()
    Write-Host "`n=== Upgrading EVERY App on your PC ===" -ForegroundColor Cyan
    & winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown
    Write-Host "`n=== Upgrade Process Complete ===" -ForegroundColor Cyan
    $Form.Close()
})
$Form.Controls.Add($UpgradeAllButton)


# ==========================================
# BUTTON 5: LIST INSTALLED APPS
# ==========================================
$ListAppsButton = New-Object System.Windows.Forms.Button
$ListAppsButton.Text = "List Installed Apps"
$ListAppsButton.Location = New-Object System.Drawing.Point(20, 525)
$ListAppsButton.Size = New-Object System.Drawing.Size(190, 35)
$ListAppsButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$ListAppsButton.BackColor = [System.Drawing.Color]::Teal
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
    $TextBox.BackColor = $ListBgColor
    $TextBox.ForeColor = $TextColor
    $TextBox.ReadOnly = $true
    $TextBox.WordWrap = $false
    $TextBox.Font = New-Object System.Drawing.Font("Consolas", 10) 
    $TextBox.Text = $InstalledAppsOutput -join "`r`n"
    
    $ListForm.Controls.Add($TextBox)
    $ListForm.ShowDialog() | Out-Null
})
$Form.Controls.Add($ListAppsButton)


# ==========================================
# BUTTON 6: CANCEL / EXIT
# ==========================================
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Text = "Cancel / Exit"
$CancelButton.Location = New-Object System.Drawing.Point(225, 525)
$CancelButton.Size = New-Object System.Drawing.Size(190, 35)
$CancelButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$CancelButton.BackColor = [System.Drawing.Color]::DimGray
$CancelButton.Add_Click({
    $Form.Close()
})
$Form.Controls.Add($CancelButton)

# Show the GUI
[void]$Form.ShowDialog()