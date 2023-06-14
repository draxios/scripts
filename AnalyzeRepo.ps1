function Analyze-Repo {
    param(
        [Parameter(Mandatory=$true)]
        [string]$repoUrl,
        [Parameter(Mandatory=$true)]
        [string]$localPath
    )

    # Clone the repo
    git clone $repoUrl $localPath

    # Initialize a hashtable to store counts of file extensions
    $fileCounts = @{}

    # Initialize a hashtable to store .NET versions (for .csproj files)
    $dotNetVersions = @{}

    # Get all files in the repo
    $files = Get-ChildItem -Path $localPath -Recurse -File

    # Iterate over the files
    foreach ($file in $files) {
        # Get the file extension
        $ext = $file.Extension

        # If we haven't seen this extension yet, initialize its count to 0
        if (-not $fileCounts.ContainsKey($ext)) {
            $fileCounts[$ext] = 0
        }

        # Increment the count for this extension
        $fileCounts[$ext]++

        # If the file is a .csproj file
        if ($ext -eq ".csproj") {
            # Load the XML
            $xml = [xml](Get-Content $file.FullName)

            # Get the TargetFramework value
            $targetFramework = $xml.Project.PropertyGroup.TargetFramework

            # If we haven't seen this version yet, initialize its count to 0
            if (-not $dotNetVersions.ContainsKey($targetFramework)) {
                $dotNetVersions[$targetFramework] = 0
            }

            # Increment the count for this .NET version
            $dotNetVersions[$targetFramework]++
        }
    }

    # Return the file counts and .NET versions
    return @{
        FileCounts = $fileCounts
        DotNetVersions = $dotNetVersions
    }
}

# Usage
# Analyze-Repo -repoUrl "https://github.com/yourusername/yourrepo.git" -localPath "C:\path\to\clone\to"
