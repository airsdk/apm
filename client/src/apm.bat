@echo off
chcp 65001>nul
::set WORKING_DIR=%cd%
::set SCRIPT_DIR=%~dp0
::set AIRDIR=%AIR_HOME%

adl -profile extendedDesktop -nodebug -cmd "%~dp0\apm.xml" -- -workingdir "%cd%" %*

