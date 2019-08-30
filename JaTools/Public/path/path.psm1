$is = Import-Module $PSScriptRoot\..\is -AsCustomObject -PassThru

get-item $PSScriptRoot\*.ps1 | ForEach-Object { .$_ }

function bestMatches {
  param($Find, $Path)
  $pattern = "*$($find.ToCharArray() -join "*")*"
  return Get-ChildItem $path |
    Where-Object { $PSItem.BaseName -like $pattern }
}

function resolve([string]$path) {
  $root = $path.Substring(0, 1)
  if ($root -match "~|.") {
    $root = Resolve-Path $root
    $path = "$root$($path.Substring(1))"
  }

  return $path

}

function findValidPath([string]$path) {
  $path = resolve $path

  [string[]]$leafs = split-path $path -Leaf
  [string]$validPath = split-path $path

  while (!(& { Test-Path $validPath })) {
    $leafs += Split-Path $validPath -Leaf
    $validPath = Split-Path $validPath
  }

  [array]::Reverse($leafs)
  $validPath = Get-Item $validPath

  return [pscustomobject]@{
    Result = $validPath, $leafs
    Path   = $validPath
    Leafs  = $leafs
  }
}

function fuzzyFind([string]$path) {

  if (Test-Path $path) { return Get-Item $path }

  $validPath, $leafs = (findValidPath $path).Result

  $result = [pscustomobject]@{
    Result = @()
    Info   = [pscustomobject]@{
      ValidPath = $validPath
      Leafs     = $leafs
      Fixes     = @()
      Matches   = @()
    }
  }

  $matchPath = $validPath

  $leafs |
    ForEach-Object {
      $fuzzyName = $_
      $match = bestMatches $fuzzyName $matchPath

      # update matchPath with root matched path
      if ($match) {
        if ([system.io.directory]::Exists($match[0])) {
          $matchPath = $match[0]
        }
        # Fixed path matches
        $result.info.fixes += [pscustomobject]@{
          Before = $fuzzyName
          After  = $match[0].name
        }
        # iterate over all matches
        $match |
          ForEach-Object {
            # if path name match the match root path name
            if ($_.Name -match $matchPath.Name) {
              $result.Info.Matches += [pscustomobject]@{
                $_.name = $_.FullName
              }
              # if this is the last loop iteration, add result to DidYouMean
              if ($fuzzyName -like $leafs[-1]) {
                $result.Result += $_.FullName
              }
            }
          }
      }
      else { "To be continued" }
    }
  return $result
}




function me($path) {

  if (!(Test-Path $path)) {
    $path = resolve $path

    if ($true -notin (
        [File]::Exists($path),
        [Directory]::Exists($path))
    ) {
      makeParent $path
    }
  }

  return Get-Item $path
}

Export-ModuleMember -Function * -Variable *
