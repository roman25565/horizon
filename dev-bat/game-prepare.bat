@echo off
rem One-time (and after a Minecraft update): build game resources from YOUR copy of Java Edition 26.3.
rem Needs JDK 25, and 26.3 played once in the official launcher.
rem Server jar: first argument, or HORIZON_SERVER_JAR in local.bat.
setlocal
call "%~dp0_env.bat" || goto :fail
if not "%~1"=="" set "HORIZON_SERVER_JAR=%~1"
if not defined HORIZON_SERVER_JAR (
  echo [error] give the 26.3 server jar: game-prepare.bat C:\path\server.jar
  goto :fail
)
pushd "%HZ_ROOT%"
cargo run --release -p horizon-prepare -- --prepare --server-jar "%HORIZON_SERVER_JAR%" || (popd & goto :fail)
cargo run --release -p horizon-prepare -- sounds
popd
echo [ok] resources prepared in %HZ_ROOT%\.local
pause
exit /b 0
:fail
pause
exit /b 1
