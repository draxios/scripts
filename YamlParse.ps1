# Set the path to the YAML file
$yamlPath = "C:\path\to\your\file.yaml"

# Read the YAML file into a PowerShell object
$yamlObject = Get-Content $yamlPath | ConvertFrom-Yaml

# Get the values of Val1 and Val2
$val1 = $yamlObject.variables.Val1
$val2 = $yamlObject.variables.Val2

# Print the values of Val1 and Val2
Write-Host "Val1: $val1"
Write-Host "Val2: $val2"
