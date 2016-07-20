Function New-Link {
	Param (
		[Parameter(Mandatory=$TRUE, Position=0)]
		[ValidateSet('SymbolicLink', 'Junction', 'HardLink', 'Shortcut')]
		[string]$Type,

		[Parameter(Mandatory=$TRUE, Position=1)]
		[ValidateScript({Test-Path $_})]
		[string]$Source,

		[Parameter(Mandatory=$TRUE, Position=2)]
		[string]$LinkName
	)

	if ($Type -eq 'Shortcut') {
		# PoSH has no shortcut support, so we must use com objects
		$WshShell = New-Object -comObject WScript.Shell
		$Shortcut = $WshShell.CreateShortcut("$LinkName")
		$Shortcut.TargetPath = "$Source"
		$Shortcut.Save()
	} else {
		# Starting 5.0, PoSH supports symlinks
		New-Item -Path "$LinkName" -ItemType $Type -Value "$Source"
	}
}
New-Alias mklink New-Link
