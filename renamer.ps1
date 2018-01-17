<#
.Synopsis
	Uses regular expressions to find and rename files.

.Description
	Usually this is bound as a command so that it can be used in place of the more basic rename-items command. It
	accepts a source regular expression pattern and a destination string, which can include backreferences ($1).

	renamer can be used in pipeline but does not confirm renames. You might want to test the results by specifying the
	`-test` parameter.

.Link
	https://docs.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference#grouping_constructs

.Parameter confirm
	-confirm:$true (default) in interactive mode only, prompts for confirmation after displaying the renames to be executed.
	-confirm:$false performs the rename without prompting

.Parameter test
	-test:$true outputs the renames to be performed but does not execute them.
	-test:$false (default) performs the renames

.Example
	renamer bruce b

	bruce.txt => b.txt
	bruce-macnaughton.txt => b-macnaughton.txt
	bruce-alan-macnaughton.text => b-alan-macnaughton.text	

.Example
	renamer '(-alan)*(-macnaughton)' `$2

	bruce.txt => (not affected)
	bruce-macnaughton.txt => bruce-macnaughton.txt (renamed to itself)
	bruce-alan-macnaughton.text => bruce-macnaughton.text

	Note that single quotes or backticks must be used to prevent Powershell from interpreting special characters.

.Example
	ls | renamer `-alan ''
	
	renames the file bruce-alan-macnaughton.text to bruce-macnaughton.text

.Example
	ls | renamer -test `-alan ''
	
	outputs bruce-macnaughton.text but does not rename bruce-alan-macnaughton.text

#>

function global:renamer {
    [CmdletBinding(DefaultParameterSetName = "interactive")]
    Param (
	[parameter(position = 1, mandatory = $true,
	    helpmessage="REGULAR EXPRESSION - quote special characters using ` (backtick) - used to select files to be renamed")]
	    [string] $pattern,
	[parameter(position = 2, mandatory = $true, helpmessage="replacement text for part matched by regular expression")]
	    [AllowEmptyString()]
	    [string] $replacement,
	[parameter(ParameterSetName = "interactive", mandatory = $false,
	    helpmessage="when used interactively ask for confirmation of changes (default -confirm:`$true)")]
	    [switch] $confirm=$true,
	[parameter(ParameterSetName = "pipeline", mandatory = $false, valuefrompipeline=$true)]
	    [system.io.filesysteminfo] $fileobj,
	[parameter(ParameterSetName = "pipeline", mandatory = $false,
	    helpmessage="when used in a pipeline don't actually rename files, just write new names to output")]
	    [switch] $test=$false
	)

    begin {
		# utility functions
		function makenewname($file){return ([regex] $pattern).replace($file.name, $replacement)}
		function extractpath($file){return (split-path $file.fullname -parent) + [io.path]::directoryseparatorchar}

		# note where we are in the pipeline
		$pos = $pscmdlet.myinvocation.pipelineposition
		$len = $pscmdlet.myinvocation.pipelinelength
		$end = $pos -eq $len
		
		# keep track of changes for interactive mode. especially useful if failure partway through renames
		$changedCount = 0
	}

    process {
		if ($fileobj) {
			<# run the pipeline - confirming the renames is NOT the default #>
			if ($fileobj.name -match $pattern) {
				$type = $fileobj.gettype().fullname
				$newname = makenewname $fileobj
				$filepath = extractpath $fileobj
				#
				# if $test is specified then don't do the rename, just pass on the filename it would have been renamed to.
				#
				if (-not $test) {
					rename-item -literalpath $fileobj.fullname $newname
				}
				#
				# newfileobj may not exist if $test was set but that's what goes into the pipe. make sure
				# it's the same type as the type that came in
				#
				$newfileobj = new-object $type ($filepath+$newname)
				write-output $newfileobj
			}
		} else {
			<# interactive mode - we work in the current directory and confirm is the default #>
			$matches = @(ls . | where {$_.Name -match $pattern})
			if ($matches.length -gt 0) {

				## get longest string  
				$n = @($matches | sort-object @{Expression={$_.Name.Length}; Ascending=$false})[0].Name.Length + 4  

				$matches | %{ $_.Name.PadRight($n, " ") + "->  " + (makenewname $_) }  

				$answer = "y"
				if ($confirm) {
					write-host -foregroundcolor red "confirm changes " -nonewline
					write-host -foregroundcolor yellow "(y or n) " -nonewline
					$answer = read-host
				}

				if ($answer -eq "y") {
					$error.clear()
					$matches | %{ rename-item -literalpath $_.fullname (makenewname $_); $changedCount += 1}

					if (!$error) {
						#$changedCount = $matches.length
					} else {  
						write-host -foregroundcolor yellow "rename failed on $($matches[$changedCount])"
					}  
				} else {  
					write-host "renames cancelled"  
				}
			}
		}
    }
    end {
		if ($pscmdlet.ParameterSetName -eq "interactive") {write-host "renamed $changedCount files"}
    }
}
