@echo off
REM - File: sqlcmdwrapper.bat
REM - Description: Wrapper for sqlcmd.exe to provide credentials from a local file
REM - Author: Tommy Goode

: load username, password, instance from config.ini. Format: key=value
for /F "tokens=*" %%I in (config.ini) do set %%I

sqlcmd -U %username% -P %password% -S %instance% %*
