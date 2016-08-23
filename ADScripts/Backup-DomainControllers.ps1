<#
.SYNOPSIS
   This script is written to create systemstate backups of a single windows server.
.DESCRIPTION
   Uses the built-in Windows Server Backup module to create the backup then copies that backup to 2 network locations.
#>

$FileSysCred = Import-Clixml 'PATHTOCREDENTIALXML'

# Create the backup
wbadmin start systemstatebackup -backupTarget:'C:\Backups' -quiet

# Create the needed PSDrives
New-PSDrive -Name Z -PSProvider FileSystem -Root 'BACKUPLOCATION1' -Credential $FileSysCred
New-PSDrive -Name Y -PSProvider FileSystem -Root 'BACKUPLOCATION2' -Credential $FileSysCred

# Copy the backup to target locations
Copy-Item -Path C:\Backups -Destination Z:\ -Credential $FileSysCred -Recurse
Copy-Item -Path C:\Backups -Destination Y:\ -Credential $FileSysCred -Recurse

# Delete the PSDrives
Remove-PSDrive -Name Z
Remove-PSDrive -Name Y
