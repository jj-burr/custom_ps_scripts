# README

## Table of Contents

- [massrename.ps1](#massrenameps1)
- [volume-assignment.ps1](#volume-assignmentps1)
- [cmove_subdirectory.ps1](#cmovesubdirectoryps1)
- [unpack.ps1](#unpackps1)

## Scripts Overview

| Script | Description |
|---|---|
| massrename.ps1 | Renames all files in a directory based on a regex pattern and a new prefix. |
| volume-assignment.ps1 | Assigns volume numbers to chapters and increments the volume number every n chapters. |
| cmove_subdirectory.ps1 | Creates new folders in the destination and moves underlying files, removing the folder‑per‑file structure. |
| unpack.ps1 | Unpacks many cbz/zip/rar files into a single directory, extracting individual chapters. |

---

## massrename.ps1 <a name="massrenameps1"></a>

### Example Command

```powershell
.\massrename.ps1
```

The default prefix is the source directory name (e.g., `On the Way to Meet Mom Chapter 001.cbz`).

### Example with WhatIf

```powershell
.\massrename.ps1 -whatIf
```

### Example with clean chapter prefix

```powershell
.\massrename.ps1 -cleanChapter
```

Uses just `"Chapter "` as the prefix (e.g., `Chapter 001.cbz`) without the directory name.

### Example with DirName prefix (explicit)

```powershell
.\massrename.ps1 -usedirname
```

---

## volume-assignment.ps1 <a name="volume-assignmentps1"></a>

### Example Command

```powershell
.\volume-assignment.ps1
```

### Config Updates Required

The script reads `config.json` for the following settings:

- `SRC_DIRECTORY` – source directory where chapter files reside
- `CBZ_FILE_EXT` – expected file extension (e.g., `.cbz`)

Ensure the config values match your directory structure and file types before execution.

---

## cmove_subdirectory.ps1 <a name="cmovesubdirectoryps1"></a>

### Example Command

```powershell
.\cmove_subdirectory.ps1
```

### Config Updates Required

The script uses `config.cfg` (INI‑style or JSON) expecting:

- `SRC_DIRECTORY` – source folder containing the folder‑per‑file structure
- `TGT_DIRECTORY` – target folder where each folder should be moved into

Populate `config.cfg` with the correct source and target paths before running.

---

## unpack.ps1 <a name="unpackps1"></a>

### Example Command

```powershell
.\unpack.ps1
```

### Config Updates Required

The script relies on `config.cfg` with these keys:

- `SRC_DIRECTORY` – directory containing the cbz/zip/rar files to unpack
- (Optionally other keys such as `DEST_DIRECTORY` if modified)

Update `config.cfg` with the source directory path and any other desired settings before executing.