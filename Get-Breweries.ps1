function Get-Breweries {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory=$True, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Query,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$BaseURL = 'https://api.untappd.com/v4/search/brewery?',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$Limit = 50,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$Offset = 0,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId = '930397271D5B553D76573C4CF037CA894BBA7C37',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret = 'E58EEB69B1D2804F4D981BD24D75D284958DC703'

    )

    # initialize docIds array
    $breweryIds = @()

    $payload = @{

        'client_id' = $ClientId
        'client_secret' = $ClientSecret
        'q' = $Query;
        'limit' = $Limit;
        'offset' = $Offset;

    }

    #$headers  = @{'x-user' = $IFIUser; 'x-password' = $IFIPassword}

    $response = Invoke-RestMethod -Method Get -Uri $BaseURL -Body $payload

    # check success

    if ($response.meta.code -ne 200){
        Write-Host "Request failed with code: $($response.meta.code)"
    }

    # check number of results

    Write-Host "Found " $response.response.found " docs."

    while ($Offset -lt $response.response.found) {

        if ($response.meta.code -ne 200){
            Write-Host "Request failed with code: $($response.meta.code)"
        }

        Write-Host "Processing docs $Offset thru $($Offset+50)..."

  #      foreach ( $brewery in $response.response.brewery.items.brewery){
 #           $breweryIds += $brewery.brewery_id
#            $brewery | ConvertTo-Json |Out-File ".\breweries_json\$($brewery.brewery_id).json" -Force -Encoding utf8

        #}

        $response.response.brewery.items.brewery | ForEach-Object {
            
            if ($null -ne $_.brewery_id){
                $_ | ConvertTo-Json | Out-File "C:\source\beer2\breweries_json\$($_.brewery_id).json" -Force
                $breweryIds += $_.brewery_id
            }
            
        }
        
        $Offset += $response.response.brewery.count

        $payload = @{

            'client_id' = $ClientId
            'client_secret' = $ClientSecret
            'q' = $Query;
            'limit' = $Limit;
            'offset' = $Offset;
    
        }

        # avoid throttling
        Start-Sleep -Seconds 40

        $response = Invoke-RestMethod -Method Get -Uri $BaseURL -Body $payload
    }

    return $breweryIds
}