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
