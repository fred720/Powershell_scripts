#Requires -Version 5.1
<#
.SYNOPSIS
    Checks whether a DLL is registerable and whether it is already registered.

.DESCRIPTION
    This script:
      1. Verifies the DLL file exists
      2. Checks if it exports DllRegisterServer (i.e., is a COM-registerable DLL)
      3. Searches the Windows Registry for matching InprocServer32 entries
      4. Optionally registers the DLL using regsvr32 if it is not already registered

.PARAMETER DllPath
    Full path to the DLL file to inspect.

.PARAMETER AutoRegister
    If specified, the script will attempt to register the DLL if it is not already registered.
    Requires elevated (Administrator) privileges.

.PARAMETER SearchAllUsers
    If specified, also checks HKEY_LOCAL_MACHINE in addition to HKEY_CURRENT_USER.

.EXAMPLE
    .\Check-DllRegistration.ps1 -DllPath "C:\Windows\System32\mylib.dll"

.EXAMPLE
    .\Check-DllRegistration.ps1 -DllPath "C:\MyApp\mylib.dll" -AutoRegister

.NOTES
    Author  : Professor Eugene / Synapse_COR
    Requires: Windows PowerShell 5.1+ or PowerShell 7+
    Note    : Registration (-AutoRegister) requires an elevated (Run as Administrator) session.
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Full path to the DLL file.")]
    [string]$DllPath,

    [Parameter(Mandatory = $false)]
    [switch]$AutoRegister,

    [Parameter(Mandatory = $false)]
    [switch]$SearchAllUsers
)

# ─────────────────────────────────────────────
# Helper: Write styled output
# ─────────────────────────────────────────────
function Write-Status {
    param([string]$Label, [string]$Message, [string]$Color = "Cyan")
    Write-Host ("[{0}] " -f $Label) -ForegroundColor $Color -NoNewline
    Write-Host $Message
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host ("─" * 60) -ForegroundColor DarkGray
    Write-Host "  $Title" -ForegroundColor White
    Write-Host ("─" * 60) -ForegroundColor DarkGray
}

# ─────────────────────────────────────────────
# STEP 1: Verify DLL exists
# ─────────────────────────────────────────────
Write-SectionHeader "STEP 1 — File Existence Check"

# Normalize path: strip surrounding quotes and whitespace that often sneak
# in when copying a path from Windows Explorer or the address bar.
$DllPath = $DllPath.Trim().Trim('"').Trim("'").Trim()

Write-Host ("  Checking path : {0}" -f $DllPath) -ForegroundColor DarkGray

$resolvedPath = $null

# Try direct literal path first
if (Test-Path -LiteralPath $DllPath -PathType Leaf) {
    $resolvedPath = (Resolve-Path -LiteralPath $DllPath).Path
    Write-Status "FOUND" $resolvedPath "Green"
}
# Try joining with current directory if only a filename was given
elseif (-not [System.IO.Path]::IsPathRooted($DllPath)) {
    $joined = Join-Path (Get-Location).Path $DllPath
    Write-Host ("  Trying relative: {0}" -f $joined) -ForegroundColor DarkGray
    if (Test-Path -LiteralPath $joined -PathType Leaf) {
        $resolvedPath = (Resolve-Path -LiteralPath $joined).Path
        Write-Status "FOUND (relative)" $resolvedPath "Green"
    }
}

if (-not $resolvedPath) {
    Write-Status "NOT FOUND" "Could not locate file." "Red"
    Write-Host ""
    Write-Host "  Attempted path : $DllPath" -ForegroundColor DarkYellow
    Write-Host "  Working dir    : $((Get-Location).Path)" -ForegroundColor DarkYellow
    Write-Host ""
    Write-Host "  Tips:" -ForegroundColor Cyan
    Write-Host "    - Wrap the path in single quotes: -DllPath 'C:\My Path\file.dll'"
    Write-Host "    - Or use Tab-completion from the same directory"
    Write-Host "    - Run: Test-Path 'C:\your\path\file.dll'  to verify PS can see it"
    exit 1
}

$fileName = [System.IO.Path]::GetFileName($resolvedPath)

# ─────────────────────────────────────────────
# STEP 2: Check for DllRegisterServer export
# ─────────────────────────────────────────────
Write-SectionHeader "STEP 2 — Export Check (DllRegisterServer)"

$isRegisterable = $false

try {
    # Use dumpbin if available (Visual Studio tools), otherwise fall back to a raw byte search
    $dumpbin = Get-Command "dumpbin.exe" -ErrorAction SilentlyContinue

    if ($dumpbin) {
        $exports = & dumpbin.exe /EXPORTS "$resolvedPath" 2>&1
        if ($exports -match "DllRegisterServer") {
            $isRegisterable = $true
        }
    } else {
        # Fallback: scan the DLL binary for the export name string
        $bytes    = [System.IO.File]::ReadAllBytes($resolvedPath)
        $encoding = [System.Text.Encoding]::ASCII
        $content  = $encoding.GetString($bytes)
        if ($content -match "DllRegisterServer") {
            $isRegisterable = $true
        }
    }
} catch {
    Write-Status "WARNING" "Could not inspect DLL exports: $_" "Yellow"
}

