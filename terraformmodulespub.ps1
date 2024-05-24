# Define variables
$AzureDevOpsPAT = "<your_azure_devops_pat>"
$TerraformEnterpriseToken = "<your_terraform_enterprise_token>"
$AzureDevOpsOrg = "your_azure_devops_org"
$AzureDevOpsProject = "your_project"
$RepoName = "your_repo_name"
$RepoUrl = "https://dev.azure.com/$AzureDevOpsOrg/$AzureDevOpsProject/_git/$RepoName"
$TerraformModuleRegistryUrl = "https://terraform.yourcompany.com"
$TerraformOrganizationName = "your_terraform_org"
$TerraformModuleName = "your_module_name"
$Version = "1.0.0"  # Adjust this versioning logic as needed
$OAuthTokenID = "<oauth_token_id>" # Replace with the actual OAuth token ID

# Error handling
trap {
    Write-Output "[ERROR] An error occurred: $_"
    exit 1
}

# Log start of the script
Write-Output "[INFO] Starting the process to link Azure DevOps repo to Terraform Enterprise."

# Publish the module to Terraform Enterprise
try {
    Write-Output "[INFO] Linking Azure DevOps repository to Terraform Enterprise"

    $headers = @{
        "Authorization" = "Bearer $TerraformEnterpriseToken"
        "Content-Type"  = "application/json"
    }

    $body = @{
        "data" = @{
            "type" = "registry-modules"
            "attributes" = @{
                "name" = $TerraformModuleName
                "organization" = $TerraformOrganizationName
                "version" = $Version
                "vcs-repo" = @{
                    "identifier" = "$AzureDevOpsOrg/$AzureDevOpsProject/$RepoName"
                    "oauth-token-id" = $OAuthTokenID
                    "display-identifier" = $RepoUrl
                }
            }
        }
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Method Post -Uri "$TerraformModuleRegistryUrl/api/v2/organizations/$TerraformOrganizationName/registry-modules" -Headers $headers -Body $body
    if ($response -eq $null) {
        throw "Failed to link the Azure DevOps repository to Terraform Enterprise"
    }
    Write-Output "[INFO] Azure DevOps repository linked to Terraform Enterprise successfully."
} catch {
    Write-Output "[ERROR] Error linking repository: $_"
    exit 1
}
