<#
.SYNOPSIS
    Applocker module to create and edit policies based off of provided parameters.
.DESCRIPTION
    This module is written to speed up the process of making applocker rules for programs while making sure the rules remain legible and consistent.
    Focuses on only EXE rules at this time.
.NOTES
    TODO:
    1)Information storage for each software
    2)Parameters to specify what software to make rules for
    3)Comment and documentation moved to main modules
    4)Fix hash rules to check uniqueness on data not name
#>

#Set strict mode and import necessary modules
Set-StrictMode -Version 1.0
Import-Module Applocker

#Blank template for an applocker policy with EXE rules configured as enabled
$blankPolicy = [xml]@'
<AppLockerPolicy Version="1">
<RuleCollection Type="Exe" EnforcementMode="Enabled" />
<RuleCollection Type="Msi" EnforcementMode="NotConfigured" />
<RuleCollection Type="Script" EnforcementMode="NotConfigured" />
<RuleCollection Type="Dll" EnforcementMode="NotConfigured" />
</AppLockerPolicy>
'@

#Blank Hash rule configured with the 'Everyone' group SID
$blankHashRule = [xml]@'
<FileHashRule Id="" Name="" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
<Conditions>
<FileHashCondition />
</Conditions>
</FileHashRule>
'@

#Given a valid file Path
#Returns XML Applocker policy
function Get-RuleSet {
    [CmdletBinding()]
    Param
    (
        #File Path to check
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]$Path
    )

    Write-Verbose -Message "Making rules for $Path"

    #Initilize variables
    $fileInfo = $null
    $tempPolicy = $null
    
    #Recurse through the target path looking for *.exe file extensions |
    #Select the Full Path to the file |
    #Get the Applocker File Information to store in $fileInfo
    $fileInfo += Get-ChildItem -Path $Path -Filter '*.exe' -Recurse | Select-Object -ExpandProperty fullname | Get-AppLockerFileInformation -ErrorAction silentlycontinue
    
    #Force $tempPolicy to XML type |
    #Create a new Applocker policy based off of the $fileInfo, preferring publisher rules, then hash rules
    $tempPolicy = [xml]($fileInfo | New-AppLockerPolicy -RuleType Publisher, Hash -User Everyone -Xml -IgnoreMissingFileInformation)
    
    return $tempPolicy
}

#Given XML Applocker policy, String ProgramName, String Level
#Return XML Applocker policy
function Edit-ApplockerPolicy {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]$tempPolicy,

        [Parameter(Mandatory=$true,
                   Position=1)]$programName,
                   
        [Parameter(Mandatory=$true,
                   Position=2)]$level
    )

    Write-Verbose -Message "Star-ing out Version numbers and BinaryName for entire policy and correcting rule name"

    #Initilize Variables
    $product = $null
    $publisher = $null
    $binaryName = $null
    $lowVersion = $null
    $highVersion = $null
    $newName = $null

    #FilePublisherRule Processing
    foreach($i in $tempPolicy.ApplockerPolicy.RuleCollection.FilePublisherRule) {
    
        #Get the needed variables from the rule before processing
        $product = $i.Conditions.FilePublisherCondition.GetAttribute('ProductName')
        $publisher = $i.Conditions.FilePublisherCondition.GetAttribute('PublisherName')
        $binaryName = $i.Conditions.FilePublisherCondition.GetAttribute('BinaryName')
        $lowVersion = $i.Conditions.FilePublisherCondition.BinaryVersionRange.GetAttribute('LowSection')
        $highVersion = $i.Conditions.FilePublisherCondition.BinaryVersionRange.GetAttribute('HighSection')
        
        #Different processing depending on the indicated $Level
        #Inputs the name and stars out attributes below the indicated $Level
        Switch ($Level) {
            'PublisherName' {$newName = $programName + ': All software signed by ' + $publisher
                             $i.Conditions.FilePublisherCondition.GetAttributeNode('ProductName').InnerText = '*'
                             $i.Conditions.FilePublisherCondition.GetAttributeNode('BinaryName').InnerText = '*'
                             $i.Conditions.FilePublisherCondition.BinaryVersionRange.GetAttributeNode('LowSection').InnerText = '*'
                             $i.Conditions.FilePublisherCondition.BinaryVersionRange.GetAttributeNode('HighSection').InnerText = '*'
                             break}
            'ProductName' {$newName = $programName + ': ' + $product + ' signed by ' + $publisher
                           $i.Conditions.FilePublisherCondition.GetAttributeNode('BinaryName').InnerText = '*'
                           $i.Conditions.FilePublisherCondition.BinaryVersionRange.GetAttributeNode('LowSection').InnerText = '*'
                           $i.Conditions.FilePublisherCondition.BinaryVersionRange.GetAttributeNode('HighSection').InnerText = '*'
                           break}
            'BinaryName' {$newName = $programName + ': Binary ' + $binaryName + ' for ' + $product + ' signed by ' + $publisher
                          $i.Conditions.FilePublisherCondition.BinaryVersionRange.GetAttributeNode('LowSection').InnerText = '*'
                          $i.Conditions.FilePublisherCondition.BinaryVersionRange.GetAttributeNode('HighSection').InnerText = '*'
                          break}
            'LowVersion' {$newName = $programName + ': Binary ' + $binaryName + ' for ' + $product + ' ' + $LowVersion + ' and higher signed by ' + $publisher
                          $i.Conditions.FilePublisherCondition.BinaryVersionRange.GetAttributeNode('HighSection').InnerText = '*'
                          break}
            'HighVersion' {$newName = $programName + ': Binary ' + $binaryName + ' for ' + $product + ' ' + $LowVersion + ' to ' + $HighVersion + ' signed by ' + $publisher
                           break}
        }
        $i.GetAttributeNode('Name').InnerText = $newName
    }
    return $tempPolicy
}

