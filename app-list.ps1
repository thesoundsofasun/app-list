# Requires -Version 5.1
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# 1. Define your list of applications here!
# You can find IDs by opening powershell and typing: winget search "App Name"
$AppList = @(
    [pscustomobject]@{ Category = "Archivator"; Name = "NanaZip"; Id = "M2Team.NanaZip" }

    [pscustomobject]@{ Category = "Audio Redactors/DAW"; Name = "VCV Rack"; Id = "VCVRack.VCVRack" }
            
    [pscustomobject]@{ Category = "Browser"; Name = "Mozilla Firefox"; Id = "Mozilla.Firefox" }
    
    [pscustomobject]@{ Category = "Graphic Redactors"; Name = "Affinity Studio"; Id = "Canva.Affinity" }
    [pscustomobject]@{ Category = "Graphic Redactors"; Name = "GIMP"; Id = "GIMP.GIMP.3" }
    
    [pscustomobject]@{ Category = "3D Redactors"; Name = "Blender"; Id = "Microsoft.VisualStudioCode" }
    
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

# 2. Setup the GUI Window
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "App List"
$Form.Size = New-Object System.Drawing.Size(450, 550)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = 'FixedDialog'
$Form.MaximizeBox = $false
$Form.Font = New-Object System.Drawing.Font("Segoe UI", 10)

# Add Title Label
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Select the applications you want to install:"
$Label.Location = New-Object System.Drawing.Point(20, 20)
$Label.Size = New-Object System.Drawing.Size(400, 25)
$Form.Controls.Add($Label)

# Add Checked List Box for Apps
$CheckedListBox = New-Object System.Windows.Forms.CheckedListBox
$CheckedListBox.Location = New-Object System.Drawing.Point(20, 50)
$CheckedListBox.Size = New-Object System.Drawing.Size(390, 380)
$CheckedListBox.CheckOnClick = $true

# Populate the list box with our apps
foreach ($App in $AppList) {
    # Display format: [Category] App Name
    $DisplayString = "[$($App.Category)] $($App.Name)"
    $CheckedListBox.Items.Add($DisplayString) | Out-Null
}
$Form.Controls.Add($CheckedListBox)

# Add Install Button
$InstallButton = New-Object System.Windows.Forms.Button
$InstallButton.Text = "Install Selected"
$InstallButton.Location = New-Object System.Drawing.Point(20, 450)
$InstallButton.Size = New-Object System.Drawing.Size(150, 35)
$InstallButton.BackColor = [System.Drawing.Color]::LightGreen

# Define what happens when "Install" is clicked
$InstallButton.Add_Click({
    $Form.Hide() # Hide window while installing
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host " Starting Installation Process..." -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan

    foreach ($Item in $CheckedListBox.CheckedItems) {
        # Match the checked string back to the object
        $App = $AppList | Where-Object { "[$($_.Category)] $($_.Name)" -eq $Item }
        
        if ($App) {
            Write-Host "`n>>> Installing $($App.Name)..." -ForegroundColor Yellow
            
            # Winget command to silently install the app
            $wingetArgs = @("install", "--id", $App.Id, "--exact", "--silent", "--accept-package-agreements", "--accept-source-agreements")
            & winget $wingetArgs
            
            if ($LastExitCode -eq 0) {
                Write-Host "[SUCCESS] $($App.Name) installed successfully!" -ForegroundColor Green
            } else {
                Write-Host "[FAILED] Failed to install $($App.Name). Exit code: $LastExitCode" -ForegroundColor Red
            }
        }
    }
    Write-Host "`n======================================" -ForegroundColor Cyan
    Write-Host " All installations have completed!" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    $Form.Close()
})
$Form.Controls.Add($InstallButton)

# Add Cancel Button
$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Text = "Cancel"
$CancelButton.Location = New-Object System.Drawing.Point(260, 450)
$CancelButton.Size = New-Object System.Drawing.Size(150, 35)
$CancelButton.Add_Click({
    $Form.Close()
})
$Form.Controls.Add($CancelButton)

# Show the GUI
[void]$Form.ShowDialog()