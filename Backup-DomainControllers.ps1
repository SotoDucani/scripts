<#
.SYNOPSIS
   This script is written to handle system state and full backups of each domain controller on the network.
.DESCRIPTION
   Using powershell remoting, this script starts a system state backup on each server in the provided list.
   Credentials are provided via a network-accessable clixml file.
#>

$Servers = 'XXXXXXXXXX','YYYYYYYYYY','ZZZZZZZZZZZ'
$Cred = Import-Clixml '\\WWWWWWWWWW\IT Admin\Credential XMLs\AdministratorCred.clixml'

ForEach ($i in $Servers)
{
    Invoke-Command -ComputerName $i -Credential $Cred -ScriptBlock {wbadmin start systemstatebackup -backupTarget:'\\WWWWWWWWWW\IT Admin\Backups'}
}