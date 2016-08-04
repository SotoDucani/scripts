<#
.SYNOPSIS
	PowerShell Script for editing a FortiSwitch configuration to have sFlow enabled on all ports.
.DESCRIPTION
	This script is written to partially automate the configuration change in a FortiSwitch to enable sFlow on all ports. This is done using the SSH.NET library that is available at http://sshnet.codeplex.com/
	
	It is sort of a hack as every line of command has to be typed out. Not sure if looping would be viable in the FortiOS.
.INPUTS
	None - Settings are manually changed in the script file
.OUTPUTS
	None
.NOTES
	File Name: Set-sFlowEnabled.ps1
	Author : Joshua Herrmann
	Written for : Powershell V3.0
	Version : 1.0
#>

# Enter your device IP addresses here:
$d1 = "192.168.0.220"

# Enter your user accounts here:
$u1 = Read-Host "Enter Username to access the device"

# Enter your passwords here:
$p1 = Read-Host "Enter the Password"
 
# Enter the SSH Session commands here:
New-SSHSession $d1 -Username $u1 -Password "$p1"

Invoke-SSHCommand -ComputerName $d1 -Command "config switch interface
edit port1
set sflow-sampler enabled
end
config switch interface
edit port2
set sflow-sampler enabled
end
config switch interface
edit port3
set sflow-sampler enabled
end
config switch interface
edit port4
set sflow-sampler enabled
end
config switch interface
edit port5
set sflow-sampler enabled
end
config switch interface
edit port6
set sflow-sampler enabled
end
config switch interface
edit port7
set sflow-sampler enabled
end
config switch interface
edit port8
set sflow-sampler enabled
end
config switch interface
edit port9
set sflow-sampler enabled
end
config switch interface
edit port10
set sflow-sampler enabled
end
config switch interface
edit port11
set sflow-sampler enabled
end
config switch interface
edit port12
set sflow-sampler enabled
end
config switch interface
edit port13
set sflow-sampler enabled
end
config switch interface
edit port14
set sflow-sampler enabled
end
config switch interface
edit port15
set sflow-sampler enabled
end
config switch interface
edit port16
set sflow-sampler enabled
end
config switch interface
edit port17
set sflow-sampler enabled
end
config switch interface
edit port18
set sflow-sampler enabled
end
config switch interface
edit port19
set sflow-sampler enabled
end
config switch interface
edit port20
set sflow-sampler enabled
end
config switch interface
edit port21
set sflow-sampler enabled
end
config switch interface
edit port22
set sflow-sampler enabled
end
config switch interface
edit port23
set sflow-sampler enabled
end
config switch interface
edit port24
set sflow-sampler enabled
end
config switch interface
edit port25
set sflow-sampler enabled
end
config switch interface
edit port26
set sflow-sampler enabled
end
config switch interface
edit port27
set sflow-sampler enabled
end
config switch interface
edit port28
set sflow-sampler enabled
end
config switch interface
edit port29
set sflow-sampler enabled
end
config switch interface
edit port30
set sflow-sampler enabled
end
config switch interface
edit port31
set sflow-sampler enabled
end
config switch interface
edit port32
set sflow-sampler enabled
end
config switch interface
edit port33
set sflow-sampler enabled
end
config switch interface
edit port34
set sflow-sampler enabled
end
config switch interface
edit port35
set sflow-sampler enabled
end
config switch interface
edit port36
set sflow-sampler enabled
end
config switch interface
edit port37
set sflow-sampler enabled
end
config switch interface
edit port38
set sflow-sampler enabled
end
config switch interface
edit port39
set sflow-sampler enabled
end
config switch interface
edit port40
set sflow-sampler enabled
end
config switch interface
edit port41
set sflow-sampler enabled
end
config switch interface
edit port42
set sflow-sampler enabled
end
config switch interface
edit port43
set sflow-sampler enabled
end
config switch interface
edit port44
set sflow-sampler enabled
end
config switch interface
edit port45
set sflow-sampler enabled
end
config switch interface
edit port46
set sflow-sampler enabled
end
config switch interface
edit port47
set sflow-sampler enabled
end
config switch interface
edit port48
set sflow-sampler enabled
end
config switch interface
edit port49
set sflow-sampler enabled
end
config switch interface
edit port50
set sflow-sampler enabled
end
config switch interface
edit port51
set sflow-sampler enabled
end
config switch interface
edit port52
set sflow-sampler enabled
end
exit"

Remove-SSHSession -RemoveAll