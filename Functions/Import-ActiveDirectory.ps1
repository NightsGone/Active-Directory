function Import-ActiveDirectory {

<#
.SYNOPSIS
    Imports ActiveDirectory Module
.DESCRIPTION
    Import-ActiveDirectory imports the ActiveDirectory Module from a specified server without the need to install RSAT (Remote System Administration Tools).
.EXAMPLE
    Import-ActiveDirectory
    This command prompts the user to input the specified server name and will attempt to import the ActiveDirectory module from that server.
.EXAMPLE
    Import-ActiveDirectory -ServerName "DC-01" -Credential (Get-Credential)
    This command will attempt to import the ActiveDirectory module from "DC-01" whilst using the credentials specified by 'Get-Credential' to authenticate.
.EXAMPLE
    $AdminCredentials = Get-Credential
    PS C:\>Import-ActiveDirectory -ServerName "DC-01" -Credential $AdminCredentials

    This command will store the credentials for authentication in $AdminCredentials and use those to authenticate against "DC-01" to import the ActiveDirectory module.    
.NOTES
    Author       : Brandon Hansen
    Contact      : brandon@v6networks.com.au
.LINK
    https://github.com/nightsgone
#>

    [CmdletBinding()]

    Param (
        [Parameter(Mandatory=$true)]
        [string]$ServerName,

        [System.Management.Automation.CredentialAttribute()] 
        $Credential 
    )

    BEGIN {
        Write-Verbose "Attempting to import ActiveDirectory Module from $ServerName"
    }

    PROCESS {

        if ($Credential) {
            
            Try {
                Write-Verbose "Connecting to $ServerName"
                $Session = New-PSSession -ComputerName $ServerName -Credential $Credential -ErrorAction Stop
                Invoke-Command -Session $Session -ScriptBlock {Import-Module ActiveDirectory}
                Import-PSSession -Session $Session -Module ActiveDirectory | Out-Null
                Write-Output 'ActiveDirectory Module successfully imported.'
            }
            Catch {
                Write-Verbose "Connecting to $ServerName failed"
                $ErrorMessage = $_.Exception.Message 
                
                if ($ErrorMessage -match 'The user name or password is incorrect') {
                    Write-Warning 'Username or Password is incorrect.'
                }
            }

        } else {

            Try {
                Write-Verbose "Connecting to $ServerName"
                $Session = New-PSSession -ComputerName $ServerName -ErrorAction Stop
                Invoke-Command -Session $Session -ScriptBlock {Import-Module ActiveDirectory}
                Import-PSSession -Session $Session -Module ActiveDirectory | Out-Null         
                Write-Output 'ActiveDirectory Module successfully imported.' 
            }
            Catch {
                Write-Verbose "Connecting to $ServerName failed"
                $ErrorMessage = $_.Exception.Message

                if ($ErrorMessage -match 'Access is denied') {
                    Write-Warning 'Access is denied. Please speicfy the -Credential parameter and try again.'
                }
            }
        }
    }
}