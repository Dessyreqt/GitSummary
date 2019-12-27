if ((Test-Path $profile) -eq $false) {
    New-Item -path $profile -type file -force
}

$profileContent = Get-Content -Path $profile
$aliasStr = 'New-Alias GitSummary "$PSScriptRoot\GitSummary.ps1"'
if ($null -eq $profileContent -or $profileContent.Contains($aliasStr) -eq $false) {
    Add-Content -Path $profile -Value $aliasStr
    Write-Host 'Alias "GitSummary" added to profile.'
}

$aliasCmd = $aliasStr + " -Scope Global"

if (!(Get-Alias GitSummary*)) {
    Invoke-Expression $aliasCmd
    Write-Host 'Alias "GitSummary" created for current session.'
} else {
    Write-Host 'Alias "GitSummary" already exists in current session.'
}
