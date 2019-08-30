Get-Item $PSScriptRoot\_*.ps1 | ForEach-Object { .$_ }

Export-ModuleMember -Function *
