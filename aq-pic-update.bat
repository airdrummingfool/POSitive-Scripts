@echo off
REM - File: aq-pics-update.bat
REM - Description: Runs a SQL script that updates 5 Star item pictures from AQ database
REM - Author: Tommy Goode

: Setup
call util\loadconfig.bat
set start_time=%DATE% %TIME%
set results_file=%~dp0aq-pic-update\last_run.log
set log_file=%~dp0aq-pic-update\log.log
del %results_file%

:SQL
echo.
echo Start time: %start_time%
echo Executing script, do NOT close this window until complete.
echo ======================================================
for /f "delims=" %%a in ('call util\sqlcmdwrapper.bat -d %autoquotes_db% -i aq-pic-update\invnos-needing-pic-update.sql -h -1 -W') do (
		call aq-pic-update\update-invno-aq-pic.bat %%a
	) >> %results_file% 2>&1
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
