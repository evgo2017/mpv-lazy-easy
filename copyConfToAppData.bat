@echo off
setlocal

:: Define the destination directory
set "DEST=%APPDATA%\mpv"

echo ==========================================
echo Copying MPV Configuration...
echo Source: %~dp0
echo Destination: %DEST%
echo ==========================================
echo.

:: Create destination directory if it doesn't exist
if not exist "%DEST%" mkdir "%DEST%"

:: Copy Configuration Files from AppData folder
echo Copying configuration files from AppData...
if exist "%~dp0AppData" (
    xcopy /s /y "%~dp0AppData\*" "%DEST%\"
) else (
    echo Warning: AppData folder not found.
)

echo.
echo ==========================================
echo Copy Configuration Complete!
echo You can now start MPV.
echo ==========================================
pause
endlocal
