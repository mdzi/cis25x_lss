
function Add-LSSUserFromFile {
    <#
        .SYNOPSIS
        Create Users from a File
        .DESCRIPTION
        Use an input file to create Users into a sample domain
        .PARAMETER FileName
        The path of the import file
        .EXAMPLE
        Create-LSSUserFromFile -FilePath 'R:\Lab25606\25605_US.csv'
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            if (-Not ($_ | Test-Path -PathType Leaf)) {
                throw "Input file does not exist"
            }
            if ($_ -NotMatch "(\.csv)") {
                throw "Input file name pattern is incorrect"
            }
            return $true
        })]
        [System.IO.FileInfo]$FileName
    )
    Begin {
        Import-Module ActiveDirectory
        $namingContext = ((Get-ADRootDSE).defaultNamingContext)
        $domainDnsName = ""
        #hack to get the default UPN Suffix
        Get-ADDomainController | ForEach-Object { $domainDnsName = $_.Domain }
        #$OldDebugPrefrence = $DebugPreference
        #$DebugPrefrence = Continue
    }
    Process {
        $InFile = Import-Csv $filename
        #Validate the properties of the incoming file
        if (-Not (([bool]($InFile[0].PSObject.Properties.Name -match "SamAccountName")) -and
                  ([bool]($InFile[0].PSObject.Properties.Name -match "Parent")) -and
                  ([bool]($InFile[0].PSObject.Properties.Name -match "Surname")) -and
                  ([bool]($InFile[0].PSObject.Properties.Name -match "GivenName")) -and
                  ([bool]($InFile[0].PSObject.Properties.Name -match "Initials")) -and
                  ([bool]($InFile[0].PSObject.Properties.Name -match "DisplayName")) -and
                  ([bool]($InFile[0].PSObject.Properties.Name -match "Password"))
                 )
           )
        {
            throw "Input file must have SamAccountName, Parent, Surname, GivenName, Initials, DisplayName, and Password properties"
        }

        $InFile | ForEach-Object {
            $OUParent = $_.Parent.Replace("DC=X",$namingContext)
            $ObjectDetailText = "User $($_.SamAccountName) under $($OUParent)"
            if ($PSCmdlet.ShouldProcess($_.SamAccountName, "Create User"))
            {
                $parentPathTest = $true
                $pathTest = $false
                if ($OUParent -ne $namingContext) {
                    Write-Debug "Test for Parent $($OUParent) Exist"
                    $parentPathTest = [bool](Get-ADOrganizationalUnit -Identity $OUParent -ErrorAction SilentlyContinue)
                }
                
                Write-Debug "Test for Object $($_.Name) Exist"
                $pathTest = [bool](Get-ADObject -Filter "(sAMAccountName -eq '$($_.SamAccountName)')" -SearchBase $namingContext -ErrorAction SilentlyContinue)

                if (-Not $pathTest -and ($parentPathTest)) {
                    Write-Output "Creating $($ObjectDetailText)"
                    $ssPassword = ConvertTo-SecureString -String $_.Password -AsPlainText -Force
                    New-ADUser -Name $_.SamAccountName -AccountPassword $ssPassword -Enabled $true -Surname $_.Surname -GivenName $_.GivenName -Initials $_.Initials -DisplayName $_.DisplayName -Path $OUParent
                } else {
                    Write-Error "Object $($ObjectDetailText) exists $($pathTest) or parent does not $($parentPathTest)"
                }
            }
        }
    }
    End {
        #$DebugPreference = $OldDebugPrefrence
    }
}
