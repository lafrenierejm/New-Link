Function New-Link {
	Param (
		[Parameter(Mandatory=$TRUE,Position=0)]
		[string]$link,

		[Parameter(Mandatory=$TRUE,Position=1)]
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