if ($isRegisterable) {
    Write-Status "REGISTERABLE" "DllRegisterServer export found — this DLL supports COM registration." "Green"
} else {
    Write-Status "NOT REGISTERABLE" "DllRegisterServer export NOT found — this DLL may not be a COM server." "Yellow"
    Write-Host ""
    Write-Host "  The DLL exists but does not appear to expose DllRegisterServer." -ForegroundColor DarkYellow
    Write-Host "  It may be a plain DLL (not a COM component) and may not require registration." -ForegroundColor DarkYellow
}

# ─────────────────────────────────────────────
# STEP 3: Search Registry for existing registration
# ─────────────────────────────────────────────
Write-SectionHeader "STEP 3 — Registry Registration Check"

$registryRoots = @("HKLM:\SOFTWARE\Classes\CLSID", "HKCU:\SOFTWARE\Classes\CLSID")

if ([System.Environment]::Is64BitOperatingSystem) {
    $registryRoots += "HKLM:\SOFTWARE\WOW6432Node\Classes\CLSID"
}

$matchedKeys   = @()
$normalizedDll = $resolvedPath.ToLower()

foreach ($root in $registryRoots) {
    if (-not (Test-Path $root)) { continue }

    try {
        $clsids = Get-ChildItem -LiteralPath $root -ErrorAction SilentlyContinue
        foreach ($clsid in $clsids) {
            $inproc = Join-Path $clsid.PSPath "InprocServer32"
            if (Test-Path $inproc) {
                $val = (Get-ItemProperty -LiteralPath $inproc -ErrorAction SilentlyContinue).'(default)'
                if ($val -and $val.ToLower() -eq $normalizedDll) {
                    $matchedKeys += [PSCustomObject]@{
                        CLSID    = $clsid.PSChildName
                        Hive     = $root
                        InprocPath = $val
                    }
                }
            }
        }
    } catch {
        Write-Status "SKIP" "Could not read $root — $_" "DarkGray"
    }
}

$isRegistered = $matchedKeys.Count -gt 0

if ($isRegistered) {
    Write-Status "REGISTERED" "Found $($matchedKeys.Count) matching registry entry/entries:" "Green"
    foreach ($entry in $matchedKeys) {
        Write-Host ""
        Write-Host ("    CLSID  : {0}" -f $entry.CLSID)       -ForegroundColor Gray
        Write-Host ("    Hive   : {0}" -f $entry.Hive)         -ForegroundColor Gray
        Write-Host ("    Path   : {0}" -f $entry.InprocPath)   -ForegroundColor Gray
    }
} else {
    Write-Status "NOT REGISTERED" "No matching InprocServer32 registry entry found for this DLL." "Yellow"
}

# ─────────────────────────────────────────────
# STEP 4: Summary & Optional Auto-Register
# ─────────────────────────────────────────────
Write-SectionHeader "SUMMARY"

Write-Host ("  File          : {0}" -f $fileName)
Write-Host ("  Path          : {0}" -f $resolvedPath)
Write-Host ("  Registerable  : {0}" -f $(if ($isRegisterable)  { "Yes" } else { "No (no DllRegisterServer export)" }))
Write-Host ("  Registered    : {0}" -f $(if ($isRegistered)    { "Yes" } else { "No" }))
Write-Host ""

if ($isRegisterable -and -not $isRegistered) {
    Write-Status "ACTION NEEDED" "This DLL is registerable but is NOT currently registered." "Yellow"

    if ($AutoRegister) {
        Write-SectionHeader "STEP 4 — Auto-Registration"

        # Check for elevation
        $principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        $isAdmin   = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        if (-not $isAdmin) {
            Write-Status "ERROR" "AutoRegister requires an elevated (Run as Administrator) session." "Red"
            Write-Host ""
            Write-Host "  Re-run this script from an elevated PowerShell prompt:" -ForegroundColor DarkYellow
            Write-Host "  Start-Process powershell -Verb RunAs" -ForegroundColor Cyan
            exit 2
        }

        Write-Status "REGISTERING" "Running: regsvr32 /s `"$resolvedPath`"" "Cyan"
        $result = Start-Process -FilePath "regsvr32.exe" `
                                -ArgumentList "/s `"$resolvedPath`"" `
                                -Wait -PassThru -NoNewWindow

        if ($result.ExitCode -eq 0) {
            Write-Status "SUCCESS" "DLL registered successfully." "Green"
        } else {
            Write-Status "FAILED" "regsvr32 exited with code $($result.ExitCode). Check the DLL path and permissions." "Red"
        }
    } else {
        Write-Host "  To register it manually, run (as Administrator):" -ForegroundColor DarkYellow
        Write-Host ("  regsvr32 `"{0}`"" -f $resolvedPath) -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  Or re-run this script with -AutoRegister to do it automatically." -ForegroundColor DarkGray
    }

} elseif ($isRegistered) {
    Write-Status "OK" "No action needed — DLL is already registered." "Green"
} elseif (-not $isRegisterable) {
    Write-Status "INFO" "DLL does not appear to require COM registration." "Cyan"
}

Write-Host ""
