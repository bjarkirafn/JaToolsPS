$path = Import-Module $PSScriptRoot\..\path -AsCustomObject -Force

$hash = [hashtable]::Synchronized(@{
    # $FileName = ""
    # $Data     = $null
    # $Result   = @()
  })

$fileJobCleaner = {
  while ($true) {
    Start-Sleep -Seconds 60

    (Get-RSJob -Name jaFileSave -State Completed).id |
      ForEach-Object { Remove-rsjob -id $_ } |
      Out-Null

  }
}

$saveJob = {

  Set-Content ($using:hash).FileName ($using:hash).Data -Force -ErrorAction Inquire

}
function save {
  param([object]$obj)

  $fileName = Get-Item $obj.fileName
  $data = $obj.data

  if ($data -isnot [string]) {
    switch ($fileName.extension.substring(1)) {
      json { $data = $data | ConvertTo-Json -Depth 5 }
    }
  }

  try {
    Set-Content $fileName $data -ErrorAction SilentlyContinue
  }
  catch {
    Start-Sleep -Milliseconds 100
    Set-Content  $fileName$data -ErrorAction SilentlyContinue
  }


  # $hash.FileName = $fileName
  # $hash.Data = $data

  # if(!(Get-RSJob -Name jaFileCleaner)){
  #   Start-RSJob -Name jaFileCleaner -ScriptBlock $fileJobCleaner
  # }

  # Start-RSJob -Name jaFileSave -ScriptBlock $saveJob

}

Export-ModuleMember -Function *
