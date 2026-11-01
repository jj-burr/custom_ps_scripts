# PS Script to rename all files in a directory based on regex pattern assigned in $rxpattern and a new prefix
param(
    [switch]$whatif,
    [switch]$cleanchapter,
    [string]$filetype = $CONFIG_OBJECT.CBZ_FILE_EXT
)
$CONFIG_FILE="C:\Users\jimmy\Documents\mlibrary\ps-scripts\custom_ps_scripts\config.json"

# Populate config file
$CONFIG_OBJECT = Get-Content -Path $CONFIG_FILE | ConvertFrom-Json 

# Ensure a file extension is always used; default to .cbz if missing
if (-not $filetype -or $filetype -eq '') {
    $filetype = '.cbz'
}

$SourceDirectory = $CONFIG_OBJECT.SRC_DIRECTORY
Write-Host "Source Directory: $SourceDirectory" -ForegroundColor Green

# Tracking variables
$totalFiles = 0
$successCount = 0
$failedCount = 0
$failedFiles = @()

$rxpattern = "Chapter " #^(\d{0,3}\s)|\s\(\D*\-\D*\)|\s\(\d*\sof\s\d*\)|\s\(of\s\d*\)" #"\s\(\D*\s?\)|\(\w*\)\s" #"\s\(\D*\s?\)|\s?\(.*\)\s?" #"\s\(\D*\s?\)|\(\w*\)\s"
# $manhwaPattern = "\s-\s(SE\s\d{1,3}\s\-)?[a-zA-z'\s\.,\-\d!]+"  # removes the chapter name and SE numbers
# $rxLeadZPattern = "\.|c[h.0-9]{1,4} ch"
$dirName = Split-Path -Path $SourceDirectory -Leaf # sometimes name is repeated, manually apply
# Default prefix is the directory name; -cleanChapter switch uses just "Chapter "
if ($cleanChapter) {
    $newPrefix = "Chapter "
} else {
    $newPrefix = "$dirName - Chapter "
} 

# Get list of Chapter ###.cbz files
$items=Get-ChildItem -LiteralPath $SourceDirectory -Recurse -File "*" # Swap File to Directory here
$totalFiles = $items.Count
Write-Host "Total $filetype files found: $totalFiles" -ForegroundColor Cyan

# Loop through each chapter individually
$items  | 
  # Match chapter numbers in file name ### and process these matched files
  Where-Object {$_.Name -imatch $rxpattern } | 
    # ::might not need this extra loop? 
    # for each matched file increase chapterTracker++
    ForEach-Object {
     
    $matchvalue = $Matches[0]
     write-host "matchvalue:::: $matchvalue" -ForegroundColor green

    
    $cleanName = $_.BaseName -replace $rxpattern,  $newprefix #"$newPrefix$matchvalue" #$newPrefix #
    write-host "cleanName:::: $cleanName$filetype" -ForegroundColor green
    # write-host "newprefix:::: $newprefix" -ForegroundColor green

    # Rename-Item -LiteralPath $_.FullName -NewName "$($_.Name)"  -WhatIf
    # Rename-Item -LiteralPath $_.FullName -NewName { [System.IO.Path]::ChangeExtension($_.Name, ".cbr") } -WhatIf
    
    
    if ($_.PSIsContainer) {
      # Directory logic rename
      ## Disabled to prevent losing file path when when proccessing files only
      $newName = "$cleanName$filetype" #
      Write-Host "The item is a directory. $($_.Name) >>>> newname: $newName" -ForegroundColor Green
      if (-not $whatif) {
          try {
              Rename-Item -LiteralPath $_.FullName -NewName $newName -ErrorAction Stop
              $successCount++
          } catch {
              $failedCount++
              $failedFiles += $_.FullName
              Write-Host "FAILED to rename directory $($_.Name): $_" -ForegroundColor Red
          }
      } else {
          Write-Host "[WhatIf] Would rename directory $($_.Name) to $newName" -ForegroundColor Gray
          $successCount++  # count whatif as "processed"
      }
    } else {
      # $fileExtension = $filetype #$_.Extension
      # Write-Host "fileExtension: $fileExtension" -ForegroundColor Cyan
      $newName = "$cleanName$filetype" 

      if (-not $whatif) {
          try {
              Write-Host " $($_.Name)  >>>> newname: $newName" -ForegroundColor Yellow
              Rename-Item -LiteralPath $_.FullName -NewName $newName -ErrorAction Stop
              $successCount++
          } catch {
              $failedCount++
              $failedFiles += $_.FullName
              Write-Host "FAILED to rename file $($_.Name): $_" -ForegroundColor Red
          }
      } else {
          Write-Host "[WhatIf] Would rename file $($_.Name) to $newName" -ForegroundColor Gray
          $successCount++  # count whatif as "processed"
      }
    } 
  }

# Summary
Write-Host "---" -ForegroundColor Cyan
Write-Host "Total $filetype files found: $totalFiles" -ForegroundColor Cyan
Write-Host "Successfully renamed: $successCount" -ForegroundColor Green
Write-Host "Failed to rename: $failedCount" -ForegroundColor Red
Write-Host "Regex pattern used: $rxpattern" -ForegroundColor Magenta
if ($failedFiles.Count -gt 0) {
    Write-Host "Failed files:" -ForegroundColor Red
    $failedFiles | ForEach-Object { Write-Host "  $_" }
}