@echo off
setlocal

set "ROOT=%~dp0"
set "BUILD_DIR=%ROOT%.build"
set "STAGE_DIR=%ROOT%.build.tmp"

if not defined AHK2EXE if exist "%ProgramFiles%\AutoHotkey\Compiler\Ahk2Exe.exe" set "AHK2EXE=%ProgramFiles%\AutoHotkey\Compiler\Ahk2Exe.exe"
if not defined AHK2EXE if exist "%ProgramFiles%\AutoHotkey\current\App\Compiler\Ahk2Exe.exe" set "AHK2EXE=%ProgramFiles%\AutoHotkey\current\App\Compiler\Ahk2Exe.exe"
if not defined AHK2EXE if exist "%ProgramFiles%\AutoHotkey\v2\Compiler\Ahk2Exe.exe" set "AHK2EXE=%ProgramFiles%\AutoHotkey\v2\Compiler\Ahk2Exe.exe"

if not defined AHK2EXE (
    for /f "delims=" %%I in ('where.exe Ahk2Exe.exe 2^>nul') do if not defined AHK2EXE set "AHK2EXE=%%I"
)

if not defined AHK2EXE goto :no_compiler
if not exist "%AHK2EXE%" goto :compiler_missing
if not exist "%ROOT%layout.ahk" goto :missing_input
if not exist "%ROOT%run-layout.ahk" goto :missing_input
if not exist "%ROOT%config.ini" goto :missing_input
if not exist "%ROOT%run-layout.ps1" goto :missing_input
if not exist "%ROOT%config\layouts" goto :missing_input
if not exist "%ROOT%config\maps" goto :missing_input
if not exist "%ROOT%icons" goto :missing_input

if exist "%STAGE_DIR%" rmdir /s /q "%STAGE_DIR%"
if exist "%STAGE_DIR%" goto :build_dir_error
mkdir "%STAGE_DIR%"
if errorlevel 1 goto :build_dir_error

if defined AHK_BASE (
    "%AHK2EXE%" /in "%ROOT%layout.ahk" /out "%STAGE_DIR%\layout.exe" /base "%AHK_BASE%"
) else (
    "%AHK2EXE%" /in "%ROOT%layout.ahk" /out "%STAGE_DIR%\layout.exe"
)
if errorlevel 1 goto :compile_error

if defined AHK_BASE (
    "%AHK2EXE%" /in "%ROOT%run-layout.ahk" /out "%STAGE_DIR%\run-layout.exe" /base "%AHK_BASE%"
) else (
    "%AHK2EXE%" /in "%ROOT%run-layout.ahk" /out "%STAGE_DIR%\run-layout.exe"
)
if errorlevel 1 goto :compile_error

copy /Y "%ROOT%config.ini" "%STAGE_DIR%\config.ini" >nul
if errorlevel 1 goto :copy_error
copy /Y "%ROOT%run-layout.ps1" "%STAGE_DIR%\run-layout.ps1" >nul
if errorlevel 1 goto :copy_error
xcopy /E /I /Y "%ROOT%config" "%STAGE_DIR%\config" >nul
if errorlevel 1 goto :copy_error
xcopy /E /I /Y "%ROOT%icons" "%STAGE_DIR%\icons" >nul
if errorlevel 1 goto :copy_error

if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
if exist "%BUILD_DIR%" goto :build_dir_error
move "%STAGE_DIR%" "%BUILD_DIR%" >nul
if errorlevel 1 goto :build_dir_error

echo Build complete: "%BUILD_DIR%"
exit /b 0

:no_compiler
echo AutoHotkey v2 Ahk2Exe was not found.
echo Install the AutoHotkey v2 compiler, put Ahk2Exe.exe on PATH, or set AHK2EXE to its full path.
exit /b 1

:compiler_missing
echo Ahk2Exe was not found at "%AHK2EXE%".
exit /b 1

:missing_input
echo A required project input is missing. Run build.cmd from the repository without moving project files.
exit /b 1

:build_dir_error
if exist "%STAGE_DIR%" rmdir /s /q "%STAGE_DIR%"
echo Could not prepare build output directory: "%BUILD_DIR%"
exit /b 1

:compile_error
if exist "%STAGE_DIR%" rmdir /s /q "%STAGE_DIR%"
echo Ahk2Exe failed. Verify that AHK2EXE points to the AutoHotkey v2 compiler and, if needed, set AHK_BASE to its v2 base file.
exit /b 1

:copy_error
if exist "%STAGE_DIR%" rmdir /s /q "%STAGE_DIR%"
echo Failed to copy redistributable runtime files into "%BUILD_DIR%".
exit /b 1