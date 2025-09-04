<#
.Synopsis
   Find Files
.DESCRIPTION
   Find files with a keyword in the file name
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Find-Files
{
    [CmdletBinding()]
    [Alias('ff')]

    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Enter the parent directory path:")]
            [string]$parentDir = (Read-Host -Prompt "Enter the parent directory path:"),
            [string]$searchPattern = (Read-Host -Prompt "Enter the file name pattern (e.g., *.txt, file?.log, *keyword*):")
    )

    Begin
    {
        # Validate that the provided path is a valid directory
        while (-not (Test-Path $parentDir -PathType Container)) {
        Write-Host "Invalid directory. Please try again."
        $parentDir = Read-Host -Prompt "Enter the parent directory path:"
}
    }
    Process
    {
        # Search for files recursively in the parent directory that match the pattern
        $files = Get-ChildItem -Path $parentDir -Filter $searchPattern -Recurse -File

        # Display results
        if ($files.Count -eq 0) {
        Write-Host "No files found matching the pattern."
} else {
    Write-Host "Files found:"
    $files | Format-Table -Property Name,Fullname,LastWriteTime -AutoSize
}
    }
    End
    {
    }
}
