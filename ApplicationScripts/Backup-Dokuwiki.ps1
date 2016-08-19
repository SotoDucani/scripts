<#
.SYNOPSIS
	PowerShell Script for backing up the enitre Dokuwiki file structure.
.DESCRIPTION
	This script is written to partially automate the backup process for Dokuwiki. This is done using Powershell's built in Copy-Item.
	
	You must edit the variables in the script to customize it. There are no parameters accepted.
#>

$time = "$(get-date -f MM-dd-yyyy)"
$limit = (Get-Date).AddDays(-15)

# Enter text to be included in the filename 
$filename ="DokuwikiBackup"

# Enter the file path you wish to backup to: (Note that the file location must already exist)
$filepath = "\\YYYYYYYYYY\IT Admin\Backups\DokuWiki Backups"

$creds = Import-Clixml "\\YYYYYYYYYY\it admin\Credential XMLs\BackupuserCred.clixml"

Copy-Item -Path S:\Bitnami\dokuwiki -Destination $filepath -Recurse
Rename-Item $filepath\dokuwiki $filename-$time

#Delete old backups
Get-ChildItem -Path $filepath -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force