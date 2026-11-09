@echo off
rem Build the game and the launcher, then import your game build into the DEV launcher
rem (as an unsigned "imported-..." version). Then start launcher-run.bat and pick it in Versions.
setlocal
call "%~dp0_env.bat" || goto :fail
pushd "%HZ_ROOT%"
cargo build --release -p horizon-client || (popd & goto :fail)
popd
pushd "%HZ_ROOT%\launcher"
cargo build --release || (popd & goto :fail)
popd
"%HZ_ROOT%\launcher\target\release\horizon-launcher.exe" import-build "%HZ_ROOT%\target\release\horizon-client.exe" --trust-unsigned || goto :fail
echo [ok] imported. Run launcher-run.bat and select the imported version.
pause
exit /b 0
:fail
echo [error] see the output above.
pause
exit /b 1
