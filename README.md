#How to use it
##Find orphan Foreign Security Principals
```Powershell
Get-OrphanForeignSecurityPrincipal
```
##Export orphan Foreign Security Principals to a file
```Powershell
Get-OrphanForeignSecurityPrincipal -TabDelimitedFile C:\temp\OFSP.txt
```
##Remove orphan Foreign Security Principals
###From the pipeline
```Powershell
Get-OrphanForeignSecurityPrincipal | Remove-OrphanForeignSecurityPrincipal
```
###From a file
```Powershell
Remove-OrphanForeignSecurityPrincipal -TabDelimitedFile C:\temp\OFSP.txt
```
###Manually
```Powershell
Remove-OrphanForeignSecurityPrincipal -DistinguishedName CN=S-1-5-21-1234567890-1234567890-1234567890-12345,CN=ForeignSecurityPrincipals,DC=contoso,DC=com
```
#Additional information
##Prerequisites
This module uses cmdlets from the Microsoft ActiveDirectory module.
##Preparation steps
Copy this module on a computer which has the ActiveDirectory module
(usually to C:\Program Files\Windows Powershell\Modules)
##Common parameters
Common parameters like -WhatIf, -Verbose and -Confirm are fully supported.
##Warning
To determine if a Foreign Security Principal is orphan or not,
this module tries to resolve the SID to a name.
If you encounter connectivity issues, the name resolution will fail,
and Foreign Security Principals will be incorectly interpreted as orphan.
Thus, the prefered method to remove orphan Foreign Security Principals is via a file,
because you can have look at the list before the removal.
