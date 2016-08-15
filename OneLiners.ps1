# File with neat one-liners that I find or make

# Get-ADUsers while excluding certain OUs
Get-ADUser -Filter * | ?{($_.DistinguishedName -notlike '*OU=Users,DC=company,DC=corp') -or ('*OU=Other Users,DC=company,DC=corp')}
