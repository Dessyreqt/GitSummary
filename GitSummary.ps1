$gitDirs = Get-ChildItem . -Attributes Directory+Hidden -ErrorAction SilentlyContinue -Filter ".git" -Recurse
$gitStatusList = New-Object System.Collections.ArrayList($null)

foreach ($gitDir in $gitDirs) {
    $parentDir = $gitDir.parent.fullname
    Push-Location $parentDir
    $name = Split-Path -Leaf (git remote get-url origin)
    $branch = git branch --show-current
    $gitStatus = [PSCustomObject]@{ 
        Name = $name
        Branch = $branch
    }
    $gitStatusList.Add($gitStatus) | Out-Null
    Pop-Location
}

$gitStatusList | Format-Table
