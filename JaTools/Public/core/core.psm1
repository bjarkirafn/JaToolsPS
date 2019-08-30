$script:jaData = Import-Module "$PSScriptRoot\..\data" -AsCustomObject
$script:coreFile = Resolve-Path "~\.jaseisei\core.json"
$moduleName = "core.psm1"
$modulePath = "$PSScriptRoot\$moduleName"




function get {
  return  Get-Content $script:coreFile | ConvertFrom-Json

}
function set {
  write-host "setting core"
  # return  Get-Content $script:coreFile | ConvertFrom-Json

}


Get-PSBreakpoint -Script $modulePath | Remove-PSBreakpoint

$vars = @()

if (test-path $script:coreFile) {

  (get).psobject.properties |
    ForEach-Object {
      $name = $_.name
      $vars += $name
      New-Variable -Name $name -Value $_.Value
      Set-PSBreakpoint -Script $modulePath -Variable $name -Action {
        $name = Get-Variable $name -ValueOnly
        "You called $(get-variable $name)"
      }
    }
}




# $bpAction = {
#   write-host "Action!!"
#   $var = $_.tostring().split(":")[-1].split(' ')[0].trim("'$")
#   $value = Get-Variable $var -ValueOnly
#   $core = get

#   $valueSerial = $value | ConvertTo-Json -Depth 5
#   $coreSerial = $core.$var | ConvertTo-Json -Depth 5

#   if ($valueSerial -ne $coreSerial) {
#     $core.$var = $value
#     set $core $var
#   }
# }






Export-ModuleMember -Function $funcs -Variable $vars
