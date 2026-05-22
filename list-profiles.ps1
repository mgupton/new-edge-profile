

Get-ChildItem "HKCU:\Software\Microsoft\Edge\Profiles" |
ForEach-Object {
    $props = Get-ItemProperty $_.PSPath
    [PSCustomObject]@{
        ShortcutName     = $props.ShortcutName
        ProfileDirectory = $_.PSChildName
    }
}
