# Setup Azure DevOps Access
$pat = "<your-pat>"
$organization = "<your-organization>"
$project = "<your-project>"
$encodedPat = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$headers = @{
    Authorization = "Basic $encodedPat"
}

# Define the output folder for all merged files
$outputFolder = "C:\merged-repos"

# Function to clone and merge text files from a repository
function CloneAndMergeRepoFiles {
    param (
        [string]$repoName,
        [string]$repoUrl
    )
    # Modify the repository URL to include the PAT for authentication
    $authRepoUrl = $repoUrl -replace 'https://', ('https://:' + $pat + '@')

    $localRepoPath = Join-Path -Path $outputFolder -ChildPath $repoName
    # Clone using the modified URL with the PAT
    git clone $authRepoUrl $localRepoPath

    MergeTextFilesInFolder -sourceFolderPath $localRepoPath -outputFileName "merged-$repoName.txt"
}

# Function to merge text files within a folder
function MergeTextFilesInFolder {
    param (
        [string]$sourceFolderPath,
        [string]$outputFileName = "merged.txt"
    )

    $outputFilePath = Join-Path -Path $sourceFolderPath -ChildPath $outputFileName
    $textFileExtensions = @('.txt', '.md', '.xml', '.json', '.cs', '.js', '.html', '.css', '.ps1', '.sh', '.yaml', '.yml','.csproj','.vbproj','.cfg','.config','.gitignore','.sln')

    $textFiles = Get-ChildItem -Path $sourceFolderPath -Recurse | Where-Object {
        $_ -is [System.IO.FileInfo] -and $textFileExtensions -contains $_.Extension
    }

    if (Test-Path $outputFilePath) {
        Clear-Content $outputFilePath
    } else {
        New-Item $outputFilePath -ItemType File
    }

    foreach ($file in $textFiles) {
        Add-Content -Path $outputFilePath -Value "`n---$($file.FullName)---`n"
        Get-Content $file.FullName | Add-Content $outputFilePath
    }

    Write-Host "All text files in $repoName have been merged into $outputFilePath"
}

# Get all repositories in the project
$repoApiUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories?api-version=6.0"
$repos = (Invoke-RestMethod -Uri $repoApiUrl -Method Get -Headers $headers).value

# Loop through each repository, clone it, and merge its text files
foreach ($repo in $repos) {
    CloneAndMergeRepoFiles -repoName $repo.name -repoUrl $repo.remoteUrl
}

Write-Host "All repositories have been processed and their text files merged."
