@echo off
rem Build (if changed) and start the game directly, offline, without the launcher.
rem Extra arguments go to the game, e.g.: game-run.bat --name Roman
setlocal
call "%~dp0_env.bat" || goto :fail
pushd "%HZ_ROOT%"
cargo run --release -p horizon-client -- %*
set "RC=%ERRORLEVEL%"
popd
exit /b %RC%
:fail
pause
exit /b 1
