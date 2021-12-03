
function Add-LSSGroupMemberFromFile {
    <#
        .SYNOPSIS
        Create GroupMembers from a File
        .DESCRIPTION
        Use an input file to create GroupMembers into a sample domain
        .PARAMETER FileName
        The path of the import file
        .EXAMPLE
        Create-LSSGroupMemberFromFile -FilePath 'R:\Lab25606\25605_UG.csv'
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
        #$OldDebugPrefrence = $DebugPreference
        #$DebugPrefrence = Continue
    }
    Process {
        $InFile = Import-Csv $filename
        #Validate the properties of the incoming file
        if (-Not (([bool]($InFile[0].PSObject.Properties.Name -match "SamAccountName")) -and
                  ([bool]($InFile[0].PSObject.Properties.Name -match "GroupSamAccountName"))
                 )
           )
        {
            throw "Input file must have SamAccountName and GroupSamAccountName properties"
        }

        $InFile | ForEach-Object {
            $ObjectDetailText = "GroupMember $($_.SamAccountName) under $($_.GroupSamAccountName)"
            if ($PSCmdlet.ShouldProcess($_.SamAccountName, "Create GroupMember"))
            {
                $parentPathTest = [bool](Get-ADGroup -Identity $_.GroupSamAccountName -ErrorAction SilentlyContinue)
                
                Write-Debug "Test for User $($_.Name) Exist"
                $pathTest = [bool](Get-ADUser -Filter "(sAMAccountName -eq '$($_.SamAccountName)')" -SearchBase $namingContext -ErrorAction SilentlyContinue)

                if ($pathTest -and ($parentPathTest)) {
                    Write-Output "Creating $($ObjectDetailText)"
                    Add-ADGroupMember -Identity $_.GroupSamAccountName -Members $_.SamAccountName
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
