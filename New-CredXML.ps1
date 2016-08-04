$Cred = Get-Credential
Export-Clixml -InputObject $Cred -Path '\\XXXXXXXXXX\IT Admin\Credential XMLs\NEWCRED.clixml'