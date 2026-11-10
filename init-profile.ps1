
param(
    [Parameter(Mandatory=$true)]
    [string]$profileName
)

$basePath = "C:\Users\MichaelGupton\AppData\Local\Microsoft\Edge\User Data"
robocopy "C:\Users\MichaelGupton\OneDrive - Avertium\Edge Browser Template\Profile 8" "$basePath\$profileName" /E /XF *cache* /XD *cache*