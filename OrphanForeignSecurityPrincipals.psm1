$ModulePath=Split-Path $MyInvocation.MyCommand.Path

$ScriptList=Get-ChildItem -Path "$ModulePath\Scripts" -Filter '*.ps1'|
            Where-Object -Property FullName -NotMatch '\.tests\.ps1$'

foreach($Script in $ScriptList)
{
    Try
        {
            $ScriptPath=$Script.FullName
            . $ScriptPath
        }
    Catch
        {
            Write-Warning ("{0}: {1}" -f $ScriptPath,$_.Exception.Message)
        }
}
