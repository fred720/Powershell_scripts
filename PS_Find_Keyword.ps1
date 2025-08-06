<#PS E:\Python\Working> ollama run gpt-oss
>>> *Purpose*
... Create a Powershell cmdlet
...
... *Task*
... search for a **keyword** in files within a directory. user would provide directory and script will have to read each file
...  within the directory and find the **keyword** in the content of file. the script would then provide a list of files in t
... hat directory with that **keyword** contained within. use Get-Childitem and Get-Content to accomplish this task.
...
Thinking...
We need to provide a PowerShell cmdlet (likely a function or script) that takes directory and keyword as input, then
searches files in that directory for the keyword, using Get-ChildItem and Get-Content. Output a list of files
containing keyword. Provide explanation, code, maybe usage.

We can propose a function like Search-KeywordInDirectory -Path <string> -Keyword <string>. Use Get-ChildItem -File
-Recurse if needed. Use Where-Object to filter by Get-Content -Raw. Use Select-Object -Unique? Or just output file
names.

Edge cases: ignoring case. Use -CaseInsensitive or -eq. Use -match or -contains. Could use Select-String cmdlet but
they said to use Get-ChildItem and Get-Content.

Provide sample usage: .\SearchKeyword.ps1 -Path "C:\Logs" -Keyword "ERROR". Show output.

Explain that we use -Filter * or default. Use -File to get only files. Use -Recurse optionally.

Ok produce final answer.
...done thinking.

Below is a **stand‑alone PowerShell script** that implements the requested “cmdlet”.
It accepts two parameters:

| Parameter | Description |
|-----------|-------------|
| **-Path** | The folder that should be searched. |
| **-Keyword** | The text you’re looking for. |

The script:

* enumerates all files in the folder (optionally recursively – see comment)
* reads each file’s content with **`Get-Content -Raw`** (so the whole file is one string)
* tests whether the keyword is present (case‑insensitive by default)
* outputs the full path of every file that contains the keyword

```powershell
<#  --------------------------------------------------------------------
    Script:  Search-KeywordInDirectory.ps1
    Author:  <YourName>
    Purpose: Search a folder for a keyword in all files and return
             the list of files that contain the keyword.
    --------------------------------------------------------------------
#>

param(
    [Parameter(Mandatory = $true,
               Position = 0,
               HelpMessage = "Folder to search.")]
    [ValidateNotNullOrEmpty()]
    [string]$Path,

    [Parameter(Mandatory = $true,
               Position = 1,
               HelpMessage = "Keyword to find.")]
    [ValidateNotNullOrEmpty()]
    [string]$Keyword
)

# ------------------------------------------------------------
# Validate the supplied path
# ------------------------------------------------------------
if (-not (Test-Path -LiteralPath $Path)) {
    throw "The path '$Path' does not exist."
}

# ------------------------------------------------------------
# Find files that contain the keyword
# ------------------------------------------------------------
# If you want to search sub‑folders, add the -Recurse switch below
$filesWithKeyword = Get-ChildItem -LiteralPath $Path `
    -File -Force           # -Recurse   # uncomment to recurse

# Build an array of file paths that match
$matchingFiles = foreach ($file in $filesWithKeyword) {
    # Read the file once – -Raw returns a single string
    $content = Get-Content -LiteralPath $file.FullName -Raw

    # Case‑insensitive search with -match
    if ($content -match [Regex]::Escape($Keyword)) {
        $file.FullName
    }
}

# ------------------------------------------------------------
# Output
# ------------------------------------------------------------
if ($matchingFiles) {
    Write-Host "Keyword '$Keyword' found in the following files:`n"
    $matchingFiles | ForEach-Object { Write-Output $_ }
}
else {
    Write-Host "Keyword '$Keyword' was not found in any file under '$Path'."
}
```

<### How to use

1. **Save** the script as `Search-KeywordInDirectory.ps1` (or any name you like).
2. **Open** PowerShell (Admin if you need access to protected folders).
3. **Run** the script, e.g.:

```powershell
.\Search-KeywordInDirectory.ps1 -Path "C:\Logs" -Keyword "ERROR"
```

or, if you want to search sub‑directories as well, edit the script once by adding the `-Recurse` flag to the
`Get-ChildItem` line:

```powershell
Get-ChildItem -LiteralPath $Path -File -Force -Recurse
```

### What it does

| Step | PowerShell Cmdlet | Purpose |
|------|-------------------|---------|
| 1 | `Get-ChildItem -File` | Lists only files in the directory |
| 2 | `Get-Content -Raw` | Reads the entire content of a file into one string |
| 3 | `-match` | Checks if the keyword appears in that string |
| 4 | Output | Prints the full file path for every match |

> **Tip:**
> If you prefer a built‑in helper, `Select-String` can do the job in one line, but the above script shows the explicit
use of `Get-ChildItem` and `Get-Content` as requested.#>
