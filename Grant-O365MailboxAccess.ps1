<#
.SYNOPSIS
	Grant Admin full access to all user mailboxes. You do not need to start a O365 session before running this script.
.NOTES
	File Name : Grant-O365MailboxAccess.ps1
	Author : Joshua Herrmann
	Written for : Powershell V3.0
	Version : 1.0
#>

$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session

$Name = Read-Host 'Input username of person who is gaining full mailbox access: '

Get-Mailbox -ResultSize Unlimited -Filter {(RecipientTypeDetails -eq 'UserMailbox')} | Add-MailboxPermission -User $Name -AccessRights FullAccess -InheritanceType all

Remove-PSSession $Session