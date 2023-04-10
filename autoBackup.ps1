# Cool hackery look and smaller window
[console]::WindowHeight = 35
[console]::WindowWidth = 140
$host.ui.rawui.BackgroundColor = "Black"
$host.ui.rawui.ForegroundColor = "Red"
# Set encoding so not only english is supported
$PSDefaultParameterValues = @{ '*:Encoding' = 'utf8' }
# Define the list of folders to be backed up
$folders = @(
    "C:\Users\Lemandog\Desktop\Example0",
    "C:\Users\Lemandog\Desktop\Example1"
)

# Define destination on the drive
$backupRoot = "D:\Backups"

$drive = Get-PSDrive -Name "D"
$thumbDriveSize = [Math]::Round(($drive.Free/1GB), 2) + [Math]::Round(($drive.Used/1GB), 2)

$maxSize = $thumbDriveSize * 0.8
# (use 0.8% of drive)

# Calculate the total size of the current backup
$totalSize = [Math]::Round(($drive.Used/1GB), 2)
# If the total size of the backup is greater than the maximum size, delete the oldest backup
Write-Output "TOTAL DRIVE SIZE: $thumbDriveSize"
Write-Output "USED DRIVE SIZE: $totalSize"
Write-Output "MAX BACKUP SIZE: $maxSize"
if ($totalSize -gt $maxSize) {
$oldestBackup = Get-ChildItem $backupRoot | Sort-Object CreationTime | Select-Object -First 1
Remove-Item $oldestBackup.FullName -Force -Recurse
}
$destination = Join-Path $backupRoot (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
New-Item -ItemType Directory -Path $destination

foreach ($folder in $folders) {
Copy-Item $folder $destination -Recurse -passthru | ?{$_ -is [system.io.fileinfo]}
}
exit 0
