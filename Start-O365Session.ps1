<#
.SYNOPSIS
	Starts an O365 Session.
.NOTES
	File Name : Start-O365Session.ps1
	Author : Joshua Herrmann
	Written for : Powershell V3.0
	Version : 1.0
#>

$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session