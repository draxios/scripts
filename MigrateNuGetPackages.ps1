param (
    [string]$teamCityFeedUrl,
    [string]$azureDevOpsFeedUrl,
    [string]$azureDevOpsPAT,
    [string[]]$packageIds,
    [string]$localPackageDirectory = "C:\NuGetPackages"
)

function Download-PackageFromTeamCity {
    param (
        [string]$packageId
    )

    nuget list $packageId -Source $teamCityFeedUrl | ForEach-Object {
        nuget install $_ -Source $teamCityFeedUrl -OutputDirectory $localPackageDirectory
    }
}

function Upload-PackageToAzureDevOps {
    param (
        [string]$packageId
    )

    $packageFiles = Get-ChildItem -Path $localPackageDirectory -Recurse -Filter "$packageId.*.nupkg"
    
    foreach ($file in $packageFiles) {
        nuget push $file.FullName -Source $azureDevOpsFeedUrl -ApiKey "AzureDevOps" -ConfigFile $null
    }
}

# Create local directory for packages
New-Item -ItemType Directory -Force -Path $localPackageDirectory

# Setting up credentials for Azure DevOps
$env:NUGET_CREDENTIALPROVIDER_SESSIONTOKENCACHE_ENABLED = "true"
$env:VSS_NUGET_EXTERNAL_FEED_ENDPOINTS = '{"endpointCredentials":[{"endpoint":"'+$azureDevOpsFeedUrl+'","username":"username","password":"'+$azureDevOpsPAT+'"}]}'

# Download and upload each package
foreach ($packageId in $packageIds) {
    Write-Host "Processing package: $packageId"
    
    Write-Host "Downloading $packageId from TeamCity..."
    Download-PackageFromTeamCity -packageId $packageId
    
    Write-Host "Uploading $packageId to Azure DevOps..."
    Upload-PackageToAzureDevOps -packageId $packageId
}

Write-Host "Migration completed."
