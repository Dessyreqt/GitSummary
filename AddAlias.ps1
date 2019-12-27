if ((Test-Path $profile) -eq $false) {
    New-Item -path $profile -type file -force
}

$profileContent = Get-Content -Path $profile
$aliasStr = 'New-Alias GitSummary "$PSScriptRoot\GitSummary.ps1"'
if ($null -eq $profileContent -or $profileContent.Contains($aliasStr) -eq $false) {
    Add-Content -Path $profile -Value $aliasStr
}

$aliasCmd = $aliasStr + " -Scope Global"

if (!(Get-Alias GitSummary*)) {
    Invoke-Expression $aliasCmd
    Write-Host 'Alias "GitSummary" created and added to profile.'
} else {
    Write-Host 'Alias "GitSummary" already exists.'
}
