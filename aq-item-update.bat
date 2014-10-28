@echo off
REM - File: aq-item-update.bat
REM - Description: Runs a SQL script that updates 5Star item info from AQ database
REM - Original Author: Devin Spikowski
REM - Modified by: Tommy Goode

: Setup
set start_time=%DATE% %TIME%
set results_file=%~dp0aq-item-update\last_run.log
set log_file=%~dp0aq-item-update\log.log

:SQL
echo.
echo Start time: %start_time%
echo Executing script, do NOT close this window until complete.
echo ======================================================
call sqlcmdwrapper.bat -i %~dp0aq-item-update\aq-item-update.sql -o %results_file%
echo ======================================================
echo End time:   %DATE% %TIME%
echo.

:Reporting
echo Run date: %start_time%>>%log_file%
type %results_file%>>%log_file%
echo ------------------------------------------->>%log_file%
echo Script complete. Check %results_file% for details.
echo.

:End
PAUSE
