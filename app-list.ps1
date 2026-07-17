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

# Parse Winget Data into our AppList
foreach ($App in $AppList) {
    $App | Add-Member -MemberType NoteProperty -Name "IsInstalled" -Value ($InstalledAppsString -match [regex]::Escape($App.Id))
    $App | Add-Member -MemberType NoteProperty -Name "HasUpdate" -Value ($UpgradableAppsString -match [regex]::Escape($App.Id))
}

# --- DARK MODE COLORS & STYLES ---
$BgColor      = [System.Drawing.Color]::FromArgb(32, 32, 32)   
$TreeBgColor  = [System.Drawing.Color]::FromArgb(45, 45, 48)   
$TextColor    = [System.Drawing.Color]::White
$NeutralBtn   = [System.Drawing.Color]::FromArgb(70, 70, 70)
$AnchorAll    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$AnchorBottom = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left

# 2. Setup the GUI Window (Now Resizable!)
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Advanced Package Manager Utility"
$Form.Size = New-Object System.Drawing.Size(560, 750) 
$Form.MinimumSize = New-Object System.Drawing.Size(560, 600) # Prevents making it too small
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = 'Sizable' # Allows resizing!
$Form.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$Form.BackColor = $BgColor     
$Form.ForeColor = $TextColor   

$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Select applications to manage (Expand categories):"
$Label.Location = New-Object System.Drawing.Point(20, 15)
$Label.Size = New-Object System.Drawing.Size(400, 25)
$Form.Controls.Add($Label)

# ==========================================
# CATEGORY TREE VIEW (REPLACES CHECKLIST)
# ==========================================
$TreeView = New-Object System.Windows.Forms.TreeView
$TreeView.Location = New-Object System.Drawing.Point(20, 45)
$TreeView.Size = New-Object System.Drawing.Size(500, 410)
$TreeView.Anchor = $AnchorAll # Stretches dynamically
$TreeView.CheckBoxes = $true
$TreeView.BackColor = $TreeBgColor
$TreeView.ForeColor = $TextColor
$TreeView.ItemHeight = 24
$TreeView.ShowLines = $false

# Populate Categories and Apps
$Categories = $AppList | Select-Object -ExpandProperty Category -Unique | Sort-Object
foreach ($Cat in $Categories) {
    $CatNode = $TreeView.Nodes.Add($Cat, "📂 " + $Cat)
    $CatNode.ForeColor = [System.Drawing.Color]::Cyan # Stand out header color
    
    $AppsInCat = $AppList | Where-Object Category -eq $Cat | Sort-Object Name
    foreach ($App in $AppsInCat) {
        if ($App.HasUpdate) {
            $Prefix = "⬆️ "
            $Suffix = " (Update Available)"
            $Color = [System.Drawing.Color]::LightGreen
        } elseif ($App.IsInstalled) {
            $Prefix = "✅ "
            $Suffix = ""
            $Color = [System.Drawing.Color]::White
        } else {
            $Prefix = "❌ "
            $Suffix = ""
            $Color = [System.Drawing.Color]::Silver
        }
        
        $ChildNode = $CatNode.Nodes.Add($App.Id, "$Prefix$($App.Name)$Suffix")
        $ChildNode.Tag = $App # Store object data inside the node
        $ChildNode.ForeColor = $Color
    }
    $CatNode.Expand() # Expand categories by default
}
$Form.Controls.Add($TreeView)

# Smart Checkbox Logic (Checking a folder checks all apps inside it)
$script:HandlingCheck = $false
$TreeView.add_AfterCheck({
    if ($script:HandlingCheck) { return }
    $script:HandlingCheck = $true
    
    $Node = $_.Node
    if ($Node.Nodes.Count -gt 0) {
        # Parent clicked: Check/Uncheck all children
        foreach ($Child in $Node.Nodes) { $Child.Checked = $Node.Checked }
    } else {
        # Child clicked: Check/Uncheck parent folder automatically
        $Parent = $Node.Parent
        if ($Parent) {
            $allChecked = $true
            foreach ($Child in $Parent.Nodes) { if (-not $Child.Checked) { $allChecked = $false; break } }
            $Parent.Checked = $allChecked
        }
    }
    $script:HandlingCheck = $false
})

# Helper function to get exactly what is checked
function Get-SelectedApps {
    $Selected = @()
    foreach ($CatNode in $TreeView.Nodes) {
        foreach ($AppNode in $CatNode.Nodes) {
            if ($AppNode.Checked) { $Selected += $AppNode.Tag }
        }
    }
    return $Selected
}

# Helper function for the Auto-Select row
function Select-Nodes ($Condition) {
    $script:HandlingCheck = $true
    foreach ($CatNode in $TreeView.Nodes) {
        $allChildrenChecked = $true
        foreach ($AppNode in $CatNode.Nodes) {
            $App = $AppNode.Tag
            if ($Condition -eq "None") { $AppNode.Checked = $false } 
            elseif ($Condition -eq "Missing") { $AppNode.Checked = -not $App.IsInstalled } 
            elseif ($Condition -eq "Installed") { $AppNode.Checked = $App.IsInstalled } 
            elseif ($Condition -eq "Updates") { $AppNode.Checked = $App.HasUpdate }
            if (-not $AppNode.Checked) { $allChildrenChecked = $false }
        }
        if ($CatNode.Nodes.Count -gt 0) { $CatNode.Checked = $allChildrenChecked }
    }
    $script:HandlingCheck = $false
}


