<#
.SYNOPSIS
	PowerShell Script for backing up the enitre Dokuwiki file structure.
.DESCRIPTION
	This script is written to partially automate the backup process for Dokuwiki. This is done using Powershell's built in Copy-Item.
	
	You must edit the variables in the script to customize it. There are no parameters accepted.
#>
$ErrorActionPreference ="Inquire"

$time ="$(get-date -f MM-dd-yyyy)"

# Enter text to be included in the filename 
$filename ="DokuwikiBackup"

# Enter the file path you wish to backup to: (Note that the file location must already exist)
$filepath = "\\YYYYYYYYYY\IT Admin\Backups\DokuWiki Backups"

$creds = Import-Clixml "\\YYYYYYYYYY\it admin\Credential XMLs\BackupuserCred.clixml"

New-PSDrive -Name U -PSProvider FileSystem -Root \\XXXXXXXXXX\apps -Credential $creds
Copy-Item -Path U:\dokuwiki -Destination $filepath -Recurse -Verbose
Write-Host "Copy Done"
Rename-Item $filepath\dokuwiki $filename-$time
Write-Host "Rename Done"
Remove-PSDrive -Name U