@echo off
chcp 65001>nul
::set WORKING_DIR=%cd%
::set SCRIPT_DIR=%~dp0
::set AIRDIR=%AIR_HOME%

for /f "tokens=*" %%a in ('where adl.exe') do set ADL_DIR=%%a
for %%a in (%ADL_DIR%) do set AIR_BIN_DIR=%%~dpa
for %%a in (%AIR_BIN_DIR:~0,-1%) do set AIR_DIR=%%~dpa

adl -profile extendedDesktop -nodebug -multi-instance -cmd "%~dp0\apm.xml" -- -workingdir "%cd%" -airdir "%AIR_DIR% " -uname "windows" %*

