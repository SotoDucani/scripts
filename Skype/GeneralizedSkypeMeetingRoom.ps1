$Alias = Short_Name
$Name = "Long Name Conference Room"
$UPN = Short_Name@company.com
$RoomMailboxPassword = "Pa$$word"
$Response = "This is the Long Name Conference room!"

#Get-DistributionGroup -RecipientTypeDetails RoomList
$RoomList = "Office Conference Rooms"
$LineURI = 'tel:+12345678901;ext=8901'

#Get-CsVoicePpolicy | Select-Object -Property Identity
$VoicePolicy = 'Office-International'

#Get-CsDialPlan | Select-Object -Property Identity
$DialPlan = 'Office-Dial-Plan'

#Run in Exchange Management Shell
New-Mailbox -Alias $Alias -Name $Name -Room -EnableRoomMailboxAccount $true -RoomMailboxPassword (ConvertTo-SecureString -String $RoomMailboxPassword -AsPlainText -Force) -UserPrincipalName $UPN
Set-CalendarProcessing -Identity $Alias -AutomateProcessing AutoAccept -AddOrganizerToSubject $false -AllowConflicts $false -DeleteComments $false -DeleteSubject $false -RemovePrivateProperty $false
Set-CalendarProcessing -Identity $Alias -AddAdditionalResponse $true -AdditionalResponse $Response
Add-DistributionGroupMember -Identity $RoomList -Member $Alias

#Run in Lync Management Shell
Enable-CsMeetingRoom -Identity $UPN -RegistrarPool lyncserver.company.com -SipAddressType UserPrincipalName
Set-CsMeetingRoom -Identity $Alias -EnterpriseVoiceEnabled $true -LineURI $LineURI
Grant-CsVoicePolicy -PolicyName $VoicePolicy -Identity $Alias
Grant-CsDialPlan -PolicyName $DialPlan -Identity $Alias
