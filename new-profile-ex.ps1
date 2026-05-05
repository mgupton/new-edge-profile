# Choose a new profile name (avoid spaces to keep it simple)
param(
    [Parameter(Mandatory=$true)]
    [string]$profileName
)

$basePath = "C:\Users\MichaelGupton\AppData\Local\Microsoft\Edge\User Data"

Get-Childitem $basePath\Profile*

Write-Host "Profile path: $basePath"


if (Test-Path "$basePath\$profileName") {
    Write-Host "Profile '$profileName' already exists. Please choose a different name." -ForegroundColor Red
    exit
}

Write-Host "New profile folder: $basePath\$profileName" -ForegroundColor Green
Read-Host "Press Enter to continue"

# System-wide install (adjust path if needed)
$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

# First launch will create the profile folder under the default user-data-dir
# & $edge --profile-directory=$profileName
Start-Process -FilePath "$edge" `
              -ArgumentList "--profile-directory=""$profileName""" `
              -Wait

Read-Host "Press Enter to continue"
``

robocopy "C:\Users\MichaelGupton\OneDrive - Avertium\Edge Browser Template\Profile 8" "$basePath\$profileName" /E /XF *cache* /XD *cache*

