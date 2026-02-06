# Unpack MANY cbz or rar files into single directory.
# Used to unpack individual chapters into a single volume
# need to rename files/images wwithin each chapter to follow the pattern v##-c###.png(.jpg)

$CONFIG_FILE="C:\myconfig\config.cfg"

# Populate config file
$CONFIG_OBJECT = Get-Content -Path $CONFIG_FILE | ConvertFrom-Json

$SourceDirectory = "$CONFIG_OBJECT.SRC_DIRECTORY"
$DestinationDirectory = $SourceDirectory + "\unpacked"

$filesToExtract = Get-ChildItem -Path $SourceDirectory -Recurse -File -Include "*.cbz", "*.zip", "*.rar"
$filesToExtract | ForEach-Object {  
  Write-host "$($_.FullName)"
  $FullName = "$($_.FullName)"
  $FileName = "$($_.Name)"
  $directoryName = $_.Directory.FullName 
  $SEVENZIP = "$env:ProgramFiles\7-Zip\7z.exe"


  $shortName = $_.BaseName

  # $shortenName =  $shortname -replace '\s?-{2,}\s?|\s?\[.*?\]\s?|\s+?(?=\.)', ''
  # $shortenPDFName = $shortenName + ".cbz"
  # $fullShortenPath = Join-Path -Path $directoryName -ChildPath $shortenPDFName  
  
  # write-host "clean name: $shortenPDFName" -ForegroundColor Yellow
  # Write-Host " new full path : $fullShortenPath" -ForegroundColor Green
  $BaseName = "$($_.BaseName)"
  $outputPath = Join-Path -Path $DestinationDirectory -ChildPath $BaseName

  # unpack
  & $SEVENZIP x -bso0 -y "$FullName" -o"$outputPath"  
  
} 
Write-Host "Unpacking complete!! Find files in $outputPath" -ForegroundColor Green