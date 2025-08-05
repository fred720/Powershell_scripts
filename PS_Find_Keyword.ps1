# Prompt the user for the directory path
$directory = Read-Host "Enter directory path"

# Prompt the user for the keyword
$keyword = Read-Host "Enter keyword"

# Get all files in the directory
Get-ChildItem -Path $directory -File | ForEach-Object {
    # Read the entire content of the file as a single string
    $content = Get-Content -Path $_.FullName -Raw

    # Check if the keyword is present in the content
    if ($content.Contains($keyword)) {
        # Output the file name if the keyword is found
        $_.Name
    }
}