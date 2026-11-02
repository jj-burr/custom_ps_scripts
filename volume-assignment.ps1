# Assign volume number to each chapter and increment volume number for every n chapters
param(
    [switch]$whatIf,
    [switch]$volumeflag,
    [switch]$debugv
)
$CONFIG_FILE="C:\Users\jimmy\Documents\mlibrary\ps-scripts\custom_ps_scripts\config.json"
# Populate config file
$CONFIG_OBJECT = Get-Content -Path $CONFIG_FILE | ConvertFrom-Json

# Set variables from config
$BASE_SRC_DIRECTORY = $CONFIG_OBJECT.BASE_SRC_DIRECTORY
$targetDirs = $CONFIG_OBJECT.TARGET_DIRS -split ',\s*'

# Loop through each target directory
foreach ($targetDir in $targetDirs) {
    # Per-target SourceDirectory
    $SourceDirectory = Join-Path $BASE_SRC_DIRECTORY $targetDir
    # dirName derived from target directory name
    $dirName = $targetDir

    Write-Host "Processing target directory: $targetDir" -ForegroundColor Green
    Write-Host "Source Directory: $SourceDirectory" -ForegroundColor Green

    # Allowed file extensions (comma‑separated) – only these extensions will be processed
    $allowedfiletypes = $CONFIG_OBJECT.FILE_EXT -split ',\s*'
    # Keep only files whose extension is in the allowed list
    $items = Get-ChildItem -LiteralPath $SourceDirectory -Recurse -File "*"
    $items = $items | Where-Object { $allowedfiletypes -contains $_.Extension }

    # Volume processing flag – set by –volumeflag switch (default $false) 

    # used to block off the processing for the two and three digit chapter files
    $twoPProcFlag = $true
    $threePProcFlag = $true

    # Flags to track completion of processing
    $twoDone = $false
    $threeDone = $false

    # Volume tracking (from config, can be overridden)
    $volumeNumber = $CONFIG_OBJECT.volumeNumber
    $chapterTracker = $CONFIG_OBJECT.chapterTracker
    $volumeChapterMax = $CONFIG_OBJECT.volumeChapterMax

    # Tracking variables
    $totalFiles = $items.Count
    $successCount = 0
    $failedCount = 0
    $failedFiles = @()

    $SPACE=" " 
    $fileType = '.cbz'

    if ($twoPProcFlag -eq $true) {
      # find chapter numbers various chapter formats with 2 digits
      # ie. chapter 00, chapter00, ch00, ch 00, c00, c 00
      $rx2pattern = "(?<=chapter\s)\d{1,2}\b\.\d|(?<=Chapter\s)\d{1,2}\b|(?<=ch\s)\d{1,2}\b\.\d|(?<=ch\s)\d{1,2}\b|(?<=c\s)\d{1,2}\b\.\d|(?<=c\s)\d{1,2}\b|(?<=chap\s)\d{1,2}\b\.\d\b|(?<=chap\s)\d{1,2}\b"

      $badItems = Get-ChildItem -LiteralPath $SourceDirectory -Recurse -Include "*.cbz"
      # write-host "badItems count == $($badItems.Count)" -ForegroundColor Yellow
      # write-host "badItems  == $badItems" -ForegroundColor Yellow
      $badItems  | 
        Where-Object { $_.BaseName -imatch $rx2pattern} | 
          ForEach-Object {
            $matchvalue = $Matches[0].TrimStart() # remove leading space if exists 
            $bad02filename = $_ 
            $matchlength=$matchvalue.length
            # write-host "filename $_"
            if ($debugv) {write-host "DEBUG MODE - BEFORE :::matchvalue $matchvalue ::: matchlength $matchlength ::: Bad filename with 2 digits :: $bad02filename" -ForegroundColor Magenta}
            $padChNumber = if ($matchvalue.Length -lt 3 -and $matchvalue -notlike "*.*"){$matchvalue.PadLeft(3, '0')} # captures 1, 03  > 001, 003
                           elseif ($matchvalue.Length -ge 3 -and $matchvalue.Contains(".")){([string]$matchvalue).PadLeft(5,'0')} #captures 02.1 , 22.1 > 002.1, 022.1
            # $cleanName = $_.BaseName -replace $rx2pattern, $matchvalue.PadLeft(3,'0') #$newPrefix # .Substring(1)  use to remove leading zero
            $chapterString = "Chapter $padChNumber"
            $newName = "$dirName - $chapterString$fileType"

            if ($debugv) {write-host "DEBUG MODE - AFTER :::::::::::: Renaming file to $newName" -ForegroundColor green}
            else {
                if ($whatIf) {
                    Write-Host "[WhatIf] Would rename file $($_.Name) to $newName" -ForegroundColor Gray
                    $successCount++
                }
                else {
                    if (-not (Test-Path $newName)) {
                        Rename-Item -Path $_.FullName -NewName $newName
                        $successCount++
                    }
                    else {
                        $failedCount++
                        $failedFiles += $_.FullName
                        Write-Host "SKIP (exists): $($_.Name)" -ForegroundColor Yellow
                    }
                }
            }
          }
        $twoDone = $true
        Write-host "End of 2 Digit Chapter name update... twoPProcFlag = $twoPProcFlag" -ForegroundColor Cyan    
    }

    if ( $twoDone -eq $true -and $threePProcFlag -eq $true) {
      # find chapter numbers various chapter formats with 3 digits following and (deciaml or not)
      # ie. chapter 000, chapter000, ch000, ch 000, c000, c 000
      $rx3pattern = "(?<=chapter\s)\d{3}[\.]\d{1}|(?<=chapter\s)\d{3}|(?<=chapter)\s+\d{3}[\.]\d{1}|(?<=chapter\s)\d{3}|(?<=ch\s)\d{3}[\.]\d{1}|(?<=ch\s)\d{3}\b|(?<=ch\.\s)\d{3}[\.]\d{1}|(?<=ch\.\s)\d{3}\b|(?<=c\s)\d{3}[\.]\d{1}|(?<=c\s)\d{3}\b|(?<=ch\.)\d{3}[\.]\d{1}|(?<=ch\.)\d{3}\b|(?<=chap\s)\d{3}[\.]\d{1}|(?<=chap\s)\d{3}\b"
      $badItems = Get-ChildItem -LiteralPath $SourceDirectory -Recurse -Include "*.cbz"
      $badItems  |  
        Where-Object { $_.BaseName -imatch $rx3pattern} | 
          ForEach-Object {
            $matchValue = $Matches[0].TrimStart() # remove leading space if exists
            if ($debugv) {write-host "regex matched filename:: $_"}
            $bad03BaseName = $_.BaseName
            $matchlength=$matchvalue.length 
            if ($debugv) {write-host "BEFORE :::match length $matchlength::: Bad filename with 3 digits ::: $bad03BaseName" -ForegroundColor red}
            # $cleanName = $_.BaseName -replace $rx3pattern, $matchvalue.PadLeft(3,'0') #$newPrefix # .Substring(1)  use to remove leading zero
            $chapterString = "Chapter $matchValue" 
            if ($debugv) {write-host "threeProc chapter match ::: matchvalue: $matchValue chapterstring: $chapterString" }
            
            $newName = "$dirName - $chapterString$fileType"
            
            if ($debugv -eq $true) {write-host "DEBUG MODE - AFTER :::::: Renaming file to $newName" -ForegroundColor green}
            else {
                if ($whatIf) {
                    Write-Host "[WhatIf] Would rename file $($_.Name) to $newName" -ForegroundColor Gray
                    $successCount++
                }
                else {
                    if (-not (Test-Path $newName)) {
                        Rename-Item -Path $_.FullName -NewName $newName
                        $successCount++
                    }
                    else {
                        $failedCount++
                        $failedFiles += $_.FullName
                        Write-Host "SKIP (exists): $($_.Name)" -ForegroundColor Yellow
                    }
                }
            }
          }
        $threeDone = $true
        if ($debugv) {Write-host "!!!!DEBUG MODE ENABLED!!!! End of 3 Digit Chapter name update... threePProcFlag = $threePProcFlag" -ForegroundColor Cyan}
      else {Write-host "End of 3 Digit Chapter name update... threePProcFlag = $threePProcFlag" -ForegroundColor Green}
    }

    # Start volume assignment process when twoPProcFlag AND threePProcFlag is completed(true)
    if ($volumeflag -and $twoDone -eq $true -and $threeDone -eq $true) {
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
            if ($debugv) {write-host "chapterNumber found == $chapterNumber" -ForegroundColor green}
            $volprefix ="Vol $paddVolNumber"
            $chprefix="Ch $chapterNumber"
# build final name ie. Manga Vol 01 Ch 001.cbz | Manga Vol 08 Ch 080.cbz 
            if ($volumeflag) {
                $newFileName = "$dirName $volprefix $chprefix$fileType"
            }
            else {
                $newFileName = "$dirName $chprefix$fileType"
            }

            if ($debugv) {write-host "newfilename == $newFileName" -ForegroundColor Cyan}
            else {
                if ($whatIf) {
                    Write-Host "[WhatIf] Would rename file to $newFileName" -ForegroundColor Gray
                    $successCount++
                }
                else {
                    if (-not (Test-Path $newFileName)) {
                        Rename-Item -Path $_.FullName -NewName $newFileName
                        $successCount++
                    }
                    else {
                        $failedCount++
                        $failedFiles += $_.FullName
                        Write-Host "SKIP (exists): $($_.Name)" -ForegroundColor Yellow
                    }
                }
            }
          }
      if ($debugv) {Write-host "!!!!DEBUG!!! End of Volume Chapter Assignment!!!" -ForegroundColor Cyan}
      else {Write-host "End of Volume Chapter Assignment!!!" -ForegroundColor Green}
    }

    # Summary output per target directory
    Write-Host "---" -ForegroundColor Cyan
    Write-Host "Target: $targetDir — Source: $dirName" -ForegroundColor Cyan
    Write-Host "Total $fileType files found: $totalFiles" -ForegroundColor Cyan
    Write-Host "Successfully renamed: $successCount" -ForegroundColor Green
    Write-Host "Failed to rename: $failedCount" -ForegroundColor Red
    if ($failedFiles.Count -gt 0) {
        Write-Host "Failed files:" -ForegroundColor Red
        $failedFiles | ForEach-Object { Write-Host "  $_" }
    }
}