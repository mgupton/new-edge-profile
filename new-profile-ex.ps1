# Choose a new profile name (avoid spaces to keep it simple)
param(
    [Parameter(Mandatory=$true)]
    [string]$profileName
)


# System-wide install (adjust path if needed)
$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

# First launch will create the profile folder under the default user-data-dir
# & $edge --profile-directory=$profileName
Start-Process -FilePath "$edge" `
              -ArgumentList "--profile-directory=$profileName" `
              -Wait

Read-Host "Press Enter to continue"
``

robocopy "C:\Users\MichaelGupton\OneDrive - Avertium\Edge Browser Template\Profile 8" "C:\Users\MichaelGupton\AppData\Local\Microsoft\Edge\User Data\$profileName" /E /XF *cache* /XD *cache*

