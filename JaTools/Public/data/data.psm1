function fromJson([string]$path) { return Get-Content $path | ConvertFrom-Json }
function toJson([string]$path, $data) { Set-Content $path ( $data | ConvertTo-Json -Depth 6 ) -Force }


Export-ModuleMember -Function * -Variable *
