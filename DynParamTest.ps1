function WorkingDynParam {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$ParamA,
        
        [Parameter(Mandatory=$true)]
        [string]$ParamB,
        
        [Parameter(Mandatory=$true)]
        [string]$ParamC
    )
    DynamicParam {
        # Set the dynamic parameters' name
        $ParameterName = 'DynParamA'
        
        # Create the dictionary 
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        
        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $true

        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)

        # Generate and set the ValidateSet 
        $arrSet = Get-ChildItem -Path "C:\Windows" -Directory | Select-Object -ExpandProperty BaseName
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)

        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }
    Begin {
        $DynParamA = $PSBoundParameters.DynParamA
    }
    Process {
        Write-Host "$($ParamA),$($ParamB),$($ParamC),$($DynParamA)"
    }
    End {
    
    }
}

function BrokenDynParam {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$ParamA,
        
        [Parameter(Mandatory=$true)]
        [string]$ParamB,
        
        [Parameter(Mandatory=$false)]
        [psobject]$Credential
    )
    DynamicParam {
        # Set the dynamic parameters' name
        $ParameterName = 'DynParamA'
        
        # Create the dictionary 
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
        
        # Create and set the parameters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $true

        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)

        # Generate and set the ValidateSet 
        $arrSet = Get-ChildItem -Path "C:\Windows" -Directory | Select-Object -ExpandProperty BaseName
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)

        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary
    }
    Begin {
        $DynParamA = $PSBoundParameters.DynParamA
        [pscredential]$Credential = $Credential
    }
    Process {
        Write-Host "$($ParamA),$($ParamB),$($Credential),$($DynParamA)"
    }
    End {
    
    }
}