Function Get-OrphanForeignSecurityPrincipal
{
    <#
    .SYNOPSIS
        Find orphan ForeignSecurityPrincipals.
    .DESCRIPTION
        Find orphan ForeignSecurityPrincipals by triying to resolve SIDs to a names.
    .PARAMETER TabDelimitedFile
        Export the result to a .TXT file with tab separated values.
        If the file exists, it will be automatically overwritten.
    .EXAMPLE
        Get-OrphanForeignSecurityPrincipal -TabDelimitedFile c:\temp\OFSP.txt
    .OUTPUTS
        Name: Object[]
        Base Type: System.Array
    .NOTES
        AUTHOR: FULLENWARTH Luc
        LASTEDIT: 09/04/2017
        VERSION:1.1.0
    .LINK
        Get-OrphanForeignSecurityPrincipal.ps1
    #>

    [Alias('fofsp')]

    [CmdletBinding()]

    [OutputType([System.Collections.ArrayList])]

    Param(
        [Parameter(HelpMessage = 'A file name or a full path')]
        [String]$TabDelimitedFile
    )

    Begin
    {
        #Requires -Module ActiveDirectory

        If ($PSBoundParameters['Debug'])
        {$DebugPreference = 'Continue'}
    }

    Process
    {
        $OrphanForeignSecurityPrincipals = @()

        $DomainSIDList = Find-AllDomainsAndSID

        Write-Verbose -Message 'Searching for orphan Foreign Security Principals...'

        $Params = @{
            Filter     = {ObjectClass -eq 'foreignSecurityPrincipal'}
            Properties = @('MemberOf', 'objectSid')
        }
        $ForeignSecurityPrincipalList = Get-ADObject @Params

        Write-Verbose -Message 'Starting Foreign Security Principals name resolution...'
        foreach ($ForeignSecurityPrincipal in $ForeignSecurityPrincipalList)
        {
            Try #Try to resolve name
            {
                $FSPTranslation = (New-Object System.Security.Principal.SecurityIdentifier($ForeignSecurityPrincipal.objectSid)).
                Translate([System.Security.Principal.NTAccount])
                Write-Debug -Message "Resolved $FSPTranslation"
            }
            Catch #Find matching domain name
            {
                $DistinguishedName = $ForeignSecurityPrincipal.DistinguishedName
                $MemberOf = $ForeignSecurityPrincipal.MemberOf

                #Search domain name
                $DomainName = 'Domain not found'
                foreach ($DomainSID in $DomainSIDList.GetEnumerator())
                {
                    If ($DistinguishedName.Contains($DomainSID.Value))
                    {
                        $DomainName = $DomainSID.Key
                        Break
                    }
                }

                If ($DomainName -eq 'Domain not found')
                {Write-Debug -Message "Could not resolve domain name for $DistinguishedName"}

                $Item = [PSCustomObject]@{
                    DistinguishedName = $DistinguishedName
                    DomainName        = $DomainName
                    MemberOf          = $MemberOf -join ';'
                }

                $OrphanForeignSecurityPrincipals += $Item
            }
        }

        If ($TabDelimitedFile -and $OrphanForeignSecurityPrincipals)
        {
            Write-Verbose 'Exporting to Tab delimited file...'

            $Params = @{
                NoTypeInformation = $true
                Path              = $TabDelimitedFile
                Force             = $true
                Delimiter         = "`t"
            }

            $OrphanForeignSecurityPrincipals|Export-Csv @Params
        }
    }

    End
    {
        $OrphanForeignSecurityPrincipals
    }
}

Function Find-AllDomainsAndSID
{
    <#
    .SYNOPSIS
        Find all domain names and associated SIDs.
    .DESCRIPTION
        Find all domain names and associated SIDs.
    .EXAMPLE
    .OUTPUTS
        Hashtable containing all domain names and associated SIDs.
    .NOTES
        AUTHOR: FULLENWARTH Luc
        LASTEDIT: 09/04/2017
        VERSION:1.0.0
    .LINK
        Get-OrphanForeignSecurityPrincipal.ps1
    #>

    Begin
    {
        #Requires -Version 4
        #Requires -Module ActiveDirectory
    }

    Process
    {
        Write-Verbose -Message 'Searching for domain SIDs and names...'

        $DomainSIDList = @{}

        Try {$AllTrustedDomains = Get-ADTrust -Filter *}
        Catch
        {
            Write-Warning -Message 'Your computer cannot run the Get-ADTrust cmdlet.
This does not impact the orphan FSP detection but you will not know from which domain the orphan FSP is coming.'
        }

        foreach ($Domain in $AllTrustedDomains)
        {
            $DomainFullName = $Domain.Name

            Write-Debug -Message "Found $DomainFullName"

            #Sometimes the trust don't exist anymore or the domain is unavailable
            Try {$DomainSID = (Get-ADDomain -Identity $DomainFullName).DomainSID}
            Catch {$DomainSID = 'Domain SID resolution failed'}

            Write-Debug -Message "Resolved to $DomainSID"

            $DomainSIDList.$DomainFullName = $DomainSID
        }
    }

    End {$DomainSIDList}
}
