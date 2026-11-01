# PS Script to rename all files in a directory based on regex pattern assigned in $rxpattern and a new prefix
param(
    [switch]$WhatIf,
    [switch]$UseDirName
)
$CONFIG_FILE="C:\Users\jimmy\Documents\mlibrary\ps-scripts\custom_ps_scripts\config.json"

# Populate config file
$CONFIG_OBJECT = Get-Content -Path $CONFIG_FILE | ConvertFrom-Json

$SourceDirectory = $CONFIG_OBJECT.SRC_DIRECTORY
#Write-Host "Source Directory: $SourceDirectory" -ForegroundColor Green
$rxpattern =  "Ch. " #^(\d{0,3}\s)|\s\(\D*\-\D*\)|\s\(\d*\sof\s\d*\)|\s\(of\s\d*\)" #"\s\(\D*\s?\)|\(\w*\)\s" #"\s\(\D*\s?\)|\s?\(.*\)\s?" #"\s\(\D*\s?\)|\(\w*\)\s"
  # $manhwaPattern = "\s-\s(SE\s\d{1,3}\s\-)?[a-zA-z'\s\.,\-\d!]+"  # removes the chapter name and SE numbers
  # $rxLeadZPattern = "\.|c[h.0-9]{1,4} ch"
$dirName = Split-Path -Path $SourceDirectory -Leaf # sometimes name is repeated, manually apply
# todo: create option to set dirname into the newPrefix variable for the new filename
# Use directory name as prefix if -UseDirName switch is supplied, otherwise default to "Chapter "
if ($UseDirName) {
    $newPrefix = $dirName
} else {
    $newPrefix = "Chapter "
}
# $fileType=".cbr"

# Get list of Chapter ###.cbz files
$items=Get-ChildItem -LiteralPath $SourceDirectory -Recurse -File "*" # Swap File to Directory here

# Write-Host "items: $items"
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
      write-host "cleanName:::: $cleanName" -ForegroundColor green
      # write-host "newprefix:::: $newprefix" -ForegroundColor green

      # Rename-Item -LiteralPath $_.FullName -NewName "$($_.Name)"  -WhatIf
      # Rename-Item -LiteralPath $_.FullName -NewName { [System.IO.Path]::ChangeExtension($_.Name, ".cbr") } -WhatIf
      
      
      if ($_.PSIsContainer) {
        # Directory logic rename
        ## Disabled to prevent losing file path when when proccessing files only
        $newName = "$cleanName" #$fileType 
        Write-Host "The item is a directory. $($_.Name) >>>> newname: $newName" -ForegroundColor Green
        if (-not $WhatIf) {
            Rename-Item -LiteralPath $_.FullName -NewName $newName
        } else {
            Write-Host "[WhatIf] Would rename directory $($_.Name) to $newName" -ForegroundColor Gray
        }
      } else {
        $fileExtension = ".cbz" #$_.Extension
        Write-Host "fileExtension: $fileExtension" -ForegroundColor Cyan
        $newName = "$cleanName$fileExtension" #$fileType
        Write-Host "The item is a file. $($_.Name)  >>>> newname: $newName" -ForegroundColor Yellow
        if (-not $WhatIf) {
            Rename-Item -LiteralPath $_.FullName -NewName $newName
        } else {
            Write-Host "[WhatIf] Would rename file $($_.Name) to $newName" -ForegroundColor Gray
        }
      } 
    }