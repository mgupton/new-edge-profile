#
# Usage:
#
# new-profile.ps1 "C:\Path\To\New\Profile"
#

param(
    [Parameter(Mandatory=$true)]
    [string]$profile_folder
)

# Get-ChildItem -Path $profile_folder -Force |
#    Remove-Item -Recurse -Force

robocopy "C:\Users\MichaelGupton\OneDrive - Avertium\Edge Browser Template\Profile 8" $profile_folder /E /XF *cache* /XD *cache*
 