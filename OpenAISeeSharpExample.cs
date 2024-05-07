// Note: The Azure OpenAI client library for .NET is in preview.
// Install the .NET library via NuGet: dotnet add package Azure.AI.OpenAI --version 1.0.0-beta.5
using Azure;
using Azure.AI.OpenAI;

OpenAIClient client = new OpenAIClient(
  new Uri("https://stifel-aitest.openai.azure.com/"),
  new AzureKeyCredential(Environment.GetEnvironmentVariable("AZURE_OPENAI_API_KEY")));

  Response<ChatCompletions> responseWithoutStream = await client.GetChatCompletionsAsync(
  "gpt-4",
  new ChatCompletionsOptions()
  {
    Messages =
    {
      new ChatMessage(ChatRole.System, @"You are an AI assistant that helps people find information."),
      new ChatMessage(ChatRole.User, @"Can you write me a simple bool PowerShell function that determines if an input string is in proper kebab-case? The string must be proper kebab-case, with a max of 54 characters, and not containing any characters normally deemed undesirable for naming conventions via standards for Amazon and Microsoft."),      new ChatMessage(ChatRole.Assistant, @"Sure, I can help you craft a PowerShell function to check if a given string adheres to your specified kebab-case requirements. Kebab-case typically means all lowercase letters, digits, and hyphens used as separators. For Amazon and Microsoft naming conventions, we'll avoid spaces, underscores, uppercase letters, and special characters, focusing on ensuring the string is no longer than 54 characters.

Here's a simple PowerShell function that does just that:

```powershell
function Test-KebabCase {
    param (
        [Parameter(Mandatory=$true)]
        [string]$InputString
    )

    # Check if the string length is within the limit
    if ($InputString.Length -gt 54) {
        return $false
    }

    # Regular expression to match proper kebab-case based on specified conditions
    # This pattern ensures the string starts with a letter or a number, 
    # followed by lowercase letters, numbers, or hyphens.
    # It does not allow for consecutive hyphens or starting/ending with a hyphen.
    $kebabCasePattern = '^[a-z0-9]+(-[a-z0-9]+)*$'

    if ($InputString -match $kebabCasePattern) {
        return $true
    } else {
        return $false
    }
}
```

To use this function, you would simply call it with the string you want to check as an argument, like this:

```powershell
Test-KebabCase -InputString \"your-kebab-case-string\"
```

Replace `\"your-kebab-case-string\"` with the actual string you want to check. The function will return `$true` if the string is a valid kebab-case string under the defined rules, or `$false` otherwise."),
    },
    Temperature = (float)0.7,
    MaxTokens = 800,


    NucleusSamplingFactor = (float)0.95,
    FrequencyPenalty = 0,
    PresencePenalty = 0,
  });


ChatCompletions response = responseWithoutStream.Value;