#Given an XML Applocker Policy
#Returns an XML policy of unique publishers
function Select-UniquePublishers {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]$tempPolicy
    )

    Write-Verbose -Message "Selecting unique publisher rules only"
    
    #Initilize Variables
    $uniquePublishers = $null

    #Select the FilePublisherRule Nodes |
    #Use Sort-Object to select ones with unique names
    $uniquePublishers = ($tempPolicy.SelectNodes('//RuleCollection[@Type="Exe"]/FilePublisherRule') | Sort-Object -Property Name -Unique)

    return $uniquePublishers
}

#Given an XML Applocker Policy
#Returns an XML policy of unique hash rules
function Select-UniqueHashes {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]$tempPolicy
    )

    Write-Verbose -Message "Selecting unique hash rules only"

    #Initilize Variables
    $uniqueHashes = $null

    #Select the FileHashRule Nodes |
    #Use Sort-Object to select ones with unique names
    $uniqueHashes = ($tempPolicy.SelectNodes('//RuleCollection[@Type="Exe"]/FileHashRule/Conditions/FileHashCondition/FileHash') | Sort-Object -Property Data -Unique)

    return $uniqueHashes
}

#Given XML policy of Unique Hash rules, String ProgramName
#Returns a single XML hash rule containing all the unique hashes
function Merge-HashRules {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,
                    Position=0)]$uniqueHashes,

        [Parameter(Mandatory=$true,
                   Position=1)]$programName
    )

    Write-Verbose -Message "Merging HashRules into single rule"

    #Initilize Variables
    $newName = $null
    $newHashRule = $null

    #Clone the Hash Rule template
    $newHashRule = $blankHashRule.clone()
    
    #Generate and drop in place a new GUID for the rule
    $newHashRule.FileHashRule.id = [string]([guid]::NewGuid().guid)
    
    #Indicate the Node where rules get dropped under
    $parentNode = $newHashRule.SelectSingleNode('/FileHashRule/Conditions/FileHashCondition')

    #Append each unique hash into the single has rule
    $uniqueHashes | % {
        [void]$parentNode.AppendChild($newHashRule.ImportNode($_, $true))
    }
    
    #Make and insert the name of the hash rule
    $newName = $programName + ': File Hashes'
    $newHashRule.FileHashRule.getAttributeNode('Name').InnerText = $newName

    return $newHashRule
}

