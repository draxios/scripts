# Azure DevOps PR Change Fetcher
# This script fetches detailed changes from a Pull Request in Azure DevOps
# Requires: PowerShell 5.1 or higher

param(
    [Parameter(Mandatory=$true)]
    [string]$PrUrl,
    
    [Parameter(Mandatory=$true)]
    [string]$Pat
)

function Get-PrDetails {
    param (
        [string]$PrUrl,
        [string]$Pat
    )
    
    # Parse PR URL to get organization, project, and PR ID
    if ($PrUrl -match "https://dev.azure.com/([^/]+)/([^/]+)/_git/([^/]+)/pullrequest/(\d+)") {
        $organization = $matches[1]
        $project = $matches[2]
        $repository = $matches[3]
        $prId = $matches[4]
    }
    else {
        throw "Invalid Azure DevOps PR URL format"
    }
    
    # Create auth header
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
    $headers = @{
        Authorization = "Basic $base64AuthInfo"
        'Content-Type' = 'application/json'
    }
    
    # API URLs
    $baseApiUrl = "https://dev.azure.com/$organization/$project/_apis/git/repositories/$repository"
    $prApiUrl = "$baseApiUrl/pullRequests/$prId`?api-version=6.0"
    
    # Get PR details
    $pr = Invoke-RestMethod -Uri $prApiUrl -Headers $headers -Method Get
    
    # Get changes
    $iterationsUrl = "$baseApiUrl/pullRequests/$prId/iterations?api-version=6.0"
    $iterations = Invoke-RestMethod -Uri $iterationsUrl -Headers $headers -Method Get
    $latestIteration = $iterations.value[-1].id
    
    $changesUrl = "$baseApiUrl/pullRequests/$prId/iterations/$latestIteration/changes?api-version=6.0"
    $changes = Invoke-RestMethod -Uri $changesUrl -Headers $headers -Method Get
    
    $changeDetails = @()
    
    foreach ($change in $changes.changes) {
        if ($change.item.gitObjectType -eq "blob") {
            $oldContent = ""
            $newContent = ""
            
            # Get old version content if it exists
            if ($change.originalContentUrl) {
                $oldContent = Invoke-RestMethod -Uri "https://dev.azure.com$($change.originalContentUrl)" -Headers $headers
            }
            
            # Get new version content
            if ($change.item.url) {
                $newContent = Invoke-RestMethod -Uri $change.item.url -Headers $headers
            }
            
            $changeDetails += [PSCustomObject]@{
                Path = $change.item.path
                ChangeType = $change.changeType
                OldContent = $oldContent
                NewContent = $newContent
            }
        }
    }
    
    # Create structured output
    $output = [PSCustomObject]@{
        PullRequest = [PSCustomObject]@{
            Id = $pr.pullRequestId
            Title = $pr.title
            Description = $pr.description
            SourceBranch = $pr.sourceRefName
            TargetBranch = $pr.targetRefName
        }
        Changes = $changeDetails
    }
    
    return $output
}

function Format-ChangeOutput {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Changes
    )
    
    $output = "# Pull Request Analysis Report`n"
    $output += "## PR Details`n"
    $output += "- ID: $($Changes.PullRequest.Id)`n"
    $output += "- Title: $($Changes.PullRequest.Title)`n"
    $output += "- Source Branch: $($Changes.PullRequest.SourceBranch)`n"
    $output += "- Target Branch: $($Changes.PullRequest.TargetBranch)`n`n"
    
    $output += "## File Changes`n"
    
    foreach ($change in $Changes.Changes) {
        $output += "### File: $($change.Path)`n"
        $output += "Change Type: $($change.ChangeType)`n`n"
        
        $output += "#### Previous Content:`n"
        $output += "````n$($change.OldContent)`n````n`n"
        
        $output += "#### New Content:`n"
        $output += "````n$($change.NewContent)`n````n`n"
    }
    
    return $output
}

try {
    # Main execution
    $changes = Get-PrDetails -PrUrl $PrUrl -Pat $Pat
    $formattedOutput = Format-ChangeOutput -Changes $changes
    
    # Output to both console and file
    $formattedOutput
    $formattedOutput | Out-File "pr_changes_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"
    
    # Return object for programmatic use
    return $changes
}
catch {
    Write-Error "Error processing PR changes: $_"
    throw
}
