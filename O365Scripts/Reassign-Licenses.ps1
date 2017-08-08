#Connect to AzureAD; As of right now this must be ran from FM-ADFS02
Connect-MsolSerivce

#Get-MsolAccountSku shows license names to match against
#E4 = CompanyName:ENTERPRISEWITHSCAL
#E5 = CompanyName:ENTERPRISEPREMIUM_NOPBIPBX

#Remove current E4 license and reassign new E5 license
foreach ($i in Get-MsolUser -EnabledFilter EnabledOnly -All | Where {$_.Licenses.AccountSkuId -eq 'CompanyName:ENTERPRISEWITHSCAL'}) {
    $i | Set-MsolUserLicense -RemoveLicenses 'CompanyName:ENTERPRISEWITHSCAL' -AddLicenses 'CompanyName:ENTERPRISEPREMIUM_NOPBIPBX'
}
