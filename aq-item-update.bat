@echo off
REM - File: aq-item-update.bat
REM - Description: Runs a SQL script that updates 5Star item info from AQ database
REM - Author: Devin Spikowski
echo Executing script, do NOT close this window until complete.
echo ======================================================
sqlcmd -U [username] -P [password] -S IRD2K12\SQL2012 -d AQEXPORT -i C:\AQitemUpdate\aq-item-update.sql -o C:\AQitemUpdate\results.txt
echo ======================================================
echo.
echo Script complete. Check C:\AQitemUpdate\results.txt for details.
echo.
PAUSE