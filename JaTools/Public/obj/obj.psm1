function splatMe{
  param([object]$obj, [pscustomobject]$kwargs)

  $kwargs.psobject.properties |
  ForEach-Object {
    $splat = @{
      Name       = $_.Name
      Value      = $_.Value
      MemberType = "NoteProperty"
    }
    $obj | Add-Member @splat
  }
}
