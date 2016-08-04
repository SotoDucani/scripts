<#
.SYNOPSIS
	Beep and prompt the user to fill out a form that appears. Used as a worklog by running on a scheduled task every 2 hours.
.NOTES
	File Name : worklog.ps1
	Author : Joshua Herrmann
	Written for : Powershell V3.0
	Version : 1.0
#>

[console]::beep(2000,500)
# override the built in prompting, just for this script
function read-host($prompt) {
    $x = 0; $y = 0;
    add-type -assemblyname microsoft.visualbasic
    [Microsoft.VisualBasic.Interaction]::InputBox($prompt, "Interactive", "(default value)", $x, $y)
}
$date = get-date -Format "ddMMyyyy hh:mm"
$date2= get-date -Format ddMMyyyy
$a = read-host "What are you working on right now?"
"$date - $a" | Out-File "G:\My Documents\logs\$date2-worklog.txt" -Append