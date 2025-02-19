# Define the variables
$organization = "bogware"  # Replace with your Azure DevOps organization name
$project = "tests"  # Replace with your Azure DevOps project name
$pat = "testmexxxxxxxxxx"  # Replace with your Personal Access Token (PAT)
$localPath = "c:\code"  # Replace with your desired local storage path

# Create the local directory if it doesn't exist
if (-not (Test-Path -Path $localPath)) {
    New-Item -ItemType Directory -Path $localPath
}

if (-not (Test-Path -Path "$localPath\$project")) {
    New-Item -ItemType Directory -Path "$localPath\$project"
}

# Base64 encode the PAT for authorization
$authHeader = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat"))

# Get the list of repositories in the project
$reposUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories?api-version=6.0"
write-host $reposUrl
$repos = Invoke-RestMethod -Uri $reposUrl -Headers @{Authorization = $authHeader} -Method Get
Write-host $repos.ToString()

# Clone each repository
foreach ($repo in $repos.value) {
    $repoName = $repo.name
    $repoCloneUrl = $repo.remoteUrl

    Write-Host "Cloning repository: $repoName"
    git clone $repoCloneUrl "$localPath\$project\$repoName"
    Start-Sleep 5
}

Write-Host "All repositories have been cloned."
