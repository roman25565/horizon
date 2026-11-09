@echo off
rem Starts the auth mock in its own window, then the launcher (DEBUG build) pointed at it.
rem Needs the HORIZON_MOCK_AUTH patch in Endpoints::live() (see README).
rem Extra arguments go to the mock, e.g.: launcher-run-mock.bat --name Roman --no-own
setlocal
call "%~dp0_env.bat" || goto :fail
set "HZ_DEV_DIR=%HZ_ROOT%\.dev-data-mock"
set "HORIZON_LAUNCHER_HOME=%HZ_DEV_DIR%\launcher"
set "HORIZON_HOME=%HZ_DEV_DIR%\game"
set "HORIZON_MOCK_AUTH=http://127.0.0.1:8765"
set "HORIZON_MSA_CLIENT_ID=mock-client"
start "auth mock" python "%~dp0mock_ms.py" --port 8765 %*
pushd "%HZ_ROOT%\launcher"
cargo run
set "RC=%ERRORLEVEL%"
popd
exit /b %RC%
:fail
pause
exit /b 1
