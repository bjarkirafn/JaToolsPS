get-item $PSScriptRoot\_*.ps1 | ForEach-Object { .$_ }

function getFileAssociations {
  param([string]$Suffix)

  $assFile = $jaCore.core.home + "\jadb\fileAssiocations.xml"
  if (!(Test-Path $assFile)) {
    Dism.exe /Online /Export-DefaultAppAssociations:$assFile | Out-Null
  }
  [xml]$assData = get-content $assFile

  if ($Suffix) {
    return $assData.DefaultAssociations.Association.Where( { $_.identifier -like $Suffix })
  }

  return $assData.DefaultAssociations.Association

}
function getInstalledApps {
  $paths = @(
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\',
    # "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'



  )

  return $paths |
    ForEach-Object {
      Get-ChildItem -Path $_ |
        Get-ItemProperty |
        Select-Object DisplayName, Publisher, InstallDate, DisplayVersion
    } | Sort-Object DisplayName
}


function getIndicatorApp {
  param($Indicator)

  $pattern = '[^a-zA-Z]'
  $fileAss = getFileAssociations

  $appName = ($fileAss.where( { $_.Identifier -like $Indicator }).applicationName -replace $pattern, ' ')
  $appName = $appName.split(' ').Where( { $_ })

  $appNames = @()
  for ($i = $appName.Count - 1; $i -ge 0; $i--) {
    $appNames += $appName[$i]
  }

  $appCommand = $env:path.split(';')
  $appNames |
    ForEach-Object {
      $name = $_
      if ($appCommand.count -gt 1) {
        $appCommand = $appCommand.where( { $_ -match $name })
      }

    }

  return , $appCommand |
    ForEach-Object {
      get-Item $_ |
        ForEach-Object {
          (get-item "$(split-path $_)\*.exe").Where({ $_.name -notmatch 'unins' })
        }
    }
}

function openInDefaultApp{
  param($fileName)

  $fileName = Get-Item $fileName
  $cmd = getIndicatorApp $fileName.Extension

  $proc = Start-Process $cmd -ArgumentList $fileName  -Wait
}



Export-ModuleMember -Function *
