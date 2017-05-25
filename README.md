# tl;dr or the short explanation
## Find orphan Foreign Security Principals
### Display them
```Powershell
Get-OrphanForeignSecurityPrincipal
```
### Display and export them to a file
```Powershell
Get-OrphanForeignSecurityPrincipal -TabDelimitedFile C:\temp\OFSP.txt
```
## Remove orphan Foreign Security Principals
### From the pipeline
```Powershell
Get-OrphanForeignSecurityPrincipal | Remove-OrphanForeignSecurityPrincipal
```
**For the pipeline method, please see the Warning section below!**
### From a file
```Powershell
Remove-OrphanForeignSecurityPrincipal -TabDelimitedFile C:\temp\OFSP.txt
```
### Manually
```Powershell
Remove-OrphanForeignSecurityPrincipal -DistinguishedName 'CN=S-1-5-21-1234567890-1234567890-1234567890-12345,CN=ForeignSecurityPrincipals,DC=contoso,DC=com'
```
# Additional information
## Prerequisites
This module uses cmdlets from the Microsoft ActiveDirectory module.
## Preparation steps
Copy this module on a computer which has the ActiveDirectory module
(usually to C:\Program Files\Windows Powershell\Modules)
## Common parameters
Common parameters like -WhatIf, -Verbose and -Confirm are fully supported.
## Warning
To determine if a Foreign Security Principal is orphan or not,
this module tries to resolve the SID to a name.

If you encounter connectivity issues, the name resolution will fail,
and Foreign Security Principals will be incorectly interpreted as orphan.

Thus, the prefered method to remove orphan Foreign Security Principals is via a file,
because you can have look at the list before the removal.
## Restoring removed Foreign Security Principals
- Via Active Directory recycle bin
- Via Powershell
1. First find your object(s) with a query like this one:
```Powershell
Get-ADObject -Filter 'IsDeleted -eq $TRUE' -IncludeDeletedObjects|?{$_.DistinguishedName -like "CN=S-*"}
```
2. Then pipe it to the `Restore-ADObject` cmdlet.
- Add the foreign account or group into all groups where it has formerly been.
This will create the same ForeignSecurityPrincipal again.
**Hint:** If you have still the export which you used to remove the ForeignSecurityPincipals,
there is a column inside with the groupmembership.
## Automation
There are several way to keep your Active Directory clean from orphan Foreign Security Principals.
Here are some suggestions:
### Method 1: For better security
1. Schedule a script to export the list to a file and send a mail.
2. Review the file and update if necessary.
3. Use the `Remove-OrphanForeignSecurityPrincipal` cmdlet associated to the file.
### Method 2: Balanced effort
1. Schedule a script to export and count the number of entries.
2. Depending on X which is the average number of accounts you delete in your environment:
- If the script finds less then X orphan Foreign Security Principals,
the script removes them directly.
- If the script finds more then X orphan Foreign Security Principals,
the script sends a mail with the export as attachment for further verification.
3. If the script has sent a mail, review the file and update if necessary.
4. If you reviewed the file, use the `Remove-OrphanForeignSecurityPrincipal` cmdlet associated to this file.
