# File with neat one-liners that I find or make

# Get-ADUsers while excluding certain OUs
Get-ADUser -Filter * | ?{($_.DistinguishedName -notlike '*OU=Users,DC=company,DC=corp') -or ('*OU=Other Users,DC=company,DC=corp')}

# Do a pingsweep of a specified address range
1..255 | % {echo "192.168.0.$_" ; ping -n 1 -w 100 192.168.0.$_ | Select-String ttl}
