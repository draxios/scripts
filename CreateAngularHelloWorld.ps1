function CreateAngularUI {
    param(
        [Parameter(Mandatory = $true)]
        [String]$Name,
        [Parameter(Mandatory = $false)]
        [ValidateSet("css", "scss", "sass", "less")]
        [String]$Style = "css"
    )

    # Create new Angular project
    mkdir $Name
    ng new $Name --style=$Style --routing --skip-git --skip-install --skip-tests

    # Add proxy configuration for local development
    $proxyConfig = @"
    {
        "/api": {
            "target": "http://localhost:5000",
            "secure": false
        }
    }
    "@

    $proxyConfig | Out-File -FilePath "./$Name/proxy.conf.json"

    # Update angular.json to use the proxy configuration during serve
    $angularJson = Get-Content -Path "./$Name/angular.json" | ConvertFrom-Json
    $serveOptions = $angularJson.projects.$Name.architect.serve.options
    $serveOptions | Add-Member -Name "proxyConfig" -Value "proxy.conf.json" -MemberType NoteProperty
    $angularJson | ConvertTo-Json -Depth 100 | Set-Content -Path "./$Name/angular.json"

    # Update outputPath for build architect
    $angularJson.projects.$Name.architect.build.options.outputPath = "dist"
    $angularJson | ConvertTo-Json -Depth 100 | Set-Content -Path "./$Name/angular.json"

    # Modify the default app component as a placeholder page
    $appComponentHtmlPath = "./$Name/src/app/app.component.html"
    $placeholderContent = @"
    <div style="text-align:center">
        <h1>Welcome to {{ title }}!</h1>
        <p>This is a placeholder page for your Angular project.</p>
    </div>
    "@
    $placeholderContent | Set-Content -Path $appComponentHtmlPath

    $appComponentTsPath = "./$Name/src/app/app.component.ts"
    (Get-Content -Path $appComponentTsPath) -replace 'title = .+;', "title = 'My Angular Project';" | Set-Content -Path $appComponentTsPath
}

# Create new Angular project
$projectName = "MyBEGTest"
CreateAngularUI -Name $projectName
