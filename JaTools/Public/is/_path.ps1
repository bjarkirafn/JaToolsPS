function path($item) {
  return $item -match "\\|/|:"
}

function validPath($path) {
  return Test-Path $path
}


function pathAndValid($item) {
  return (path $path) -and (validPath $path)
}
