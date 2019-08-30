get-item $PSScriptRoot\*.ps1 | ForEach-Object { .$_ }

Export-ModuleMember -Function * -Variable *
