
try {
  Import-Module PoshRSJob -ErrorAction Stop
}
catch {
  Write-Warning "`r`nPoshRSJob Module needs to be installed."
  $result = Read-Host -prompt "Do you want me to install it for you? [no\Yes]"

  if ($result -like '' -or $result.startswith('y')) {
    Install-Module PoshRSJob -Scope CurrentUser -PassThru
    Import-Module PoshRSJob
  }
}


function stop {
  param([string]$Name)
  if ($name) {
    $jobs = (Get-RSJob).Where( { $_.Name -like $Name }) |
      ForEach-Object {
        Stop-RSJob -id $_.id
        Remove-RSJob -id $_.id
      }
  }
}

function disposeAll {
  foreach ($job in (Get-RSJob)) {
    Remove-RSJob -id $job.id
  }
}

Export-ModuleMember -Function *
