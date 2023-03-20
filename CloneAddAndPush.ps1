# Set the variables for the Git repo URL, local directory, and file name
$repoUrl = "https://github.com/username/repo.git"
$localDir = "C:\path\to\local\directory"
$fileName = "example.txt"

# Clone the Git repo to the local directory
git clone $repoUrl $localDir

# Change the current working directory to the root of the Git repo
cd $localDir

# Add a new text file to the root of the Git repo
New-Item -ItemType File -Name $fileName

# Stage the changes
git add .

# Commit the changes with a message
git commit -m "Added $fileName"

# Get the default branch name
$branch = git symbolic-ref refs/remotes/origin/HEAD | Select-String -Pattern "^refs/remotes/origin/(.*)" | % { $_.Matches[0].Groups[1].Value }

# Push the changes to the default branch
git push origin $branch
