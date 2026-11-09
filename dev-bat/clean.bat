@echo off
rem Delete build outputs (frees many GB). Does NOT touch .local (prepared resources) or .dev-data.
setlocal
call "%~dp0_env.bat" || goto :fail
choice /m "Delete target folders of the game and the launcher"
if errorlevel 2 exit /b 0
pushd "%HZ_ROOT%" & cargo clean & popd
pushd "%HZ_ROOT%\launcher" & cargo clean & popd
echo [ok] cleaned.
pause
exit /b 0
:fail
pause
exit /b 1
