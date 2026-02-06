
# Assign volume number to each chapter and increment volume number for every n chapters
$CONFIG_FILE="C:\myconfig\config.cfg"

# Populate config file
$CONFIG_OBJECT = Get-Content -Path $CONFIG_FILE | ConvertFrom-Json


$SourceDirectory = "$CONFIG_OBJECT.SRC_DIRECTORY"
$rx3pattern = "^(?<=chapter\s)\b\d{3}\b|(?<=ch\s?)\d{3}\b|(?<=c\s?)\d{3}\b" # find chapter numbers. expecting 00 or 000 chapter format
$DEGBUGCONSOLE = $false
$DEGBUGV = $false
$dirName = Split-Path -Path $SourceDirectory -Leaf # Get title of book source from path

$fileType=".cbz"
$SPACE=" "


$twoPProcFlag = $true
$threePProcFlag = $true


$volumeNumber=1 # Volume number assignment to a chapter
$chapterTracker=0 # Track number of chapters to assign to a volume before incrementing volume number
$volumeChapterMax=5 # Assign n chapters to a volume

if ($twoPProcFlag -eq $false) {
  # find chapter numbers various chapter formats with 2 digits
  # ie. chapter 00, chapter00, ch00, ch 00, c00, c 00
  $rx2pattern = "(?<=chapter)\s+\d{1,2}[\.]\d{1}|(?<=chapter)\s+\d{1,2}|(?<=ch)\s{0,1}\d{1,2}[\.]\d{1}|(?<=ch)\s{0,1}\d{1,2}\b|(?<=c)\s{0,1}\d{1,2}[\.]\d{1}|(?<=c)\s{0,1}\d{1,2}\b"
  write-host "rx2patter == $rx2pattern" -ForegroundColor red
  $badItems = Get-ChildItem -LiteralPath $SourceDirectory -Recurse -Include "*.cbz"
  # write-host "badItems count == $($badItems.Count)" -ForegroundColor Yellow
  # write-host "badItems  == $badItems" -ForegroundColor Yellow
  $badItems  | 
    Where-Object { $_.BaseName -imatch $rx2pattern} | 
      ForEach-Object {
        $matchvalue = $Matches[0].TrimStart() # remove leading space if exists 
        $bad02filename = $_.BaseName 
        $matchlength=$matchvalue.length
        if ($DEGBUGCONSOLE) {write-host "BEFORE :::match length $matchlength::: Bad filename - $bad02filename" -ForegroundColor Magenta}
        $padChNumber = if ($matchvalue.Length -lt 3){$matchvalue.PadLeft(3, '0')} # captures 1, 01, 1.1 > 001, 001.1
                       elseif ($matchvalue.Length -ge 3){([string]$matchvalue).PadLeft(5,'0')} #captures 02.1 > 002.1
        # $cleanName = $_.BaseName -replace $rx2pattern, $matchvalue.PadLeft(3,'0') #$newPrefix # .Substring(1)  use to remove leading zero
        $chapterString = "Chapter $padChNumber"
        $newName = "$chapterString$fileType"

         if ($DEGBUGCONSOLE) {write-host "AFTER :::::::::::: Renaming file to $newName" -ForegroundColor green}
         else {Rename-Item -Path $_.FullName -NewName $newName} #-WhatIf}} #-WhatIf}
      }
      $twoPProcFlag = $true
      Write-host "End of 2 Digit Chapter name update... twoPProcFlag = $twoPProcFlag" -ForegroundColor Cyan    
}