#Given XML policy of uniquePublishers, XML hashRule
#Returns XML Applocker policy
function New-FinalApplockerPolicy {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false,
                   Position=0)]$uniquePublishers,
                   
        [Parameter(Mandatory=$false,
                   Position=1)]$hashRule
    )

    Write-Verbose "Creating the final policy"

    #Clone the Applocker policy template
    $finalPolicy = $blankPolicy.clone()

    #Indicate the node where rules get dropped under
    $parentNode = $finalPolicy.ApplockerPolicy.SelectSingleNode('//RuleCollection[@Type="Exe"]')
    
    #Insert the publisher rules
    if ($uniquePublishers) {
        $uniquePublishers | % {
            [void]$parentNode.appendChild($finalPolicy.ImportNode($_, $true))
        }
    }
    
    #Insert the hash rule
    if ($hashRule) {
        $hashRule.FileHashRule | % {
            [void]$parentNode.appendChild($finalPolicy.ImportNode($_, $true))
        }
    }
    return $finalPolicy
}

function Get-ApplicationApplockerPolicy {
    <#
    .SYNOPSIS
        The main function that handles the creation and editing of the applocker policy
    .DESCRIPTION
        
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
    .EXAMPLE
        No Export; Publisher Level
        Creates an Applocker Policy based off the files at "C:\Program Files (x86)\VMware"
        Edits the policy to enforce at the Publisher level and prefaces each rule with "VMWare:"

        Get-ApplicationApplockerPolicy -Name "VMware" -Path "C:\Program Files (x86)\VMware" -Level 'PublisherName'
    .EXAMPLE
        Export; Product Level
        Creates an Applocker Policy based off the files at "C:\Program Files (x86)\VMware"
        Edits the policy to enforce publisher rules at the Product level and prefaces each rule with "VMWare:"
        Saves the policy to the current execution path with the filename VMWare Rules.xml

        Get-ApplicationApplockerPolicy -Name "VMware" -Path "C:\Program Files (x86)\VMware" -Level 'ProductName' -FileName 'VMWare Rules.xml' -Export
    .PARAMETER Name
        Sets what each rule's name in the policy will be prefaced with. Should be the name of the software you are creating a policy for.
    .PARAMETER Path
        Path where the files you wish to create a policy for are located. Searches recursively through the path for EXE files.
    .PARAMETER Level
        Specifies what level publisher rules should be enforced to. Input must match the below options exactly.
        Options for $Level:
            PublisherName
            ProductName
            BinaryName
            LowVersion
            HighVersion
    .PARAMETER FileName
        When the -Export flag is used, this is the file name the policy is saved to. Include the .xml at the end.
    .PARAMETER Export
        When the -Export flag is used, the script saves the policy to the filename specified.
    #>
    
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0)]
            [string]$Name,

        [Parameter(Mandatory=$true,Position=1)]
            [string]$Path,
        
        [Parameter(Mandatory=$true,Position=2)]
            [ValidateSet("PublisherName","ProductName","BinaryName","LowVersion","HighVersion")]
            [string]$Level,
                   
        [Parameter(Mandatory=$false,Position=3)]
            [string]$FileName,
                   
        [Parameter(Mandatory=$false,Position=4)]
            [switch]$Export
    )

    Write-Verbose "Creating Applocker rules for $Name at location $Path, then saving to $fileName"

    #Initilize Variables
    $uniquePublishers = $null
    $uniqueHashes = $null
    $finalPolicy = $null
    $hashRule = $null
    $tempPolicy = $null

    #Get the auto-generated Applocker Policy
    $tempPolicy = Get-RuleSet -Path $Path
    
    #If there are publisher rules, edit them to match the specified level and get the unique publisher rules
    if ($tempPolicy.AppLockerPolicy.RuleCollection.FilePublisherRule) {
        $tempPolicy = Edit-ApplockerPolicy -tempPolicy $tempPolicy -programName $Name -Level $Level
        $uniquePublishers = Select-UniquePublishers -tempPolicy $tempPolicy
    }
    
    #If there are hash rules, get the unique hashes and merge them to a single hash rule
    if ($tempPolicy.AppLockerPolicy.RuleCollection.FileHashRule) {
        $uniqueHashes = Select-UniqueHashes -tempPolicy $tempPolicy
        $hashRule = Merge-HashRules -uniqueHashes $uniqueHashes -programName $Name
    }
    
    #Create the final Applocker Policy
    if ($uniquePublishers -And $hashRule) {
        $finalPolicy = New-FinalApplockerPolicy -uniquePublishers $uniquePublishers -hashRule $hashRule
    }
    elseif ($uniquePublishers -And (-Not $hashRule)) {
        $finalPolicy = New-FinalApplockerPolicy -uniquePublishers $uniquePublishers
    }
    elseif ($hashRule -And (-Not $uniquePublishers)) {
        $finalPolicy = New-FinalApplockerPolicy -hashRule $hashRule
    }
    
    #Save to $FileName
    if ($Export) {
        Write-Verbose "Saving Final Policy"
        $finalPolicy.save($FileName)
    }
    
    return $finalPolicy
}

