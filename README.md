# Cleanup temp files and maintenance log v1.0.bat

## Overview

**Cleanup temp files and maintenance log v1.0.bat** is a Windows Batch (`.bat`) script designed to perform routine system maintenance by safely cleaning temporary files and selected Windows maintenance log directories.
The script includes structured logging, user interaction via a menu-driven interface, and safeguards to avoid unintended deletions.

This script is intended for **IT administrators, support technicians, and advanced users** performing local system maintenance on Windows devices.

---

## Features

* Menu-driven interface for ease of use
* Cleans common Windows and application temporary directories
* Cleans Windows maintenance logs (CBS and DISM)
* Per-run log file with timestamp
* Locale-independent timestamps
* File-level delete tracking (attempted, deleted, skipped)
* Safe handling of:

  * Missing directories
  * Locked files
  * Read-only, system, and hidden files
  * Reparse points (junctions/symlinks)

---

## Script Information

| Property          | Value                                           |
| ----------------- | ----------------------------------------------- |
| Script Name       | Cleanup temp files and maintenance log v1.0.bat |
| Version           | 1.0                                             |
| Script Type       | Windows Batch Script                            |
| Execution Context | Local user or elevated administrator            |
| Logging           | Enabled (per execution)                         |

---

## Requirements

* Windows 10 or later
* Command Prompt (`cmd.exe`)
* PowerShell available in system PATH (used for timestamp generation)
* NTFS file system
* Recommended: Run as **Administrator** for full cleanup capability

---

## Folder and File Locations

### Log Folder

```
C:\IT Maintenance Logs
```

### Log File Naming Convention

```
Cleanup_temp_files_and_maintenance_log_v1.0_run_by_username_on_YYYY-MM-DD_HHMMSS.log
```

Each execution creates a **new log file**, ensuring historical runs are preserved.

---

## Menu Options

### 1. Cleanup Temp Files

Cleans the following directories (if present):

* `%USERPROFILE%\AppData\LocalLow\NVIDIA\DXCache`
* `%USERPROFILE%\AppData\Local\NVIDIA\DXCache`
* `%USERPROFILE%\AppData\Local\Temp`
* `C:\Windows\Prefetch`
* `C:\Windows\SoftwareDistribution\Download`
* `C:\Windows\Temp`

### 2. Cleanup Maintenance Logs

Cleans the following Windows log directories:

* `C:\Windows\Logs\CBS`
* `C:\Windows\Logs\DISM`

### 3. Open Log Folder

Opens the log directory in Windows Explorer.

### 4. Quit

Gracefully exits the script and finalizes logging.

---

## Logging Behavior

* Logs are written throughout execution
* Script continues running even if logging fails
* Each deletion attempt is logged as:

  * `DELETED`
  * `SKIPPED (delete failed)`
  * `SKIPPED (missing folder)`
* Directory removals are logged separately
* A summary section is written after each cleanup operation

---

## Safety and Design Considerations

* Does **not** delete user documents or system-critical folders
* Reparse points (junctions and symbolic links) are detected and skipped
* Directory deletions occur only after files are processed
* Read-only, system, and hidden attributes are removed **only** to allow deletion
* Script does not terminate on individual errors

---

## Running the Script

1. Copy the `.bat` file to a local machine
2. Right-click the file
3. Select **Run as administrator** (recommended)
4. Choose an option from the menu

---

## Customization

You may safely modify:

* `LOG_DIR` to change log storage location
* Cleanup target paths under `:OPT1` and `:OPT2`
* Script name and version variables

**Do not modify** delayed expansion or logging subroutines unless you understand batch scripting behavior.

---

## Known Limitations

* Locked files may be skipped
* Some Windows folders require elevation
* PowerShell must be available for timestamp creation
* Batch scripting does not provide transactional rollback

---

## Support and Maintenance

This script is provided **as-is** and is suitable for internal IT use.
Test modifications in a non-production environment before deployment.

---

## Version History

### v1.0

* Initial release
* Menu-driven cleanup
* Structured logging
* File-level counters and summary reporting

---


---

License
MIT License

Copyright (c) 2025 Max Timmers
Contact email: maxtimmers@live.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

## Maintainers

- Owner: Max Timmers
- Contact: maxtimmers@live.com
- Last Updated: 19-DEC-2025
