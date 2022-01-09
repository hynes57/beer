function Get-BreweryInfo {
    [CmdletBinding()]
    param (

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$BaseURL = 'https://api.untappd.com/v4/brewery/info/',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$NumberBreweries = 277777,

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


    $payload = @{

        'client_id' = $ClientId
        'client_secret' = $ClientSecret

    }

    while ($Offset -le $NumberBreweries) {

        $response = Invoke-RestMethod -Method Get -Uri $($BaseURL+$Offset) -Body $payload -ErrorAction Continue

        if ($response.meta.code -eq 200){
            Write-Host "$Offset is a valid id. Processing..."
            $response.response.brewery | ConvertTo-Json | Out-File "C:\source\beer2\brewery_info_json\$($response.response.brewery.brewery_id).json" -Force
        }

        else {
            Write-Host "Request failed with code: $($response.meta.code). $Offset is not a valid id"
        }
        
        $Offset ++

        $response = $null
        # avoid throttling
        Start-Sleep -Seconds 40

        #$response = Invoke-RestMethod -Method Get -Uri $BaseURL -Body $payload
    }
}