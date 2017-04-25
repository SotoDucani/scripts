<#
.Synopsis
Module made to allow cleaner and faster interaction with AppLocker policies. Also allows for mass modification to the policy while in the XML format.
#>

[xml]$policy = Get-AppLockerPolicy -Effective -Xml

function Set-Policy {

#parameters -Effective -LDAP -XML

}

function Show-Policy {

#Parameters -Conditions -Names

}

function Remove-Versions {

#ForEach-Object through and replace any entry in 

$policy.AppLockerPolicy.RuleCollection[1].FilePublisherRule[0].Conditions.FilePublisherCondition.BinaryVersionRange.LowSection

}