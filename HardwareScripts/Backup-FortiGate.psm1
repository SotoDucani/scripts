<#
.SYNOPSIS
	Backups a Fortigate configuration to a target location
.DESCRIPTION
	This script is written to partially automate the backup process for the FortiGate. This is done using the SSH.NET library (http://sshnet.codeplex.com/) as well as pscp (http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)
	
	The user running this script needs to have the module SSH-Sessions (From SSH.NET Library) available. To find the possible locations to place the module, run the following command in powershell:
	
	$env:PSModulePath -split ';'
	
	Credit to this blog for the idea and basic structure of the script: http://www.powershelladmin.com/wiki/SSH_from_PowerShell_using_the_SSH.NET_library
.EXAMPLE
    Backup-FortiGate -Path '\\Server\Share\Backups' -Device '192.168.0.254' -Username 'Tom' -Password 'Jerry'
.INPUTS
	None
.OUTPUTS
	None
#>

function Backup-FortiGate
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String]$Path,

        [Parameter(Mandatory=$true)]
        [String]$Device,

        [Parameter(Mandatory=$true)]
        [String]$Username,

        [Parameter(Mandatory=$true)]
        [String]$Password
    )

    # Try to load the SSH-Sessions module
    Try
    {
        Import-Module SSH-Sessions
	}
	Catch
	{
		Write-Host "Error when attempting to load the SSH-Sessions module. Check to see if you have set it up correctly." -ForegroundColor Red
	}
	
	$Date="$(get-date -f MM-dd-yyyy)"
	
	# Create the SSH Session with the target device
	New-SSHSession $Device -Username $Username -Password "$Password"

	# Get the hostname (This is specific to FortiGate)
	$DeviceResult = Invoke-SSHCommand -ComputerName $Device -Command "show system global"
	$DeviceArray = $DeviceResult -Split '"'
	$DeviceHostname = $DeviceArray[1]
	
	# End the SSH Session
	Remove-SSHSession -RemoveAll
	
	# Run the backup command
	Start-Process "C:\Program Files (x86)\PUTTY\pscp.exe" -ArgumentList ("$($Username)@$($Device):sys_config C:\Temp\josh.he") -Wait
	$SBresult = Get-Content "C:\Temp\sys_config"
	$SBresult | Out-File -FilePath "$Path\$DeviceHostname-Backup-$Date.conf"
	Remove-Item "C:\Temp\sys_config"
}