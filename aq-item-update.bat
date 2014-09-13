@echo off
REM - File: aq-item-update.bat
REM - Description: Runs a SQL script that updates 5Star item info from AQ database
REM - Author: Devin Spikowski
REM - Modified by: Tommy Goode ;)

IF %1.==. GOTO ArgError
IF %2.==. GOTO ArgError

:SQL
echo.
echo Start time: %DATE% %TIME%
echo Executing script, do NOT close this window until complete.
echo ======================================================
sqlcmd -U %1 -P %2 -S IRD2K12\SQL2012 -d AQEXPORT -i %~dp0aq-item-update.sql -o %~dp0results.txt
echo ======================================================
echo End time: %DATE% %TIME%
echo.
echo Script complete. Check %~dp0results.txt for details.
echo.
PAUSE
GOTO End

:ArgError
echo Please provide username and password for the SQL DB.
echo Usage: aq-item-update.bat [username] [password]
PAUSE

:End
