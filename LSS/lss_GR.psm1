
function Add-LSSGroupFromFile {
    <#
        .SYNOPSIS
        Create Groups from a File
        .DESCRIPTION
        Use an input file to create Groups into a sample domain
        .PARAMETER FileName
        The path of the import file
        .EXAMPLE
        Create-LSSGroupFromFile -FilePath 'R:\Lab25606\25605_GR.csv'
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
        #$OldDebugPrefrence = $DebugPreference
        #$DebugPrefrence = Continue
    }
    Process {
        $InFile = Import-Csv $filename
        #Validate the properties of the incoming file
        if (-Not (([bool]($InFile[0].PSObject.Properties.Name -match "SamAccountName")) -and
                  ([bool]($InFile[0].PSObject.Properties.Name -match "Parent"))
                 )
           )
        {
            throw "Input file must have SamAccountName and Parent properties"
        }

        $InFile | ForEach-Object {
            $OUParent = $_.Parent.Replace("DC=X",$namingContext)
            $ObjectDetailText = "Group $($_.SamAccountName) under $($OUParent)"
            if ($PSCmdlet.ShouldProcess($_.SamAccountName, "Create Group"))
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
                    New-ADGroup -Name $_.SamAccountName -GroupCategory $_.Category -GroupScope $_.Scope -Path $OUParent
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
