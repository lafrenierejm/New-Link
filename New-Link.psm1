Function New-Link {
	Param (
		[Parameter(Mandatory=$TRUE, Position=0)]
		[ValidateSet('SymbolicLink', 'Junction', 'HardLink', 'Shortcut')]
		[string]$Type,

		[Parameter(Mandatory=$TRUE, Position=1)]
		[ValidateScript({Test-Path $_})]
		[string]$target,

		[Parameter(Mandatory=$TRUE, Position=2)]
		[string]$link
	)

	if ($Type -eq 'Shortcut') {
		# PoSH has no shortcut support, so we must use com objects
		$WshShell = New-Object -comObject WScript.Shell
		$Shortcut = $WshShell.CreateShortcut("$link")
		$Shortcut.TargetPath = "$target"
		$Shortcut.Save()
	} else {
		# Starting 5.0, PoSH supports symlinks
		New-Item -Path "$link" -ItemType $Type -Value "$target"
	}
}
New-Alias mklink New-Link
