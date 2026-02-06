# Create new folders in destination and move underlying files into the new folder. There was a folder per file, this removes that structure of folder/folder/file to folder/file.
$CONFIG_FILE="C:\myconfig\config.cfg"

# Populate config file
$CONFIG_OBJECT = Get-Content -Path $CONFIG_FILE | ConvertFrom-Json
$SourceFiles="$($CONFIG_OBJECT.SRC_DIRECTORY)"
$TargetPath="$($CONFIG_OBJECT.TGT_DIRECTORY)"

$ListDir=Get-ChildItem -LiteralPath $SourceFiles -Directory 
$ListDir | ForEach-Object {
    $parentFolderName1= $_.name
    # $parentFolderName2=Split-Path -Path $parentFolderName1 -Leaf
    # write-host "parentFolderName1: $parentFolderName1" -ForegroundColor green
    $DestinationFolder="$TargetPath\$parentFolderName1"
    if (-not (Test-Path $DestinationFolder -PathType Container)) {
        New-Item -Path "$DestinationFolder" -ItemType Directory -Force | Out-Null 
        Write-Host "Created destination directory: $DestinationFolder"  -ForegroundColor green
    } else {Write-Host "Destination directory Exists: $DestinationFolder"  -ForegroundColor green}
  Get-ChildItem -LiteralPath $_.FullName -Recurse -File | ForEach-Object {

    # Write-Host "Matched File: $($_.FullName)" -ForegroundColor Green
    Move-Item -Path $_.FullName -Destination $DestinationFolder #-WhatIf  
  };
  }
  ;