<#
.SYNOPSIS
	PowerShell Script for backing up multiple FortiSwitch configurations. Assumes 1 user account can log into all switches.
.DESCRIPTION
	This script is written to partially automate the backup process for FortiSwitches. This is done using the SSH.NET library (http://sshnet.codeplex.com/) as well as pscp (http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)
	
	The user running this script needs to have the module SSH-Sessions (From SSH.NET Library) available. To find the possible locations to place the module, run the following command:
	
	$env:PSModulePath -split ';'
	
	Credit to this blog for the idea and basic structure of the script: http://www.powershelladmin.com/wiki/SSH_from_PowerShell_using_the_SSH.NET_library
.EXAMPLE
    PS C:\> Backup-FortiSwitches -Path '\\Server\Share\Backups' -Devices '192.168.0.1','192.168.0.2','192.168.0.3' -Username 'Tom' -Password 'Jerry'

    Connects to and backs up the configuration of switches at 192.168.0.1,2,3 to the \\server\share\backups path.
.INPUTS
	System.Object

    You can pipe a set of device ip addresses to Backup-FortiSwitches.
.OUTPUTS
	None
#>

function Backup-FortiSwitch
{
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory=$true)]
        [String]$Path,

        [Parameter(Mandatory=$true,
				   ValueFromPipeline=$true)]
        [Object]$Devices,

        [Parameter(Mandatory=$true)]
        [String]$Username,

        [Parameter(Mandatory=$true)]
        [String]$Password
	)
	
	Try
    {
        Import-Module SSH-Sessions
	}
	Catch
	{
		Write-Host "Error when attempting to load the SSH-Sessions module. Check to see if you have set it up correctly." -ForegroundColor Red
	}
	
	$Date="$(get-date -f MM-dd-yyyy)"
	
	Foreach($Device in $Devices)
	{
		# Open the SSH Session
		New-SSHSession $Device -Username $Username -Password $Password
		
		# Get the device hostname
		$Result = Invoke-SSHCommand -ComputerName $Device -Command "show system global"
		$Array = $Result -Split '"'
		$Hostname = $Array[1]
		
		#Remove the SSH Session
		Remove-SSHSession -RemoveAll

		Start-Process "C:\Program Files (x86)\PUTTY\pscp.exe" -ArgumentList ("$($Username)@$($Device):sys_config C:\Temp") -Wait
		$SBresult = Get-Content "C:\Temp\sys_config"
		$SBresult | Out-File "$Path\$Hostname-Backup-$Date.conf"
		Remove-Item "C:\Temp\sys_config"
	}
}