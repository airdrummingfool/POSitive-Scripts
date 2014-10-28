@echo off
REM - File: sqlcmdwrapper.bat
REM - Description: Wrapper for sqlcmd.exe to provide credentials from a local file
REM - Author: Tommy Goode

call loadconfig.bat
sqlcmd -U %username% -P %password% -S %instance% %*
set username=null
set password=null
set instance=null
