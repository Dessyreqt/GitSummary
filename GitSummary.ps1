$gitDirs = Get-ChildItem . -Attributes Directory+Hidden -ErrorAction SilentlyContinue -Filter ".git" -Recurse
$gitStatusList = New-Object System.Collections.ArrayList($null)

foreach ($gitDir in $gitDirs) {
    $parentDir = $gitDir.parent.fullname
    Push-Location $parentDir
    $branch = git symbolic-ref HEAD | %{$_ -replace "^refs\/heads\/" }
    $gitStatus = [PSCustomObject]@{ 
        Directory = $parentDir
        Branch = $branch
    }
    $gitStatusList.Add($gitStatus) | Out-Null
    Pop-Location
}

$gitStatusList | Format-Table
