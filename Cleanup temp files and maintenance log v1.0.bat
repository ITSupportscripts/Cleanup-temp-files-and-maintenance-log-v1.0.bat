@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Cleanup temp files and maintenance log v1.0.bat

rem ============================================================
rem  - Per-run logging with retries and summary
rem ============================================================

set "SCRIPT_NAME=Cleanup temp files and maintenance log v1.0.bat"
set "SCRIPT_VERSION=1.0"

rem -----------------------------------------------------------------
rem Logging setup
set "LOG_DIR=C:\IT Maintenance Logs"

for /f "tokens=1-3 delims=/:. " %%a in ("%date% %time%") do (
    rem This block intentionally left minimal; locale-safe timestamp is built below using PowerShell.
)

set "USERNAME_SAFE=%USERNAME%"

rem Build a locale-independent timestamp: YYYY-MM-DD_HHMMSS
for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd_HHmmss'"`) do set "TS=%%T"

set "LOG_FILE=Cleanup_temp_files_and_maintenance_log_v1.0_run_by_username_on_%TS%.log"
set "LOG_PATH=%LOG_DIR%\%LOG_FILE%"

rem Try to create log directory if missing
if not exist "%LOG_DIR%" (
    md "%LOG_DIR%" >nul 2>&1
    if errorlevel 1 (
        echo ERROR: Could not create log folder: "%LOG_DIR%"
        rem Still continue; logging may fail if folder cannot be created.
    )
)

rem Initialize log file (one per run)
call :LOG "------------------------------------------------------------"
call :LOG "Script name: %SCRIPT_NAME%"
call :LOG "Script version: %SCRIPT_VERSION%"
for /f "usebackq delims=" %%S in (`powershell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"`) do set "START_TS=%%S"
call :LOG "Script start time: %START_TS%"
call :LOG "Log location used: %LOG_DIR%"
call :LOG "Log file: %LOG_PATH%"
call :LOG "------------------------------------------------------------"

:MENU
cls
echo =============================================
echo Cleanup temp files and maintenance log MENU
echo Script version: 1.0
echo =============================================
echo.
echo 1. Cleanup temp files
echo 2. Cleanup maintenance logs
echo 3. Open log folder
echo 4. Quit
echo.

set "CHOICE="
set /p "CHOICE=Select an option (1-4): "

if "%CHOICE%"=="1" goto OPT1
if "%CHOICE%"=="2" goto OPT2
if "%CHOICE%"=="3" goto OPT3
if "%CHOICE%"=="4" goto QUIT
goto MENU

:OPT1
call :LOG "MENU OPTION CHOSEN: 1. Cleanup temp files"
call :RESET_COUNTERS
call :CLEAN_TARGET "%USERPROFILE%\AppData\LocalLow\NVIDIA\DXCache"
call :CLEAN_TARGET "%USERPROFILE%\AppData\Local\NVIDIA\DXCache"
call :CLEAN_TARGET "%USERPROFILE%\AppData\Local\Temp"
call :CLEAN_TARGET "C:\Windows\Prefetch"
call :CLEAN_TARGET "C:\Windows\SoftwareDistribution\Download"
call :CLEAN_TARGET "C:\Windows\Temp"
call :SUMMARY
call :PAUSEMENU
goto MENU

:OPT2
call :LOG "MENU OPTION CHOSEN: 2. Cleanup maintenance logs"
call :RESET_COUNTERS
call :CLEAN_TARGET "C:\Windows\Logs\CBS"
call :CLEAN_TARGET "C:\Windows\Logs\DISM"
call :SUMMARY
call :PAUSEMENU
goto MENU

:OPT3
call :LOG "MENU OPTION CHOSEN: 3. Open log folder"
if exist "%LOG_DIR%" (
    start "" explorer.exe "%LOG_DIR%"
) else (
    echo ERROR: Log folder not found: "%LOG_DIR%"
)
goto MENU

:QUIT
call :LOG "MENU OPTION CHOSEN: 4. Quit"
call :LOG "Script end."
endlocal
exit /b 0

rem -----------------------------------------------------------------
rem Subroutines

:RESET_COUNTERS
set /a FILES_ATTEMPTED=0
set /a FILES_DELETED=0
set /a FILES_SKIPPED=0
exit /b 0

:CLEAN_TARGET
set "TARGET=%~1"

if not exist "%TARGET%" (
    call :LOG "SKIPPED (missing folder): %TARGET%"
    exit /b 0
)

rem Delete files first (count only file delete attempts)
for /f "usebackq delims=" %%F in (`dir /a:-d /b /s "%TARGET%\*" 2^>nul`) do (
    set "FP=%%F"
    set /a FILES_ATTEMPTED+=1

    rem Remove read-only/system/hidden attributes if possible (do not count as delete)
    attrib -r -s -h "!FP!" >nul 2>&1

    del /f /q "!FP!" >nul 2>&1
    if errorlevel 1 (
        call :LOG "SKIPPED (delete failed): !FP!"
        set /a FILES_SKIPPED+=1
    ) else (
        call :LOG "DELETED: !FP!"
        set /a FILES_DELETED+=1
    )
)

rem Remove subdirectories (do not count in file counters)
rem Use /ad to get directories only, deepest first via /o:-n is not reliable for depth;
rem we enumerate with dir /s and then remove, letting failures be logged and continuing.
for /f "usebackq delims=" %%D in (`dir /a:d /b /s "%TARGET%\*" 2^>nul`) do (
    set "DP=%%D"
    rem Skip reparse points (junctions/symlinks) to avoid unintended traversal/removal
    fsutil reparsepoint query "!DP!" >nul 2>&1
    if not errorlevel 1 (
        call :LOG "SKIPPED (dir remove failed): !DP!"
    ) else (
        rd /s /q "!DP!" >nul 2>&1
        if errorlevel 1 (
            call :LOG "SKIPPED (dir remove failed): !DP!"
        ) else (
            call :LOG "REMOVED DIR: !DP!"
        )
    )
)

exit /b 0

:SUMMARY
echo.
echo Files attempted: %FILES_ATTEMPTED%
echo Files deleted:   %FILES_DELETED%
echo Files skipped:   %FILES_SKIPPED%
echo.

call :LOG "SUMMARY:"
call :LOG "Files attempted: %FILES_ATTEMPTED%"
call :LOG "Files deleted: %FILES_DELETED%"
call :LOG "Files skipped: %FILES_SKIPPED%"
call :LOG "------------------------------------------------------------"
exit /b 0

:PAUSEMENU
echo Press any key to return to menu
pause >nul
exit /b 0

:LOG
rem Safe logging: if log path is not writable, still allow script to run
set "MSG=%~1"
>>"%LOG_PATH%" echo %MSG% 2>nul

exit /b 0

