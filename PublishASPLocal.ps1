$websiteName = "YourWebsiteName"
$publishProfilePath = "C:\Your\Path\To\PublishProfile.pubxml"
$websitePublishFolder = "C:\Your\Path\To\WebsitePublishFolder"

# Load the Web Deploy assembly
Add-Type -AssemblyName "Microsoft.Web.Deployment"

# Set up the deployment options
$deploymentOptions = New-Object Microsoft.Web.Deployment.DeploymentBaseOptions
$deploymentOptions.UserName = ""
$deploymentOptions.Password = ""
$deploymentOptions.AllowUntrusted = $true

# Publish the website using the specified profile
Write-Host "Publishing $websiteName..."
$publishResult = [Microsoft.Web.Deployment.DeploymentManager]::InvokeDeploymenOperation(
    [Microsoft.Web.Deployment.DeploymentWellKnownProvider]::Auto,
    "sync",
    $publishProfilePath,
    $websitePublishFolder,
    $deploymentOptions
)

# Output the result of the deployment
Write-Host "Publish result: " + $publishResult.Status
