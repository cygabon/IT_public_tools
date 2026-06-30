#requires -RunAsAdministrator

param(
  [Parameter(Mandatory=$true)]
  [string]$LCMFrameworkBundle,

  [string]$WebRoot = "C:\inetpub\wwwroot",
  [string[]]$AllowedRemoteAddress = @("10.0.0.0/8")
)

$ReleasePath = Join-Path $WebRoot "release"
$BuildsPath  = Join-Path $ReleasePath "builds"

Install-WindowsFeature Web-Server -IncludeManagementTools

Import-Module WebAdministration -ErrorAction Stop
Import-Module IISAdministration -ErrorAction SilentlyContinue

New-Item $ReleasePath -ItemType Directory -Force | Out-Null
New-Item $BuildsPath -ItemType Directory -Force | Out-Null

New-NetFirewallRule `
  -DisplayName 'Nutanix Dark Site Web Server' `
  -Profile Any `
  -Direction Inbound `
  -Action Allow `
  -Protocol TCP `
  -LocalPort 80 `
  -RemoteAddress $AllowedRemoteAddress `
  -ErrorAction SilentlyContinue

Set-WebConfigurationProperty `
  -PSPath "IIS:\Sites\Default Web Site" `
  -Filter "system.webServer/directoryBrowse" `
  -Name "enabled" `
  -Value "True"

Copy-Item $LCMFrameworkBundle "C:\inetpub\lcm_dark_site_bundle.tar.gz" -Force

tar -xvzf "C:\inetpub\lcm_dark_site_bundle.tar.gz" -C $ReleasePath

Write-Host "Dark site URL: http://<server-ip-or-fqdn>/release"
Write-Host "Test from a VM/CVM-side network before configuring LCM."
