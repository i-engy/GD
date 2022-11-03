



<#
    fetch the SID user a user
    apply the SID to a particular folder in a windows Vm
    on that folder also remove inheritance and authenticated users
#>
#user input folder name
#$dir = Read-Host "Enter a Directory path"
<#
#check if user input is empty
if($dir.Length -eq 0){
    Write-Host "Directory name cannot be empty" -ForegroundColor Red
    break script
}
#>


$dirList = @()
$dirList += 'D:\1test'              #directory 1
# $dirList += 'D:\test'               #directory 2
# $dirList += 'D:\shell'              #directory 3


#get logged in user name
$username = $env:USERNAME

$SID = Read-Host -Prompt 'Provide SID of user: '
$ChangePermissions = Read-Host -Prompt 'Change user permissions or not: (y/n)'

Write-Output "Curent username: $username"
Write-Output "Fetching SID of user..."
# #get SID of user
# $SID = ((get-aduser "$username"  -Properties * | select SID).SID).value

Write-Output "Processing Directories..."
foreach ($dir in $dirList) {
    #check if directory exists
    if (Test-Path "$dir") {

        Write-Output "Getting permission details of '$dir' '$ChangePermissions'"
        #get ACL
        $acl = Get-Acl "$dir"

        if (($ChangePermissions -eq "y") -or ($ChangePermissions -eq "Y")) {
            Write-Host "Change ownership."

            $acl.SetOwner((New-Object System.Security.Principal.SecurityIdentifier($SID)))
            # Add the new user and preserve all current permissions: SetAccessRuleProtection(False, X)
            # Add the new user and remove all inherited permissions: SetAccessRuleProtection(True, False)
            # Add the new user and convert all inherited permissions to explicit permissions: SetAccessRuleProtection(True, True)
            $acl.SetAccessRuleProtection($true, $true)
        }
        elseif (($ChangePermissions -eq "n") -or ($ChangePermissions -eq "N")) {
            Write-Host "DONT Change Ownership and permissions."
        }
        else {
            Write-Host "Ignore options."
        }
        
        $sddl = "O:$SID"
        $acl.SetSecurityDescriptorSddlForm($sddl)
        Write-Output "Modifying permission details of '$dir'"

        #modifying permission
        #Store the new ACL to the Home Folder.
        Set-Acl -Path $dir -AclObject $ACL

    }
    else {
        Write-Host "Could not find '$dir'" -ForegroundColor Red
    }
}