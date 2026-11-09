@echo off
rem Release build of the launcher, copied to dist\horizon-launcher.exe.
setlocal
call "%~dp0_env.bat" || goto :fail
pushd "%HZ_ROOT%\launcher"
cargo build --release || (popd & goto :fail)
popd
if not exist "%HZ_ROOT%\dist" mkdir "%HZ_ROOT%\dist"
copy /y "%HZ_ROOT%\launcher\target\release\horizon-launcher.exe" "%HZ_ROOT%\dist\" >nul
echo [ok] %HZ_ROOT%\dist\horizon-launcher.exe
pause
exit /b 0
:fail
echo [error] launcher build failed.
pause
exit /b 1
