# Prompt for Azure DevOps Organization and PAT
$org = Read-Host -Prompt "Enter your Azure DevOps Organization name"
$pat = Read-Host -Prompt "Enter your PAT" -AsSecureString
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))

# Base API URL
$baseUrl = "https://dev.azure.com/$org/"

# Prepare header for authorization
$headers = @{
    Authorization=("Basic {0}" -f $base64AuthInfo)
}

# Get all projects
$projectUri = $baseUrl + "_apis/projects?api-version=6.0"
$projects = Invoke-RestMethod -Uri $projectUri -Method Get -Headers $headers
$repoCount = 0
$repoList = @()

foreach ($project in $projects.value) {
    # For each project, get repositories
    $repoUri = $baseUrl + $project.name + "/_apis/git/repositories?api-version=6.0"
    $repos = Invoke-RestMethod -Uri $repoUri -Method Get -Headers $headers
    
    foreach ($repo in $repos.value) {
        $repoInfo = "Project: " + $project.name + " - Repo: " + $repo.name + " | URL: " + $repo.remoteUrl
        $repoList += $repoInfo
        Write-Host $repoInfo
        $repoCount++
    }
}

# Output repositories to a file
$repoList | Out-File -FilePath "AzureDevOpsRepos.txt"

# Output the count of repositories found
Write-Host "Total Repositories Found: $repoCount"