if ($twoPProcFlag -eq $true && $threePProcFlag -eq $false) {
  # find chapter numbers various chapter formats with 3 digits following and (deciaml or not)
  # ie. chapter 000, chapter000, ch000, ch 000, c000, c 000
  $rx3pattern = "(?<=chapter)\s+\d{3}[\.]\d{1}|(?<=chapter)\s+\d{3}\b|(?<=ch)\s{0,1}\d{3}[\.]\d{1}|(?<=ch)\s{0,1}\d{3}\b|(?<=c)\s{0,1}\d{3}[\.]\d{1}|(?<=c)\s{0,1}\d{3}\b" #"(?<=chapter)\s{0,1}\d{1,3}\.{0,1}\d{0,1}\b|(?<=ch)\s{0,1}\d{1,3}\.{0,1}\d{0,1}\b|(?<=c)\s{0,1}\d{3}\.{0,1}\d{0,1}\b"
  $badItems = Get-ChildItem -LiteralPath $SourceDirectory -Recurse -Include "*.cbz"
  $badItems  | 
    Where-Object { $_.BaseName -imatch $rx3pattern} | 
      ForEach-Object {
        $matchValue = $Matches[0].TrimStart() # remove leading space if exists
        $bad03BaseName = $_.BaseName
        $matchlength=$matchvalue.length 
        if ($DEGBUGCONSOLE -eq $true) {write-host "BEFORE :::match length $matchlength::: Bad filename with 3 digits - $bad03BaseName" -ForegroundColor red}
        # $cleanName = $_.BaseName -replace $rx3pattern, $matchvalue.PadLeft(3,'0') #$newPrefix # .Substring(1)  use to remove leading zero
        $chapterString = "Chapter $matchValue"
        $newName = "$chapterString$fileType"

        if ($DEGBUGCONSOLE -eq $true) {write-host "AFTER :::::: Renaming file to $newName" -ForegroundColor green}
        else {Rename-Item -Path $_.FullName -NewName $newName}  #-WhatIf} #-WhatIf}
      }
      $threePProcFlag = $true
      Write-host "End of 3 Digit Chapter name update... threePProcFlag = $threePProcFlag" -ForegroundColor Cyan    
}


# Start volume assignment process when twoPProcFlag AND threePProcFlag is completed(true)
if ($twoPProcFlag -eq $true && $threePProcFlag -eq $true) {
Write-host "Starting volume assignment process..." -ForegroundColor Cyan
$chrxpattern = "\d{3}\.{0,1}\d{1}|\d{3}" # find chapter numbers. expecting 000 or 000.0 chapter format
# Get list of Chapter ###.cbz files
$items=Get-ChildItem -LiteralPath $SourceDirectory -Recurse -Include "*.cbz"

# Loop through each chapter individually
$items  | 
  # Match chapter numbers in file name ### and process these matched files
  Where-Object {$_.BaseName -imatch $chrxpattern } | 
    # ::might not need this extra loop? 
    # for each matched file increase chapterTracker++

    ForEach-Object {

      $chapterTracker++

      # Increment $volumeNumber after processing 10 chapters? 
      # what if they're not in order :O due to different digit sizing issue 
      # ie. 02, 021, 022 are popualted sequentially thus 02 is assigned to volume 02
      if ($chapterTracker % $volumeChapterMax -le 0) {
        $volumeNumber++
        $chapterTracker=0
      } 

      $paddVolNumber = ([string]$volumeNumber).PadLeft(2, '0')
      $chapterNumber = $Matches[0] #([string]$Matches[0]).PadLeft(3, '0')
      if ($DEGBUGV) {write-host "chapterNumber found == $chapterNumber" -ForegroundColor green}
      $volprefix ="Vol $paddVolNumber"
      $chprefix="Ch $chapterNumber"
      # build final name ie. Manga Vol 01 Ch 001.cbz | Manga Vol 08 Ch 080.cbz
      #$dirName$SPACE
      $newFileName = "$dirName - $volPrefix$SPACE$chprefix$fileType" #$dirName$SPACE

      if ($DEGBUGV) {write-host "newfilename == $newFileName" -ForegroundColor Cyan}
      else {Rename-Item -Path $_.FullName -NewName $newFileName  #-WhatIf
      } #  -WhatIf} #-WhatIf # use -WhatIf to test rename
      }
    Write-host "End of Volume Chapter Assignment!!!" -ForegroundColor Cyan  
} 
  # write-host "$extractValue"
  # Write-Host "$dirName $($_.Name)"
  # Rename-Item -NewName { $_.DirectoryName + $_.Name }
