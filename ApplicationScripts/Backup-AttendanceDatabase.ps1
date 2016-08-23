<#
.SYNOPSIS
   Script to first copy files from the Attendance software backup directory on XXXXXXXXXX to the backup directory in YYYYYYYYYY.
   It then deletes any files that are more than 14 days old from the backup directory in YYYYYYYYYY.
.DESCRIPTION
   Uses robocopy to move files from \\XXXXXXXXXX\Backup to \\YYYYYYYYYY\IT Admin\Backups\AttendanceBackups.
   This ignores any already existing files, and does NOT delete files that no longer exist in the source location.
   Then the script recursively looks in \\YYYYYYYYYY\IT Admin\Backups\AttendanceBackups for any files that are older than the $limit value,
   and deletes them.
.NOTES
	File Name: Backup-AttendanceDatabase.ps1
	Author : Joshua Herrmann
	Written for : Powershell V3.0
	Version : 1.1
#>

$limit = (Get-Date).AddDays(-15)
$path = "BACKUPLOCATION"

#Use Robocopy to copy new files, ignoring already existing files
ROBOCOPY 'C:\Attendance Data\Backup' $path

# Delete files older than the $limit
Get-ChildItem -Path $path -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
