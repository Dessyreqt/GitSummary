function Get-GitDirs {
    Get-ChildItem . -Attributes Directory+Hidden -ErrorAction SilentlyContinue -Filter ".git" -Recurse
}

function Get-RemoteState {
    param ( [string]$branch )
    $remoteState = ""
    [string]$upstream = git remote
    if ($upstream.Length -gt 0) {
        & git fetch | Out-Null
        $remoteBranch = "$upstream/$branch"
        $unpulled = (git log --pretty=format:'%h' ..$remoteBranch | Measure-Object -Character).Characters
        $unpushed = (git log --pretty=format:'%h' "${remoteBranch}.." | Measure-Object -Character).Characters

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

function Get-LocalState {
    param ( [string]$branch )
    $localState = ""
    $untracked = (git status | Select-String -Pattern "Untracked").Matches.Count
    $newFiles = (git status | Select-String -Pattern "new file").Matches.Count
    $modified = (git status | Select-String -Pattern "modified").Matches.Count

    if ($untracked -ne 0) {
        $localState += "?"
    } else {
        $localState += " "
    }

    if ($newFiles -ne 0) {
        $localState += "+"
    } else {
        $localState += " "
    }

    if ($modified -ne 0) {
        $localState += "M"
    } else {
        $localState += " "
    }

    $localState
}

function Get-GitStatus {
    param ( [string]$dir )
    Push-Location $dir
    $branch = git symbolic-ref HEAD | ForEach-Object { $_ -replace "^refs\/heads\/" }
    $remoteState = Get-RemoteState $branch
    $localState = Get-LocalState $branch
    Pop-Location
    [PSCustomObject]@{ 
        Directory = $dir
        Branch = $branch
        State = $localState + $remoteState
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

