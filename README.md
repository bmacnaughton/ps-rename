# ps-rename

Rename files in powershell using regular expressions

Invoking rename.ps1 defines a global function that implements renaming files using regular expressions in both the source and the target. It is basically a wrapper to apply the Regex.Replace() function to filenames. It does not move files.

The name for the function I use is 'rename' but you can change it to anything you'd like - just edit the source.

It's not particularly well documented yet, but is useful enough to me to put it on github.

The interactive syntax is:

`rename source-regex target-regex`

When used interactively it displays the changes it will make and prompts for confirmation.

It can be used in pipelines like this:

`ls bruce*.c | rename 'bruce(.*)\.c' 'sam$1.c'`

WARNING: when used in pipelines it does not prompt for confirmation. If you'd like to see the results of a pipeline rename without actually making the changes use `-test`:

`ls bruce*.c | rename -test 'bruce(.*)\.c' 'sam$1.c'`

You should notice the use of single quotes to prevent variable substitution by PowerShell. See http://www.regular-expressions.info/powershell.html for details. Of course, you can use it without regular expressions too.