# ==========================================
# AUTO-SELECTION BUTTONS (ANCHORED BOTTOM)
# ==========================================
$BtnSelectMissing = New-Object System.Windows.Forms.Button
$BtnSelectMissing.Text = "Select Missing"
$BtnSelectMissing.Location = New-Object System.Drawing.Point(20, 470)
$BtnSelectMissing.Size = New-Object System.Drawing.Size(120, 30)
$BtnSelectMissing.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnSelectMissing.BackColor = $NeutralBtn
$BtnSelectMissing.Anchor = $AnchorBottom
$BtnSelectMissing.Add_Click({ Select-Nodes "Missing" })
$Form.Controls.Add($BtnSelectMissing)

$BtnSelectInstalled = New-Object System.Windows.Forms.Button
$BtnSelectInstalled.Text = "Select Installed"
$BtnSelectInstalled.Location = New-Object System.Drawing.Point(146, 470)
$BtnSelectInstalled.Size = New-Object System.Drawing.Size(120, 30)
$BtnSelectInstalled.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnSelectInstalled.BackColor = $NeutralBtn
$BtnSelectInstalled.Anchor = $AnchorBottom
$BtnSelectInstalled.Add_Click({ Select-Nodes "Installed" })
$Form.Controls.Add($BtnSelectInstalled)

$BtnSelectUpdates = New-Object System.Windows.Forms.Button
$BtnSelectUpdates.Text = "Select Updates"
$BtnSelectUpdates.Location = New-Object System.Drawing.Point(272, 470)
$BtnSelectUpdates.Size = New-Object System.Drawing.Size(120, 30)
$BtnSelectUpdates.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnSelectUpdates.BackColor = $NeutralBtn
$BtnSelectUpdates.Anchor = $AnchorBottom
$BtnSelectUpdates.Add_Click({ Select-Nodes "Updates" })
$Form.Controls.Add($BtnSelectUpdates)

$BtnClearAll = New-Object System.Windows.Forms.Button
$BtnClearAll.Text = "Clear All"
$BtnClearAll.Location = New-Object System.Drawing.Point(398, 470)
$BtnClearAll.Size = New-Object System.Drawing.Size(122, 30)
$BtnClearAll.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$BtnClearAll.BackColor = $NeutralBtn
$BtnClearAll.Anchor = $AnchorBottom
$BtnClearAll.Add_Click({ Select-Nodes "None" })
$Form.Controls.Add($BtnClearAll)


# ==========================================
# ACTION ROW 1: INSTALL / UNINSTALL
# ==========================================
$InstallButton = New-Object System.Windows.Forms.Button
$InstallButton.Text = "Install Selected"
$InstallButton.Location = New-Object System.Drawing.Point(20, 515)
$InstallButton.Size = New-Object System.Drawing.Size(245, 35)
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
$UninstallButton.Location = New-Object System.Drawing.Point(275, 515)
$UninstallButton.Size = New-Object System.Drawing.Size(245, 35)
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
$UpgradeSelectedButton.Location = New-Object System.Drawing.Point(20, 560)
$UpgradeSelectedButton.Size = New-Object System.Drawing.Size(245, 35)
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
$UpgradeAllButton.Location = New-Object System.Drawing.Point(275, 560)
$UpgradeAllButton.Size = New-Object System.Drawing.Size(245, 35)
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
# ACTION ROW 3: UTILITIES
# ==========================================
$ListAppsButton = New-Object System.Windows.Forms.Button
$ListAppsButton.Text = "List Installed Apps"
$ListAppsButton.Location = New-Object System.Drawing.Point(20, 605)
$ListAppsButton.Size = New-Object System.Drawing.Size(245, 35)
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
    $TextBox.BackColor = $TreeBgColor
    $TextBox.ForeColor = $TextColor
    $TextBox.ReadOnly = $true
    $TextBox.WordWrap = $false
    $TextBox.Font = New-Object System.Drawing.Font("Consolas", 10) 
    $TextBox.Text = $InstalledAppsString
    
    $ListForm.Controls.Add($TextBox)
    $ListForm.ShowDialog() | Out-Null
})
$Form.Controls.Add($ListAppsButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Text = "Cancel / Exit"
$CancelButton.Location = New-Object System.Drawing.Point(275, 605)
$CancelButton.Size = New-Object System.Drawing.Size(245, 35)
$CancelButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$CancelButton.BackColor = [System.Drawing.Color]::DimGray
$CancelButton.Anchor = $AnchorBottom
$CancelButton.Add_Click({
    $Form.Close()
})
$Form.Controls.Add($CancelButton)

# Show the GUI
[void]$Form.ShowDialog()