# Prompt the user for the parent directory
Write-Host "Enter the parent directory path:"
$parentDir = Read-Host

# Validate that the provided path is a valid directory
while (-not (Test-Path $parentDir -PathType Container)) {
    Write-Host "Invalid directory. Please try again."
    $parentDir = Read-Host
}

# Prompt the user for the file name pattern (e.g., *.txt, file?.log)
Write-Host "Enter the file name pattern (e.g., *.txt, file?.log, *keyword*):"
$searchPattern = Read-Host

# Search for files recursively in the parent directory that match the pattern
$files = Get-ChildItem -Path $parentDir -Filter $searchPattern -Recurse -File

# Display results
if ($files.Count -eq 0) {
    Write-Host "No files found matching the pattern."
} else {
    Write-Host "Files found:"
    $files | Format-Table -Property Name, Length, LastWriteTime -AutoSize
}

