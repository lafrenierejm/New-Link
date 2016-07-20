Function New-Link {
	Param (
		[Parameter(Mandatory=$TRUE, Position=0)]
		[ValidateSet('SymbolicLink', 'Junction', 'HardLink', 'Shortcut')]
		[string]$Type,

		[Parameter(Mandatory=$TRUE, Position=1)]
		[string]$link,

		[Parameter(Mandatory=$TRUE, Position=2)]
		[ValidateScript({Test-Path $_})]
		[string]$target
	)

	# Run `mklink /d` if $target is a directory
	if (Test-Path -pathtype container $target) {
		$command = "mklink /d"
	} else {
		$command = "mklink"
	}

	cmd /c "$command $link $target"
}
New-Alias mklink New-Link
