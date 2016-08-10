function New-Link {
    <#
    .SYNOPSIS
        Creates a filesystem link or shortcut.

    .DESCRIPTION
        The New-Link cmdlet provides a unified interface for creating any type of filesystem link, including shortcuts.

    .PARAMETER Type
        The type of link to create

    .PARAMETER Source
        The path of the item to which the created link will point

    .PARAMETER Destination
        The path at which to create the link object

    .OUTPUTS
        Either a new WScript.Shell object if the specified type is 'Shortcut' or a new item of the specified type.

    .LINK
        New-Item
        New-Object

    .COMPONENT
        New-Item
        New-Object
    #>
    [CmdletBinding(
        SupportsShouldProcess = $TRUE
    )]
    param (
        [Parameter(Mandatory=$TRUE, Position=0)]
        [ValidateSet('SymbolicLink', 'Junction', 'HardLink', 'Shortcut')]
        [string]$Type,

        [Parameter(Mandatory=$TRUE, Position=1)]
        [ValidateScript({Test-Path "$_"})]
        [string]$Source,

        [Parameter(Mandatory=$FALSE, Position=2)]
        [string]$Destination
    )

    process {
        # PowerShell has no native shortcut support, so those are handled with COM objects
        if ($Type -eq 'Shortcut') {
            # A shortcut's extensions must be either '.lnk' or '.url'
            if ((-not ("$Destination".EndsWith('.lnk'))) -and (-not ("$Destination".EndsWith('.url')))) {
                throw "The shortcut pathname must end with '.lnk' or '.url'."
            }
            if ($PSCmdlet.ShouldProcess($Destination, 'Create Shortcut')) {
                # Get the full path of $Source
                $SourcePathInfo = Resolve-Path -Path "$Source"
                $SourceFullPath = $(Get-Item -Path "$SourcePathInfo").FullName
                Write-Debug "The full path to the source is `"$SourceFullPath`""

                # Create the shortcut to $SourceFullPath
                $WshShell = New-Object -comObject WScript.Shell
                $Shortcut = $WshShell.CreateShortcut("$Destination")
                $Shortcut.TargetPath = "$SourceFullPath"
                $Shortcut.Save()
            }
        } else {
            if ($PSCmdlet.ShouldProcess($Destination, 'Create Link')) {
                # Starting with version 5.0, PoSH has native symlink support
                New-Item -Path "$Destination" -ItemType $Type -Value "$Source"
            }
        }
    }
}
New-Alias mklink New-Link

Export-ModuleMember -function New-Link
Export-ModuleMember -alias mklink
