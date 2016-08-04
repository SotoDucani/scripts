<#
.SYNOPSIS
	Discovers a list of local administrators for all domain-joined computers on the network. This list is output into a file sorted by computer name. A list of computers that cannot be reached are output to a seperate file.
	
	Permissions to access the target computers must be at least local administrator.
.DESCRIPTION
	This script makes use of the wmi service on the target computers in order to pull their local admins. It queries the accounts by ensuring they are a local account and that they are a member of the Administrator group. Admin group is checked through a SID match (Administrator SID = S-1-5-32-544).
.INPUTS
	None
.OUTPUTS
	A failure log and a list of admins by computer.
.NOTES
	File Name : Get-DomainLocalAdmins.ps1
	Author : Unknown Reddit User (Thanks!!)
	Written for : Powershell V3.0
	Version : 1.0
#>

import-module activedirectory

# Gets all computers from the directory except for those that start with VM
$domainComputers = get-adcomputer -filter {enabled -eq "True"}

$FailLog = "C:\Users\Josh.he\unreachables.txt"
$computersWithAdmin = "C:\Users\Josh.he\admins.txt"

foreach($computer in $domainComputers) {
	# Get admin group on remote computer
    $admingroup = get-wmiobject win32_group -Filter "LocalAccount=True AND SID='S-1-5-32-544'" -computer $computer.name -erroraction silentlycontinue
    if ($admingroup){
		# Make a query to get relevant info
        $query="GroupComponent = `"Win32_Group.Domain='" + $admingroup.Domain + "',NAME='" + $admingroup.Name + "'`""
        # Execute query and only return domain members
		$users = (Get-WmiObject win32_groupuser -Filter $query -computer $computer.name) | select PartComponent | Where {$_ -like "*Domain=`"pmi`"*"}
		# Tidy up string
        $admins = foreach ($user in $users) {($user.PartComponent.split(","))[1]}
        if ($admins.length -gt 0){
            add-content $computersWithAdmin $computer.name
            add-content $computersWithAdmin $admins
            add-content $computersWithAdmin " "
        }
    } else{
        "failed"
        Add-Content -Path $FailLog $computer.name
    }
}