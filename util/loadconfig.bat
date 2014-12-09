@echo off
REM - File: loadconfig.bat
REM - Description: Load environment variables from a local file
REM - Author: Tommy Goode

: load username, password, instance, db names from config.ini. Format: key=value
for /F "tokens=*" %%I in (%~dp0..\config.ini) do set %%I
