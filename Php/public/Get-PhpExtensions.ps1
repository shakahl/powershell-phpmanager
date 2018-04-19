function Get-PhpExtensions() {
    <#
    .Synopsis
    Lists the extensions for PHP installation.

    .Description
    Lists all the extensions found in a PHP installation (Builtin, Enabled and Disabled).

    .Parameter Path
    The path to the PHP installation.
    If omitted we'll use the one found in the PATH environment variable.

    .Outputs
    System.Array
    #>
    Param(
        [Parameter(Mandatory = $false, Position = 0, HelpMessage = 'The path to the PHP installation; if omitted we''ll use the one found in the PATH environment variable')]
        [ValidateNotNull()]
        [ValidateLength(1, [int]::MaxValue)]
        [string] $Path
    )
    Begin {
        $result = @()
    }
    Process {
        If ($Path -eq $null -or $Path -eq '') {
            $phpVersionsInPath = Get-Php
            If ($phpVersionsInPath.Count -eq 0) {
                Throw "No PHP versions found in the current PATHs: use the -Path argument to specify the location of installed PHP"
            }
            If ($phpVersionsInPath.Count -gt 1) {
                Throw "Multiple PHP versions found in the current PATHs: use the -Path argument to specify the location of installed PHP"
            }
            $phpVersion = $phpVersionsInPath[0]
        } Else {
            $Path = [System.IO.Path]::GetFullPath($Path)
            If (-Not(Test-Path -Path $Path)) {
                throw "Unable to find the directory/file $Path"
            }
            $phpVersion = Get-PhpVersionFromPath -Path $Path
        }
        $result += Get-PhpBuiltinExtensions -PhpVersion $phpVersion
        $dllExtensions = Get-PhpExtensionDetail -PhpVersion $phpVersion
        $activatedExtensions = Get-PhpActivatedExtensions -PhpVersion $phpVersion
        ForEach ($dllExtension in $dllExtensions) {
            If ($activatedExtensions | Where-Object {$_.Handle -eq $dllExtension.Handle}) {
                $dllExtension.State = $Script:EXTENSIONSTATE_ENABLED
            } Else {
                $dllExtension.State = $Script:EXTENSIONSTATE_DISABLED
            }
            $result += $dllExtension
        }
    }
    End {
        $result
    }
}
