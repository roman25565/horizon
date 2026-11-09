@echo off
rem Release build of the game, copied to dist\horizon-client.exe.
setlocal
call "%~dp0_env.bat" || goto :fail
pushd "%HZ_ROOT%"
cargo build --release -p horizon-client || (popd & goto :fail)
popd
if not exist "%HZ_ROOT%\dist" mkdir "%HZ_ROOT%\dist"
copy /y "%HZ_ROOT%\target\release\horizon-client.exe" "%HZ_ROOT%\dist\" >nul
echo [ok] %HZ_ROOT%\dist\horizon-client.exe
pause
exit /b 0
:fail
echo [error] game build failed.
pause
exit /b 1
