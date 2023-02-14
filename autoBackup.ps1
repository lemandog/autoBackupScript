[console]::WindowHeight = 35
[console]::WindowWidth = 140
$host.ui.rawui.BackgroundColor = "Black"
$host.ui.rawui.ForegroundColor = "Red"
$PSDefaultParameterValues = @{ '*:Encoding' = 'utf8' }
# Define the list of folders to be backed up
$folders = @(
    "C:\Users\Lemandog\Pictures\PRACTICE",
    "C:\Users\Lemandog\Pictures\wip",
    "C:\Users\Lemandog\IdeaProjects",
    "C:\Users\Lemandog\PycharmProjects",
    "C:\Users\Lemandog\Documents\SYSTEMAX Software Development\SAI2 Demo",
    "C:\Users\Lemandog\Desktop\ןנמדנאללû"
)

# Define the root path for the backup destination on the thumb drive
$backupRoot = "D:\Backups"

# Calculate the size of the thumb drive
$drive = Get-PSDrive -Name "D"
$thumbDriveSize = [Math]::Round(($drive.Free/1GB), 2) + [Math]::Round(($drive.Used/1GB), 2)

# Set the maximum size of the backup to 80% of the thumb drive size
$maxSize = [Math]::Round((0.8 * $thumbDriveSize), 2) * 1GB

# Calculate the total size of the current backup
$totalSize = [Math]::Round(($drive.Used/1GB), 2)
# If the total size of the backup is greater than the maximum size, delete the oldest backup
Write-Output "TOTAL DRIVE SIZE: $thumbDriveSize"
Write-Output "USED DRIVE SIZE: $totalSize"
if ($totalSize -gt $maxSize) {
$oldestBackup = Get-ChildItem $backupRoot | Sort-Object CreationTime | Select-Object -First 1
Remove-Item $oldestBackup.FullName -Force
}
$destination = Join-Path $backupRoot (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
New-Item -ItemType Directory -Path $destination
# Create a new backup by copying the folders to the backup destination
foreach ($folder in $folders) {
Copy-Item $folder $destination -Recurse -passthru | ?{$_ -is [system.io.fileinfo]}
}
exit 0