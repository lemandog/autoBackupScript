# Cool hackery look and smaller window
[console]::WindowHeight = 35
[console]::WindowWidth = 140
$host.ui.rawui.BackgroundColor = "Black"
$host.ui.rawui.ForegroundColor = "Green"
# Set encoding so not only english is supported
$PSDefaultParameterValues = @{ '*:Encoding' = 'utf8' }
# Define the list of folders to be backed up
$folders = @(
    "O:\Docs",
    "O:\Pics",
    "O:\Desktop",
    "C:\Users\Lemandog\AppData"
)

# Define destination drives
$driveLetters = @("D", "E", "Q")
foreach ($letter in $driveLetters) {
    $backupRoot = $letter+":\backupScript"

    $drive = Get-PSDrive -Name $letter -ErrorAction SilentlyContinue
    if ($null -eq $drive) {
        Write-Output "Drive $letter does not exist. Skipping..."
        continue
    }
    $thumbDriveSize = [Math]::Round(($drive.Free/1GB), 2) + [Math]::Round(($drive.Used/1GB), 2)
    # Calculate the total size of the current backup
    $totalSize = [Math]::Round(($drive.Used/1GB), 2)
    # If the total size of the backup is greater than the maximum size, delete the oldest backup
    Write-Output "Backing up to drive $letter :"
    Write-Output "TOTAL DRIVE SIZE: $thumbDriveSize"
    Write-Output "USED DRIVE SIZE: $totalSize"
    # Calculate the total size of the folders to be backed up
    $foldersSize = 0
    foreach ($folder in $folders) {
        if (Test-Path $folder) {
            $folderSize = (Get-ChildItem -Path $folder -Recurse -File | Measure-Object -Property Length -Sum).Sum / 1GB
            $foldersSize += [Math]::Round($folderSize, 2)
        } else {
            Write-Output "Folder $folder does not exist. Skipping..."
        }
    }

    Write-Output "TOTAL SIZE OF SELECTED FILES: $foldersSize GB"
    if ($foldersSize -gt ($drive.Free / 1GB)) {
        $oldestBackup = Get-ChildItem $backupRoot | Sort-Object CreationTime | Select-Object -First 1
        Write-Output "DELETING OLDEST FOLDER TO FREE UP SPACE: $totalSize"
        Remove-Item $oldestBackup.FullName -Force -Recurse
    }
    $destination = Join-Path $backupRoot (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
    New-Item -ItemType Directory -Path $destination

    foreach ($folder in $folders) {
        Copy-Item $folder $destination -Recurse -passthru | ?{$_ -is [system.io.fileinfo]}
    }
}
exit 0
