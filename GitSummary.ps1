function Get-GitDirs {
    Get-ChildItem . -Attributes Directory+Hidden -ErrorAction SilentlyContinue -Filter ".git" -Recurse
}

function Get-GitStatus {
    param ([string]$dir)
    Push-Location $dir
    $branch = git symbolic-ref HEAD | ForEach-Object { $_ -replace "^refs\/heads\/" }
    Pop-Location
    [PSCustomObject]@{ 
        Directory = $dir
        Branch = $branch
    }
}

function Write-GitStatusList {
    param ([System.Collections.ArrayList]$gitStatus)
    $gitStatusList | Format-Table    
}

$gitDirs = Get-GitDirs
$gitStatusList = New-Object System.Collections.ArrayList($null)

foreach ($gitDir in $gitDirs) {
    $parentDir = $gitDir.parent.fullname
    $gitStatus = Get-GitStatus $parentDir
    $gitStatusList.Add($gitStatus) | Out-Null
}

Write-GitStatusList $gitStatusList

