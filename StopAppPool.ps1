Invoke-Command -ComputerName "RemoteServerName" -ScriptBlock { Import-Module WebAdministration; Stop-WebAppPool -Name "AppPoolName" } -Credential (Get-Credential)
Invoke-Command -ComputerName "RemoteServerName" -ScriptBlock { Import-Module WebAdministration; Start-WebAppPool -Name "AppPoolName" } -Credential (Get-Credential)
Invoke-Command -ComputerName "RemoteServerName" -ScriptBlock { Import-Module WebAdministration; Restart-WebItem 'IIS:\Sites\SiteName' } -Credential (Get-Credential)
