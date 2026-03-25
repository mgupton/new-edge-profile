
<#
.SYNOPSIS
Creates a new Microsoft Edge profile (via --user-data-dir) and sets a custom display name.

.PARAMETER ProfileDir
Folder to store the profile data (e.g., C:\EdgeProfiles\MyNewProfile). Must be unique.

.PARAMETER ProfileName
The display name you want to see in Edge (e.g., "Michael – Testing").

.PARAMETER EdgePath
Path to msedge.exe. Defaults to the standard install location if not provided.

.PARAMETER CreateShortcut
If set, creates a desktop shortcut to launch Edge with this profile.

.EXAMPLE
.\New-EdgeProfile.ps1 -ProfileDir "C:\EdgeProfiles\ConsultingProfile" -ProfileName "Consulting – Michael" -CreateShortcut
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ProfileDir,

    [Parameter(Mandatory = $true)]
    [string]$ProfileName,

    [string]$EdgePath = "${Env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",

    [switch]$CreateShortcut
)

function Write-Info($msg) { Write-Host "[INFO] $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Warning $msg }
function Write-Err($msg)  { Write-Host "[ERROR] $msg" -ForegroundColor Red }

# 1) Validate Edge binary
if (-not (Test-Path $EdgePath)) {
    $alt = "$Env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
    if (Test-Path $alt) { $EdgePath = $alt }
    else {
        Write-Err "msedge.exe not found. Specify -EdgePath explicitly."
        exit 1
    }
}

# 2) Ensure ProfileDir exists
try {
    if (-not (Test-Path $ProfileDir)) {
        Write-Info "Creating profile directory: $ProfileDir"
        New-Item -ItemType Directory -Path $ProfileDir -Force | Out-Null
    }
} catch {
    Write-Err "Failed to create profile directory: $($_.Exception.Message)"
    exit 1
}

# 3) Launch Edge once to initialize the profile
$edgeArgs = @(
    "--user-data-dir=`"$ProfileDir`"",
    "--no-first-run",
    "--no-default-browser-check"
)

Write-Info "Starting Edge to initialize profile..."
$proc = Start-Process -FilePath $EdgePath -ArgumentList $edgeArgs -PassThru

# 4) Wait for Preferences file to appear
$preferencesPath = Join-Path $ProfileDir "Default\Preferences"
$maxWaitSeconds = 30
$elapsed = 0
while (-not (Test-Path $preferencesPath) -and $elapsed -lt $maxWaitSeconds) {
    Start-Sleep -Seconds 1
    $elapsed++
}

if (-not (Test-Path $preferencesPath)) {
    Write-Warn "Preferences not found yet. Attempting graceful close of Edge and retry."
    try {
        # Try close window nicely
        $proc.CloseMainWindow() | Out-Null
        Start-Sleep -Seconds 2
    } catch {}

    # If still running, terminate
    if (-not $proc.HasExited) {
        Write-Info "Terminating Edge process..."
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }

    # Re-check in case it wrote on exit
    if (-not (Test-Path $preferencesPath)) {
        Write-Err "Preferences file still not present at: $preferencesPath"
        Write-Err "Try re-running the script or open Edge once with this profile and then re-run."
        exit 1
    }
} else {
    # Close Edge before editing Preferences to prevent write conflicts
    try {
        $proc.CloseMainWindow() | Out-Null
        Start-Sleep -Seconds 2
        if (-not $proc.HasExited) {
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        }
    } catch {}
}

# 5) Read and modify Preferences JSON
Write-Info "Updating profile display name in Preferences..."
try {
    $jsonText = Get-Content -Path $preferencesPath -Raw -ErrorAction Stop
    $prefs = $jsonText | ConvertFrom-Json -ErrorAction Stop

    if (-not $prefs.profile) {
        $prefs | Add-Member -MemberType NoteProperty -Name profile -Value (@{})
    }
    $prefs.profile.name = $ProfileName

    # Optionally set a custom avatar icon (0–29 are standard Chromium icons)
    # if (-not $prefs.profile.avatar_icon) {
    #     $prefs.profile.avatar_icon = 26  # pick any, or remove this line
    # }

    # Write back JSON with reasonable depth
    $newJson = $prefs | ConvertTo-Json -Depth 20
    Set-Content -Path $preferencesPath -Value $newJson -Encoding UTF8
} catch {
    Write-Err "Failed to update Preferences: $($_.Exception.Message)"
    exit 1
}

Write-Info "Profile name set to: '$ProfileName'"
Write-Info "Profile data: $ProfileDir"
Write-Info "Preferences: $preferencesPath"

# 6) Optional – create a desktop shortcut
if ($CreateShortcut) {
    try {
        $desktop = [Environment]::GetFolderPath("Desktop")
        $shortcutPath = Join-Path $desktop ("Edge - " + ($ProfileName -replace '[\\/:*?"<>|]', '_') + ".lnk")

        $wsh = New-Object -ComObject WScript.Shell
        $sc = $wsh.CreateShortcut($shortcutPath)
        $sc.TargetPath = $EdgePath
        $sc.Arguments  = "--user-data-dir=`"$ProfileDir`" --no-first-run --no-default-browser-check"
        $sc.WorkingDirectory = Split-Path $EdgePath
        $sc.IconLocation = "$EdgePath,0"
        $sc.Save()

        Write-Info "Shortcut created: $shortcutPath"
    } catch {
        Write-Warn "Failed to create shortcut: $($_.Exception.Message)"
    }
}

Write-Host "`nDone. Launch Edge with:"
Write-Host "`"$EdgePath`" --user-data-dir=`"$ProfileDir`"" -ForegroundColor Green
``
