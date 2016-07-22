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

    .PARAMETER Link
        The path of the link to create

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

        [Parameter(Mandatory=$TRUE, Position=2)]
        [string]$Link
    )

    process {
        # PowerShell has no native shortcut support, so those are handled with COM objects
        if ($Type -eq 'Shortcut') {
            if ($PSCmdlet.ShouldProcess($Link, 'Create Shortcut')) {
                # Get the full path of $Source
                $SourcePathInfo = Resolve-Path -Path "$Source"
                $SourceFullPath = $(Get-Item -Path "$SourcePathInfo").FullName
                Write-Debug "The full path to the source is `"$SourceFullPath`""

                # Create the shortcut to $SourceFullPath
                $WshShell = New-Object -comObject WScript.Shell
                $Shortcut = $WshShell.CreateShortcut("$Link")
                $Shortcut.TargetPath = "$SourceFullPath"
                $Shortcut.Save()
            }
        } else {
            if ($PSCmdlet.ShouldProcess($Link, 'Create Link')) {
                # Starting with version 5.0, PoSH has native symlink support
                New-Item -Path "$Link" -ItemType $Type -Value "$Source"
            }
        }
    }
}
New-Alias mklink New-Link

Export-ModuleMember -function New-Link
Export-ModuleMember -alias mklink
