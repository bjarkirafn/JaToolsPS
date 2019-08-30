using namespace System.IO
Import-LocalizedData -BindingVariable Strings -FileName Strings -ErrorAction Ignore

$user = Resolve-Path ~
$script:jahome = "$user\.jaseisei"
$script:coreFile = "$jahome\core.json"

# $dev = $true
# $core = $null

# if (test-path $coreFile) {
#   $core = Get-Content $coreFile | ConvertFrom-Json
#   # $dev = $core.dev.mode
# }

# if ($dev -or !$jaTools) {

Remove-Variable jaTools -ErrorAction SilentlyContinue

$scripts = Get-ChildItem $PSScriptRoot\Public -Directory | Where-Object { $_.name -notmatch "_" }
$global:jaTools = [pscustomobject]@{ } | Select-Object $scripts.BaseName

# $core = Get-Content $coreFile | ConvertFrom-Json
# $core.psobject.properties.name|
#   ForEach-Object {
#     $value = $_.Value
#     $splat = @{
#       Name       = $_.Name
#       Value      = $value
#       MemberType = "NoteProperty"
#     }
#     $jaTools | Add-Member @splat
#   }

# $vars = @()

$scripts |
  ForEach-Object {
    $jaTools.($_.BaseName) = Import-Module $_ -AsCustomObject -Force
  }

# if (!$core) {
# $core = [pscustomobject]@{

#   home = $jahome
# }
# }
#
# $core = [pscustomobject]@{
#   core = $core
# }

# $jaTools | Add-Member -Name core -Value $core -MemberType NoteProperty


$coreEvent = {

  $isUpdated = {
    $coreData = { "$(Get-Content $root\core.json)".Replace(' ', '') }
    $obj = $jaTools.core | ConvertTo-Json -Depth 5 -Compress
    "$obj".Replace(' ', '') -ne (& $coreData)
  }

  if ((& $isUpdated)) {
    Write-Host "Must Save"
    Set-Content $root\core.json ($coreObj | ConvertTo-Json -Depth 5) -Force
  }
  else{
    Write-Host "All good!"
  }

}



# $global:jaToolstimer = New-Object timers.timer
# # 1 second interval
# $timer.Interval = 5000

# #Create the event subscription
# Register-ObjectEvent -InputObject $jaToolstimer -EventName Elapsed -SourceIdentifier Timer.Output -Action {
#     $coreObj = $global:jaTools.core | Convertto-json -Depth 6
#     $coreData = Get-Content $jahome\core.json | ConvertFrom-Json
#     if($coreObj -ne $coreData){
#       Write-Host "Must Save"
#     }

# }

# $jaToolstimer.Enabled = $True

# if (!(Get-PSBreakpoint -Script $modulePath)) {
#   Set-PSBreakpoint -Variable jaTools -Mode Read -Action {
#     write-host "Hi there!!"
#   }
# }

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Variable jaTools

