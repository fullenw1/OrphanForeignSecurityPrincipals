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
Copy this module to a computer which has the ActiveDirectory module
(usually to C:\Program Files\Windows Powershell\Modules)
## Export format
Because the export contains both Foreign Security Principal's Distinguished Names (with coma inside)
and group membership (with semi-colon inside), the choice has been made to export the list in a tab delimited format.

Therefore, if you edit the export in Excel, you must save modifications as a <.txt> file.

Another way to edit the export is with any "neutral" text editor like Notepad.
## Common parameters
Common parameters like `-WhatIf`, `-Verbose` and `-Confirm` are fully supported.
## Warning
To determine if a Foreign Security Principal is orphan or not,
this module tries to resolve the SID to a name.

If you encounter connectivity issues, the name resolution will fail,
and Foreign Security Principals will be incorrectly interpreted as an orphan..

Thus, the preferred method to remove orphan Foreign Security Principals is via a file,
because you can have look at the list before the removal.

You can also simulate a deletion whit the -WhatIf parameter.
## Restoring removed Foreign Security Principals
- Restore via Powershell from the Recycle Bin (must be activated before any deletion occurred).
More about activating the Recycle Bin can be found [here](https://technet.microsoft.com/en-us/library/dd379481(v=ws.10).aspx)
1. First, find your object(s) with a query like this one:
```Powershell
Get-ADObject -Filter 'IsDeleted -eq $TRUE' -IncludeDeletedObjects | Where-Object {$_.DistinguishedName -like "CN=S-*"}
```
2. Then pipe it to the `Restore-ADObject` cmdlet.
- Add the foreign account or group into all groups where it has formerly been.
This will create the same ForeignSecurityPrincipal again.
**Hint:** If you have still the export file which you used to remove the ForeignSecurityPincipals,
there is a column inside with the group membership.
## Automation
There are several ways to keep your Active Directory clean from orphan Foreign Security Principals.
Here are some suggestions:
### Method 1: For better security
1. Schedule a script to export the list to a file and send a mail.
2. Review the file and update if necessary.
3. Use the `Remove-OrphanForeignSecurityPrincipal` cmdlet associated with the file.
### Method 2: Balanced effort
1. Schedule a script to export and count the number of entries.
2. Depending on X which is the average number of accounts you deleted in your environment since your last cleanup:
- If the script finds less than X orphan Foreign Security Principals,
the script removes them directly.
- If the script finds more then X orphan Foreign Security Principals,
the script sends a mail with the export as an attachment for further verification.
3. If the script has sent a mail, review the file and update if necessary.
4. If you reviewed the file, use the `Remove-OrphanForeignSecurityPrincipal` cmdlet associated with this file.
