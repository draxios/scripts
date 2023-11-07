# Path to the web.config file
$webConfigPath = "path\to\your\web.config" # Update this with the actual path

# Check if the file exists
if (Test-Path $webConfigPath) {
    # Load the web.config as an XML document
    $webConfig = [xml](Get-Content $webConfigPath)

    # Find the <authentication> element under <system.webServer><security>
    $securityNode = $webConfig.configuration.'system.webServer'.security
    $authNode = $securityNode.authentication

    # If the <authentication> node exists, remove it
    if ($authNode -ne $null) {
        $securityNode.RemoveChild($authNode)

        # Save the updated web.config
        $webConfig.Save($webConfigPath)
        Write-Output "The <authentication> block has been removed from the web.config file."
    }
    else {
        Write-Output "No <authentication> block found in the <security> section of the <system.webServer> in the web.config file."
    }
}
else {
    Write-Error "The web.config file was not found at the specified path: $webConfigPath"
}
