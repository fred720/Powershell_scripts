<#
https://openlibrary.org/search.json
https://openlibrary.org/search.json?q=the+lord+of+the+rings
https://openlibrary.org/search.json?title=the+lord+of+the+rings
https://openlibrary.org/search.json?author=tolkien&sort=new
https://openlibrary.org/search.json?q=the+lord+of+the+rings&page=2
https://openlibrary.org/search/authors.json?q=twain
https://openlibrary.org/search/authors.json?q=j%20k%20rowling
<#https://openlibrary.org/authors/OL23919A.json#>
#>


function Get-OpenLibraryAuthor
{
    [CmdletBinding()]
    [Alias('authorsearchOpenLibrary')]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Choose an any author")]
        [string]$author
    )

    Begin
    {
        Write-Host "Searching for $author......"
    }
    Process
    {
        Write-Host "Processing........"
        #$author = 'tolstoy'
        $uri = "https://openlibrary.org/search/authors.json"
        $uri += "?q=$($author)"
        #$uri
        #$result.docs
        Clear-Host
        $result = Invoke-Restmethod -Uri $uri -DisableKeepAlive
        $ol_key = $result.docs[0].key
        #$ol_key
        $uri_1 = "https://openlibrary.org/authors/$($ol_key).json"
        $result_1 = Invoke-RestMethod -Uri $uri_1 -DisableKeepAlive
        #$result_1.key
        #$result_1.name
        $result_1.links[0].url
        #$result_1.birth_date
        #$result_1.death_date
        $uri_2 = "https://openlibrary.org/authors/$($ol_key)/works.json?limit=100"
        $works = Invoke-RestMethod -uri $uri_2 -DisableKeepAlive
        $works.entries
    }

    End
    {
        if ($result_1.wikipedia)
            {
                start $result_1.wikipedia
                Write-Host "Process complete! "  
            }
          else
            {
                start $result_1.links[0].url
                Write-Host "Process complete! No WikiPedia link"  
            }

    }
}
<#https://openlibrary.org/authors/OL1394244A/works.json?offset=50#>



######################################################################################################################
######################################################################################################################
######################################################################################################################

function Get-OpenLibrarySubject
{
    [CmdletBinding()]
    [Alias('subjectOpenLibrary')]

    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Any Subject")]
        [string]$subject
    )

    Begin
    {
        Write-Host "Searching for $subject......"
    }
    Process
    {
        Write-Host "Processing......."
        #$subject = 'race'
        $uri = "https://openlibrary.org/subjects/$($subject).json?details=true"
        $result = Invoke-RestMethod -Uri $uri
        $result
    }
    End
    {
        Write-Host "Process complete!"
    }
}
######################################################################################################################
######################################################################################################################
######################################################################################################################

function Get-OpenLibrarySearch
{
    [CmdletBinding()]
    [Alias('searchOpenLibrary')]
    Param
    (
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Enter a name or book")]
        [string]$query
    )

    Begin
    {
        Write-Host "Searching for $query......"
    }
    Process
    {
        Write-Host "Processing......."
        #$query = "gogol"
        $uri = "https://openlibrary.org/search.json"
        $uri += "?q=$($query)"
        #$uri += "&page=1"
        $results = Invoke-RestMethod -uri $uri -DisableKeepAlive
        $results.docs
    }
    End
    {
        Write-Host "Process complete!"
    }
}
######################################################################################################################
######################################################################################################################
######################################################################################################################
<#https://openlibrary.org/search.json?title=the+lord+of+the+rings#>
function Get-OpenLibraryTitle
{
    [CmdletBinding()]
    [Alias('titleOpenLibrary')]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$title
    )

    Begin
    {
    Write-Host "Searching for $title......"
    }
    Process
    {Write-Host "Processing......."
        #$title = "beloved"
        $uri = "https://openlibrary.org/search.json"
        $uri += "?title=$title"
        $request = Invoke-RestMethod -uri $uri -DisableKeepAlive
        $request.docs

    }
    End
    {
    Write-Host "Process complete!"
    }
}
######################################################################################################################
######################################################################################################################
######################################################################################################################