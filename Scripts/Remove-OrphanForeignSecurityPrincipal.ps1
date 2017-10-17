Function Remove-OrphanForeignSecurityPrincipal
{
    <#
    .SYNOPSIS
        Remove orphan ForeignSecurityPrincipals based on their SID numbers.
    .DESCRIPTION
        Remove orphan ForeignSecurityPrincipals based on their SID numbers.
    .PARAMETER DistinguishedName
        List of SIDs to remove
        Mutualy exclusive with the TabDelimitedFile parameter.
    .PARAMETER TabDelimitedFile
        Path of a .TXT file.
        This file must be an Tab delimited file
        containing at least one column with exactly 'DistinguishedName' as header.
        Mutualy exclusive with the DistinguishedName parameter.
    .EXAMPLE
        Use an imput file.

        Remove-OrphanForeignSecurityPrincipal -TabDelimitedFile c:\temp\OFSP.txt
    .EXAMPLE
        Pipe the result of the Find-OrphanForeignSecurityPrincipal cmdlet the the Remove-OrphanForeignSecurityPrincipal cmdlet.

        Find-OrphanForeignSecurityPrincipal |select -First 5|Remove-OrphanForeignSecurityPrincipal
    .EXAMPLE
        Specify ForeignSecurityPrincipals' distinguished names as parameter.

        Remove-OrphanForeignSecurityPrincipal -DistinguishedName 'CN=S-1-5-21-1595408694-1749029380-1551332766-35442,CN=ForeignSecurityPrincipals,DC=contoso,DC=com','CN=S-1-5-21-1595408694-1749029380-1551332766-37718,CN=ForeignSecurityPrincipals,DC=contoso,DC=com'
    .INPUTS
        System.String[]
    .NOTES
        AUTHOR: FULLENWARTH Luc
        LASTEDIT: 09/04/2017
        VERSION:1.0.0
    .LINK
        Remove-OrphanForeignSecurityPrincipal.ps1
    #>

    [Alias('rofsp')]

    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = 'Pipe'
    )]

    Param(
        [Parameter(
            ParameterSetName = 'Pipe',
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [Array]$DistinguishedName,

        [Parameter(
            ParameterSetName = 'File',
            HelpMessage = 'A file name or a full path.'
        )]
        [ValidateScript( {Test-Path -Path $_})]
        [String]$TabDelimitedFile
    )

    Begin
    {
        #Requires -Modules ActiveDirectory

        If ($PSBoundParameters['Debug'])
        {$DebugPreference = 'Continue'}

        If ($PSBoundParameters['TabDelimitedFile'])
        {
            Write-Verbose 'Parsing file...'
            $Params = @{
                Path      = $TabDelimitedFile
                Delimiter = "`t"
            }

            $OrphanFSPList = Import-Csv @Params

            If ($OrphanFSPList)
            {
                foreach ($OrphanFSP in $OrphanFSPList)
                {
                    $Message = "Found {0}" -f $OrphanFSP.DistinguishedName
                    Write-Debug -Message $Message

                    $DistinguishedName += $OrphanFSP.DistinguishedName
                }
            }
            Else
            {Throw "The $$TabDelimitedFile file is empty!"}
        }
    }

    Process
    {
        foreach ($DN in $DistinguishedName)
        {
            If ($PSCmdlet.ShouldProcess($DN, 'Remove'))
            {Remove-ADObject -Identity $DN -Confirm:$false}
        }
    }

    End {}
}
