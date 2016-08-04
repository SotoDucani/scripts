<#
.SYNOPSIS
	PowerShell Script for backing up multiple FortiSwitch configurations. Assumes 1 user account can log into all switches.
.DESCRIPTION
	This script is written to partially automate the backup process for FortiSwitches. This is done using the SSH.NET library (http://sshnet.codeplex.com/) as well as pscp (http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html)
	
	You must edit the variables in the script to customize it. There are no parameters accepted.
	
	The user running this script needs to have the module SSH-Sessions (From SSH.NET Library) available. To find the possible locations to place the module, run the following command:
	
	$env:PSModulePath -split ';'
	
	Credit to this blog for the idea and basic structure of the script: http://www.powershelladmin.com/wiki/SSH_from_PowerShell_using_the_SSH.NET_library
.INPUTS
	None - Settings are manually changed in the script file
.OUTPUTS
	A number of configuration files downloaded from the specified devices. The save location and filename is determined as shown below:
	
	$filepath\$hostname$filename-$time$ext
.NOTES
	File Name: Backup-FortiSwitches.ps1
	Author : Joshua Herrmann
	Written for : Powershell V3.0
	Version : 1.0
#>

$ErrorActionPreference ="Inquire"

Import-Module SSH-Sessions

$time ="$(get-date -f MM-dd-yyyy)"

# CUSTOM CONFIGURATION

# Enter text to be included in the filename 
$filename ="Backup"

# Enter the desired file extension
$ext =".conf"

# Enter the file path you wish to backup to: (Note that the file location must already exist)
$filepath = "\\YYYYYYYYYY\IT Admin\Backups\Fortigate_Configuration_Backups"
 
# Enter your device IP addresses here:
$d1 = "192.168.0.220"
$d2 = "192.168.0.221"
$d3 = "192.168.0.222"

# Enter your user account here:
$u1 = Read-Host "Enter Username to access the devices"

# Enter your password here:
$p1 = Read-Host "Enter the Password"
 
# Enter the SSH Session commands here:
New-SSHSession $d1 -Username $u1 -Password "$p1"
New-SSHSession $d2 -Username $u1 -Password "$p1"
New-SSHSession $d3 -Username $u1 -Password "$p1"
 
# END CUSTOM CONFIGURATION

# NEED TO CREATE A LOOP FOR THESE
#--------------------

# Get the hostname (This is specific to FortiSwitches)
$d1Result = Invoke-SSHCommand -ComputerName $d1 -Command "show system global"
$d1Array = $d1Result -Split '"'
$d1Hostname = $d1Array[1]

# Run the backup command
Start-Process 'C:\Program Files (x86)\PUTTY\pscp.exe' -ArgumentList ("admin@192.168.0.220:sys_config C:\LOCALFILEPATH") -Wait
$SBresult = Get-Content C:\LOCALFILEPATH
$SBresult | Out-File "$filepath\$d1Hostname-$filename-$time$ext"
Remove-Item C:\LOCALFILEPATH

#--------------------

# Get the hostname (This is specific to FortiSwitches)
$d2Result = Invoke-SSHCommand -ComputerName $d2 -Command "show system global"
$d2Array = $d2Result -Split '"'
$d2Hostname = $d2Array[1]

# Run the backup command
Start-Process 'C:\Program Files (x86)\PUTTY\pscp.exe' -ArgumentList ("admin@192.168.0.221:sys_config C:\Users\josh.he") -Wait
$SBresult = Get-Content C:\Users\josh.he\sys_config
$SBresult | Out-File "$filepath\$d2Hostname-$filename-$time$ext"
Remove-Item C:\Users\josh.he\sys_config

#--------------------

# Get the hostname (This is specific to FortiSwitches)
$d3Result = Invoke-SSHCommand -ComputerName $d3 -Command "show system global"
$d3Array = $d3Result -Split '"'
$d3Hostname = $d3Array[1]

# Run the backup command
Start-Process 'C:\Program Files (x86)\PUTTY\pscp.exe' -ArgumentList ("admin@192.168.0.222:sys_config C:\Users\josh.he") -Wait
$SBresult = Get-Content C:\Users\josh.he\sys_config
$SBresult | Out-File "$filepath\$d3Hostname-$filename-$time$ext"
Remove-Item C:\Users\josh.he\sys_config

#--------------------

Remove-SSHSession -RemoveAll

Exit