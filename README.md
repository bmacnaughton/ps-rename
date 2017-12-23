# ps-rename

Rename files in powershell using regular expressions

Invoking rename.ps1 defines a global function named "renamer" that allows renaming files using regular expressions. It is basically a wrapper to apply the Regex.Replace() function to filenames. It does not move files.

The name for the function I use is 'renamer' but you can change it to anything you'd like - just edit the source.

The interactive syntax is:

`rename source-regex target-regex`

When used interactively it displays the changes it will make and prompts for confirmation (default).

It can be used in pipelines like this:

`ls bruce*.c | rename 'bruce(.*)\.c' 'sam$1.c'`

WARNING: when used in pipelines it does not prompt for confirmation. If you'd like to see the results of a pipeline rename without actually making the changes use `-test`:

`ls bruce*.c | rename -test 'bruce(.*)\.c' 'sam$1.c'`

You should notice the use of single quotes to prevent variable substitution by PowerShell. You can also use a backtick (`) to quote a single character. See http://www.regular-expressions.info/powershell.html for details. Of course, you can use it without regular expressions too.

