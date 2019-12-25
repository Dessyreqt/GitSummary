function Get-GitDirs {
    Get-ChildItem . -Attributes Directory+Hidden -ErrorAction SilentlyContinue -Filter ".git" -Recurse
}

function Get-RemoteState {
    param ( [string]$branch )
    & git fetch
    $remoteState = ""
    [string]$upstream = git remote
    if ($upstream.Length -gt 0) {
        $remoteBranch = "$upstream/$branch"
        $unpulled = (& git log --pretty=format:'%h' ..$remoteBranch | Measure-Object -Character).Characters
        $unpushed = (& git log --pretty=format:'%h' "${remoteBranch}.." | Measure-Object -Character).Characters

        if ($unpulled -ne 0) {
            $remoteState += "v"
        } else {
            $remoteState += " "
        }

        if ($unpushed -ne 0) {
            $remoteState += "^"
        } else {
            $remoteState += " "
        }
    } else {
        $remoteState = "--"
    }
    
    $remoteState
}

function Get-GitStatus {
    param ( [string]$dir )
    Push-Location $dir
    $branch = git symbolic-ref HEAD | ForEach-Object { $_ -replace "^refs\/heads\/" }
    $remoteState = Get-RemoteState $branch
    Pop-Location
    [PSCustomObject]@{ 
        Directory = $dir
        Branch = $branch
        State = $remoteState
    }
}

function Write-GitStatusList {
    param ( [System.Collections.ArrayList]$gitStatus )
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

