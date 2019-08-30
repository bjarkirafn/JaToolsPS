$script:time = import-module $PSScriptRoot\..\time -AsCustomObject -Force
$script:obj = import-module $PSScriptRoot\..\obj -AsCustomObject -Force
$script:file = import-module $PSScriptRoot\..\file -AsCustomObject -Force


enum LogFormat {
  Stacked
  Wide
}

class LoggerObject {
  [String]$Name
  [String]$Path
  [DateTime]$TimeStart
  [object[]]$LogText
  [object[]]$WatchList
  [object]$Format

}

class ChangedObject {
  [String]$Name
  [String]$From
  [String]$To
}

class Helpers {

  hidden [string] _logFormatter() {
    $formats = @{
      Stacked = {
        $result = @()
        $this.logList.GetEnumerator() |
          ForEach-Object {
            $result += "$($_.Time)`n$($_.Log)`n"
          }
        $result -join "`n"
      }

      Wide    = {
        (
          $this.logList.GetEnumerator() |
            ForEach-Object {
              $valuesLen = ($_.values -join ' ').Length
              $spaces = [int]($maxLength - $valuesLen - 2)
              "$($_.Log)$(' '*$spaces)$($_.Time)`n"
            }
        ) -join ""
      }
    }

    $key = $this.Format.Type

    if ($key -match "wide") {
      $maxLength = $this.Format.MaxLength
      $minSpace = $this.Format.MinSpace

      $spaceValue = ($this.logList |
          ForEach-Object { $_.values -join ' ' } |
          Sort-Object length)[-1].Length

      $spaceValue = $maxLength - $spaceValue
      if ($spaceValue -lt $minSpace) {
        $this.Format.MaxLength = $maxLength += ($minSpace - $spaceValue) + 2
      }

    }

    # if ($key -notin $this.format.type.keys) {
    #   $key = $this.format.type.keys[0]
    # }
    return & $formats.$key

  }

  hidden [void] _save() {

    $text = $this._logFormatter()

    # Set-Content $this.FileName $text -ErrorAction SilentlyContinue
    $script:file.save(@{
        FileName = $this.FileName
        Data     = $text
      })

    # $done = $false
    # while (!$done) {
    # try {
    #   # Set-Content $this.BackupFile ($this.logList | Convertto-json -depth 4) -ErrorAction SilentlyContinue
    #   # $script:file.save($this.FileName, $text)
    #   Set-Content $this.FileName $text -ErrorAction SilentlyContinue
    # }
    # catch {
    #   Start-Sleep -Milliseconds 100
    #   Set-Content $this.FileName $text -ErrorAction SilentlyContinue

    #   # $script:file.save(@{

    #   #     FileName = $this.FileName
    #   #     Data     = $text
    #   #   })
    #   # $done = $false
    # }
    # }




    #   try {
    #     Set-Content $this.FileName $text -ErrorAction SilentlyContinue | out-null
    #   }
    #   catch { continue }

    #   try {
    #   }
    #   catch { continue }
  }

  hidden [void] _addToLogList([string]$text) {
    $result = @{Time = Get-Date; Log = $Text }
    $this.logList += $result
    $this._save()
  }

}

class Logger : Helpers {

  hidden [array]$logList

  [String]$FileName
  [String]$BackupFile

  [object]$Format = @{
    Type      = "Stacked"
    MaxLength = 80
    MinSpace  = 6
  }

  Logger([LoggerObject]$Object) {

    $script:obj.splatMe($this, $Object)
    $this.FileName = Join-Path $this.Path "$($this.Name).log"
    $this.BackupFile = Join-Path $this.Path "$($this.Name).json"

    $this._startLog()
  }

  hidden [void] _startLog() {
    $this.TimeStart = Get-Date
    $text = $this.Name + " logging started"
    $this.logList = @()
    $this._addToLogList($text)
  }

  [void] changed([ChangedObject]$Obj) {
    $text = "$($Obj.Name) changed from: $($Obj.from) to: $($Obj.to)"
    $this.elapsed()
    $this._addToLogList($text)

    $this.TimeStart = Get-Date
  }


  [void] elapsed() {
    $prefix = $this.LogText.Elapsed.prefix
    $text = $prefix + $script:time.elapsed($this.TimeStart)

    if ($this.logList -and $this.logList[-1].Log -match $prefix) {
      $num = $this.logList.Count - 2
      $this.logList = $this.logList[0..$num]
    }

    $this._addToLogList($text)
  }

  [void] restart() { $this._startLog() }


  [void] testMe() { write-host ($this | ConvertTo-Json -depth 5) }
}

function newLogger([LoggerObject]$obj) {
  return [Logger]::new($obj)
}