function Merge-ApplockerPolicies {
    <#
    .SYNOPSIS
        Merges two applocker policies together while getting rid of duplicate rules.
        
        DO NOT USE for policies that were not created with this module.
    .DESCRIPTION
        
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
    .EXAMPLE
        No Export;
    .EXAMPLE
        
    .PARAMETER One
        
    .PARAMETER Two
        
    .PARAMETER FileName
        When the -Export flag is used, this is the file name the policy is saved to. Include the .xml at the end.
    .PARAMETER Export
        When the -Export flag is used, the script saves the policy to the filename specified.
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false,
                   Position=0)][string]$One,

        [Parameter(Mandatory=$false,
                   Position=0)][string]$Two,
                   
        [Parameter(Mandatory=$false,
                   Position=2)][string]$FileName,
                   
        [Parameter(Mandatory=$false,
                   Position=3)][switch]$Export
    )

    Write-Verbose -Message "Merging policies $One and $Two"

    #Initilize Variables
    $policyOne = $null
    $policyTwo = $null
    $hashes = $null
    $publishers = $null
    $paths = $null

    #Get the policies content and force to XML type
    $policyOne = [xml](Get-Content -Path $One)
    $policyTwo = [xml](Get-Content -Path $Two)

    #Clone the blank Applocker policy template
    $newPolicy = $blankPolicy.clone()

    #Combine the file hashes |
    #Select the unique rules based off of the Names
    $hashes = @($policyOne.ApplockerPolicy.SelectNodes('//RuleCollection[@Type="Exe"]//FileHashRule') +
                $policyTwo.ApplockerPolicy.SelectNodes('//RuleCollection[@Type="Exe"]//FileHashRule') | Sort-Object -Property Name -Unique)

    #Combine the publisher rules |
    #Select the unique rules based off of the Names
    $publishers = @($policyOne.ApplockerPolicy.SelectNodes('//RuleCollection[@Type="Exe"]//FilePublisherRule') +
                    $policyTwo.ApplockerPolicy.SelectNodes('//RuleCollection[@Type="Exe"]//FilePublisherRule') | Sort-Object -Property Name -Unique)
    
    #Combine the path rules |
    #Select the unique rules based off of the Names
    $paths = @($policyOne.ApplockerPolicy.SelectNodes('//RuleCollection[@Type="Exe"]//FilePathRule') +
               $policyTwo.ApplockerPolicy.SelectNodes('//RuleCollection[@Type="Exe"]//FilePathRule') | Sort-Object -Property Name -Unique)

    #Indicate the node that rules need to be dropped in under
    $parentNode = $newPolicy.ApplockerPolicy.SelectSingleNode('//RuleCollection[@Type="Exe"]')
    
    #Insert all the rules
    $hashes | % {
        [void]$parentNode.appendChild($newPolicy.ImportNode($_, $true))
    }

    $publishers | % {
        [void]$parentNode.appendChild($newPolicy.ImportNode($_, $true))
    }

    $paths | % {
        [void]$parentNode.appendChild($newPolicy.ImportNode($_, $true))
    }

    #Save to $Filename
    if ($Export) {
        Write-Verbose "Saving Merged Policy"
        $newPolicy.save($FileName)
    }
    
    return $newPolicy
}

#Expose these two functions to the module user
Export-ModuleMember -Function Get-ApplicationApplockerPolicy
Export-ModuleMember -Function Merge-ApplockerPolicies
