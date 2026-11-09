@echo off
rem Build (if changed) and start the launcher with the dev data folders.
setlocal
call "%~dp0_env.bat" || goto :fail
if not defined HORIZON_MSA_CLIENT_ID echo [note] HORIZON_MSA_CLIENT_ID is not set: the UI works, Play will refuse.
pushd "%HZ_ROOT%\launcher"
cargo run --release -- %*
set "RC=%ERRORLEVEL%"
popd
exit /b %RC%
:fail
pause
exit /b 1
