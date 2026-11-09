@echo off
rem The project's own pre-PR self-check: rustfmt, clippy, tests of touched crates, Python tests.
setlocal
call "%~dp0_env.bat" || goto :fail
pushd "%HZ_ROOT%"
python tools\pr_ready.py %*
set "RC=%ERRORLEVEL%"
popd
pause
exit /b %RC%
:fail
pause
exit /b 1
