$ErrorActionPreference = "Stop"
 
$VsixLocation = $dirFiles + "\cxvscode-2021.3.1.vsix"
 
$VSInstallDir = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\resources\app\ServiceHub\Services\Microsoft.VisualStudio.Setup.Service"
 
if (-Not $VSInstallDir) {
  Write-Error "Visual Studio InstallDir registry key missing"
  Exit 1
}
  
Write-Host "VSInstallDir is $($VSInstallDir)"
Write-Host "VsixLocation is $($VsixLocation)"
Write-Host "Installing $($PackageName)..."
Start-Process -Filepath "$($VSInstallDir)\VSIXInstaller" -ArgumentList "/q /a $($VsixLocation)" -Wait
 
Write-Host "Cleanup..."
rm $VsixLocation
 
Write-Host "Installation of $($PackageName) complete!"
