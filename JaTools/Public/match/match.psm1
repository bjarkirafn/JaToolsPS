class Best {
  [psobject] Path([string]$Path) {
    return @{Result = $Path }
  }

}


$best = [Best]::new()



# function fuzzy {
#   param (
#     # The search query.
#     # [Parameter(Position = 0)]
#     # [ValidateNotNullOrEmpty()]
#     [string] $Search,

#     # The data you want to search through.
#     # [Parameter(Position = 1, ValueFromPipeline = $true)]
#     # [ValidateNotNullOrEmpty()]
#     # [Alias('In')]
#     [string] $Data

#     # Set to True (default) it will calculate the match score.
#     # [Parameter()]
#     # [switch] $CalculateScore = $true
#   )

#   BEGIN {
#     CalculateScore = $true
#     # Remove spaces from the search string
#     $search = $Search.Replace(' ', '')

#     # Add wildcard characters before and after each character in the search string
#     $quickSearchFilter = '*'

#     $search.ToCharArray().ForEach( {
#         $quickSearchFilter += $_ + '*'
#       })
#   }

#   PROCESS {
#     foreach ($string in $Data) {

#       # Trim to get rid of offending whitespace
#       $string = $string.Trim()

#       # Do a quick search using wildcards
#       if ($string -like $quickSearchFilter) {

#         Write-Verbose "Found match: $($string)"

#         if ($CalculateScore) {

#           # Get score of match
#           $score = Get-FuzzyMatchScore -Search $Search -String $string

#           Write-Output (, ([PSCustomObject][Ordered] @{
#                 Score  = $score
#                 Result = $string
#               }))
#         }

#         else {
#           $string
#         }
#       }
#     }
#   }
# }


function fuzzy([string]$Search, [string[]]$InItems) {
  $search = $Search.Replace(' ', '')
  $quickSearchFilter = "*" + ($search.ToCharArray() -join '*') + "*"
  $quickSearchFilter

}

Export-ModuleMember -Function * -Variable *
