@echo off
rem Shared settings for all dev scripts. Called by the other .bat files.
rem Repo root = the folder above this one.
for %%I in ("%~dp0..") do set "HZ_ROOT=%%~fI"

rem Separate data folders so dev runs never touch your real install.
if not defined HZ_DEV_DIR set "HZ_DEV_DIR=%HZ_ROOT%\.dev-data"
set "HORIZON_LAUNCHER_HOME=%HZ_DEV_DIR%\launcher"
set "HORIZON_HOME=%HZ_DEV_DIR%\game"

rem Personal settings (client ID, server jar path) live in local.bat, which you create yourself.
rem Example local.bat:
rem   set "HORIZON_MSA_CLIENT_ID=00000000-0000-0000-0000-000000000000"
rem   set "HORIZON_SERVER_JAR=F:\MinecraftTools\server-26.3.jar"
if exist "%~dp0local.bat" call "%~dp0local.bat"

where cargo >nul 2>nul || (
  echo [error] cargo not found. Install Rust from https://rustup.rs and reopen the terminal.
  exit /b 1
)
exit /b 0
