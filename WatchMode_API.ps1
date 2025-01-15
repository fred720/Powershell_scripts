############################################################################################################################################
############################################################################################################################################

function Get-Movie{
    [CmdletBinding()]
    [Alias('moviesearch')]
    Param
    (
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [string]$value
    )

    Begin
    {
    Write-Output "Searching for $Value......"
    }
    Process
    {
        $key = Import-Clixml -Path ".\watchmode.xml"
        #$value = "Phantom Thread"
        $uri = "https://api.watchmode.com/v1/autocomplete-search/"
        $api_key = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($key))
        $uri += "?apiKey=$($api_key)"
        $uri += "&search_value=$($value)"
        $uri += "&search_type=1"
        $results = Invoke-RestMethod -Uri $uri -DisableKeepAlive
        $results.results
        #start $results.results.image_url
}
    End
    {
        Write-Output 'Process Complete'
    }
}

############################################################################################################################################
############################################################################################################################################

function Get-StreamingSources
{
    [CmdletBinding()]
    [Alias('streaming')]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$title_id
)

    Begin
    {
    Write-Output "Gathering Streaming Sources......"
    }
    Process
    {
    $key = Import-Clixml -Path ".\watchmode.xml"
    #$title_id = "1300275"
    $uri = "https://api.watchmode.com/v1/title/$($title_id)/sources/"
    $api_key = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($key))
    $uri += "?apiKey=$($api_key)"
    $request = invoke-restmethod -uri $uri -DisableKeepAlive
    $request
    }
    End
    {
    write-output "Process Complete!"
    }
}

############################################################################################################################################
############################################################################################################################################


function Get-MovieDetails
{
    [CmdletBinding()]
    [Alias('moviedetails')]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$title_id
    )

    Begin
    {
    Write-Output "Gathering Movie Details......"
    }
    Process
    {
    $key = Import-Clixml -Path ".\watchmode.xml"
    #$title_id = "1300275"
    $uri = "https://api.watchmode.com/v1/title/$($title_id)/details/"
    $api_key = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($key))
    $uri += "?apiKey=$($api_key)"
    $request = invoke-restmethod -uri $uri -DisableKeepAlive
    $request
    
    }
    End
    {
    write-output "Process Complete!"
    }
}

############################################################################################################################################
############################################################################################################################################


function Get-Moviecast
{
    [CmdletBinding()]
    [Alias('moviecast')]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [string]$title_id
    )

    Begin
    {
    Write-Output "Gathering Movie Cast and crew......"
    }
    Process
    {
    $key = Import-Clixml -Path ".\watchmode.xml"
    #$title_id = "1300275"
    $uri = "https://api.watchmode.com/v1/title/$($title_id)/cast-crew/"
    $api_key = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($key))
    $uri += "?apiKey=$($api_key)"
    $request = invoke-restmethod -uri $uri -DisableKeepAlive
    $request
    }
    End
    {
    write-output "Process Complete!"
    }
}

############################################################################################################################################
############################################################################################################################################
<#'https://api.watchmode.com/v1/releases/?apiKey=YOUR_API_KEY'#>

function Get-MovieReleases
{
    [CmdletBinding()]
    [Alias('newrelease')]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false,ValueFromPipeline=$true)]
        [string]$start_date
    )

    Begin
    {
    Write-Output "Gathering new releases......"
    }
    Process
    {
    $key = Import-Clixml -Path ".\watchmode.xml"
    $start_date = "20240712"
    $uri = "https://api.watchmode.com/v1/releases/"
    $api_key = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($key))
    $uri += "?apiKey=$($api_key)"
    $request = invoke-restmethod -uri $uri -DisableKeepAlive
    #$request.releases
    foreach($r in $request.releases){
    $prop = [ordered]@{
        Title = $r.title
        Release_Date = $r.source_release_date
        Service_Name = $r.source_name
        Type = $r.type
        Season = $r.season_number
        Title_ID = $r.id
        Source_ID = $r.source_id}
    $obj = New-Object -TypeName psobject -Property $prop
    $obj
    }
    }
    End
    {
    write-output "Process Complete!"
    }
}
############################################################################################################################################
############################################################################################################################################