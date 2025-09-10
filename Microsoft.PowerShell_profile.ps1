$Host.PrivateData.ErrorForegroundColor = 'Cyan'
$path = Get-Childitem "C:\Users\fcallier\OneDrive - Burns & McDonnell\Documents\WindowsPowerShell\Modules"
foreach ($item in $path){
	Import-Module -Name $item -Verbose}

#############################################################################################################
# Quickly find files by name

function qfind ($name)
{
    ls -Recurse -Filter "*${name}*" -ErrorAction SilentlyContinue | foreach {
            $place_path = $_.Directory
            echo "${place_path}\${_}"}
}

#########################################################################################################
# Quickly stop a Process

function pkill ($name)
{
    gps $name -ErrorAction SilentlyContinue | kill
}

#############################################################################################################
# Quickly puts you in admin mode

function admin
{
    if ($args.Count -gt 0)
    {
        $argsList = " & '" + $args + "'"
        Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $argsList
    }
    else
    {
        Start-Process "$psHome\powershell.exe" -Verb runAs
    }
}

#############################################################################################################
# Reload profile after changes

function reload-profile
{
    & $profile
}

##############################################################################
# Get a list of files in the current folder without listing the directories
function ll
{
    Get-ChildItem -Path $PWD -file | sort-object Name
}

############################################################################
clear-host
cd "C:\Users\fcallier\OneDrive - Burns & McDonnell"



