@echo off
REM - File: aq-sku-update.bat
REM - Description: Runs a SQL script that updates 5 Star item AQ SKUs based on the AQ export db
REM - Author: Tommy Goode

: Setup
call util\loadconfig.bat
set start_time=%DATE% %TIME%
set results_file=%~dp0aq-sku-update\last_run.log
set log_file=%~dp0aq-sku-update\log.log
del %results_file%

:SQL
echo.
echo Start time: %start_time%
echo Executing script, do NOT close this window until complete.
echo ======================================================
call util\sqlcmdwrapper.bat -d %positive_db% -i aq-sku-update\aq-sku-update.sql -h -1 -W >> %results_file% 2>&1
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
