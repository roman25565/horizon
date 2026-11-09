@echo off
rem Fast check after editing launcher code: compile check, then unit tests.
setlocal
call "%~dp0_env.bat" || goto :fail
pushd "%HZ_ROOT%\launcher"
cargo check || (popd & goto :fail)
cargo test --lib || (popd & goto :fail)
popd
echo [ok] launcher compiles and tests pass.
pause
exit /b 0
:fail
echo [error] see the output above.
pause
exit /b 1
