<#
.SYNOPSIS
	PowerShell Script for backing up a FortiGate configuration.
.DESCRIPTION
	This script is written to partially automate the backup process for the FortiGate. This is done using the SSH.NET library (http://sshnet.codeplex.com/) as well as pscp (http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)
	
	You must edit the variables in the script to customize it. There are no parameters accepted.
	
	The user running this script needs to have the module SSH-Sessions (From SSH.NET Library) available. To find the possible locations to place the module, run the following command:
	
	$env:PSModulePath -split ';'
	
	Credit to this blog for the idea and basic structure of the script: http://www.powershelladmin.com/wiki/SSH_from_PowerShell_using_the_SSH.NET_library
.INPUTS
	N$
.OUTPUTS
	A number of configuration files downloaded from the specified devices. The save location and filename is determined as shown below:
	
	$filepath\$hostname$filename-$time$ext
.EXAMPLE
    Backup-FortiGate -Device 192.168.0.254 -Username Tom -Password Jerry
.NOTES
	File Name: Backup-FortiGate.ps1
	Author : Joshua Herrmann
	Written for : Powershell V3.0
	Version : 1.2
#>

[CmdletBinding()]
param(
    # Enter your device IP addresses here:
	[Parameter(Mandatory=$True)]
	[string[]]$Device,

	# Enter your user accounts here:
    [Parameter(Mandatory=$True)]
	[string[]]$Username,

	# Enter your passwords here:
    [Parameter(Mandatory=$True)]
	[string[]]$Password,

	# Enter text to be included in the filename 
	[string[]]$Filename ="Backup",

	# Enter the desired file extension
	[string[]]$Extension =".conf",

	# Enter the file path you wish to backup to: (Note that the file location must already exist)
	[string[]]$Filepath = "\\XXXXXXXXXX\IT Admin\Backups\Fortigate_Configuration_Backups"
)

Import-Module SSH-Sessions

$ErrorActionPreference ="Inquire"

$time ="$(get-date -f MM-dd-yyyy)"

# NEED TO CREATE A LOOP FOR THESE
#--------------------

# Create the SSH Session with the target device
New-SSHSession $Device[0] -Username $Username[0] -Password "$Password"

# Get the hostname (This is specific to FortiGate)
$DeviceResult = Invoke-SSHCommand -ComputerName $Device[0] -Command "show system global"
$DeviceArray = $DeviceResult -Split '"'
$DeviceHostname = $DeviceArray[1]

# Run the backup command
Start-Process 'C:\Program Files (x86)\PUTTY\pscp.exe' -ArgumentList ("admin@192.168.0.254:sys_config C:\Users\josh.he") -Wait
$SBresult = Get-Content C:\Users\josh.he\sys_config
$SBresult | Out-File "$Filepath\$DeviceHostname-$Filename-$time$Extension"
Remove-Item C:\Users\josh.he\sys_config

#--------------------

Remove-SSHSession -RemoveAll