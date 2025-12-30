
# System-wide install (adjust path if needed)
$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

# Choose a new profile name (avoid spaces to keep it simple)
$profileName = "m1k3"

# First launch will create the profile folder under the default user-data-dir
& $edge --profile-directory=$profileName


robocopy "C:\Users\MichaelGupton\OneDrive - Avertium\Edge Browser Template\Profile 8" "	C:\Users\MichaelGupton\AppData\Local\Microsoft\Edge\User Data\$profile_folder" /E /XF *cache* /XD *cache*

