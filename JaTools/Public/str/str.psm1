using namespace system.io



# get-item $PSScriptRoot\*.ps1 |
#   ForEach-Object {
#     . $_.FullName
#   }



class To {

  [string] Title([string[]]$Text) {
    return (Get-Culture).TextInfo.ToTitleCase($Text)
  }

}

$to = [To]::new()


# class Time {
#   [string] Elapsed([DateTime]$Start) {
#     $span = New-TimeSpan $Start  (get-date) | Select-Object Hours, Minutes, Seconds
#     return "{0:D2}:{1:D2}:{2:D2}" -f $span.psobject.properties.value
#   }
# }

# $time = [Time]::new()

Export-ModuleMember -Function * -Variable *
