param (
    [Alias("l", "local")][switch] $localOnly = $false
)

function Get-GitDirs {
    Get-ChildItem . -Attributes Directory+Hidden -ErrorAction SilentlyContinue -Filter ".git" -Recurse
}

function Get-RemoteState([string] $branch) {
    $remoteState = ""
    $remoteBranch = "origin/$branch"
    $upstreamExists = (git branch -r | Select-String -Pattern "$remoteBranch$").Matches.Count
    if ($upstreamExists -gt 0) {
        if ($localOnly -eq $false) {
            & git fetch | Out-Null
        }
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

function Get-LocalState([string] $branch) {
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

function Get-GitStatus([string] $dir) {
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

function Format-Color {
	$lines = ($input | Out-String) -replace "`r", "" -split "`n"
	foreach($line in $lines) {
        if ($line.Length -gt 5) {
            $color = ""
            $state = $line.Substring($line.Length - 5, 5)
            if ($state -like "   *") { 
                $color = "Green"
            }
            if ($state -like "*[v^]*") { 
                $color = "Yellow"
            }
            if ($state -like "*[?+M]*") { 
                $color = "Red"
            }
            if($color) {
                Write-Host -ForegroundColor $color $line
            } else {
                Write-Host $line
            }
        } else {
            Write-Host $line
        }
	}
}

function Write-GitStatusList([System.Collections.ArrayList] $gitStatus) {
    $gitStatusList | Format-Table | Format-Color  
}

$gitDirs = Get-GitDirs
$gitStatusList = New-Object System.Collections.ArrayList($null)

foreach ($gitDir in $gitDirs) {
    $parentDir = $gitDir.parent.fullname
    $gitStatus = Get-GitStatus $parentDir
    $gitStatusList.Add($gitStatus) | Out-Null
}

Write-GitStatusList $gitStatusList

