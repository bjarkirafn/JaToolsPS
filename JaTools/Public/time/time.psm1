function elapsed([DateTime]$Start) {
  $span = New-TimeSpan $Start  (get-date) | Select-Object Hours, Minutes, Seconds
  return "{0:D2}:{1:D2}:{2:D2}" -f $span.psobject.properties.value
}

Export-ModuleMember -function *
