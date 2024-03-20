# Define the issue key
$issueKey = "BEG-1628"

# Define the base URL for your JIRA instance
$baseUrl = "https://yourjira.instance.com"

# Construct the URI for accessing the issue with specific fields
$uri = "$baseUrl/rest/api/2/issue/$issueKey?fields=customfield_11403,customfield_11404"

# Define the authorization header with your API token
# Replace 'your_token_here' with your actual API token
$headers = @{
    "Authorization" = "Basic your_token_here"
    "Content-Type" = "application/json"
}

# Perform the GET request
$response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers

# Extract the values of the custom fields from the response
$customField_11403_Value = $response.fields.customfield_11403
$customField_11404_Value = $response.fields.customfield_11404

# Output the values
Write-Output "Custom Field 11403 Value: $customField_11403_Value"
Write-Output "Custom Field 11404 Value: $customField_11404_Value"
