@echo off
REM - File: reports-export.bat
REM - Description: Export POSitive reports for backup/versioning purposes
REM - Author: Tommy Goode
REM - Copyright 2014 International Restaurant Distributors, Inc.

: Setup
call ..\util\loadconfig.bat
set "pwd=%~dp0"
set "reports_dir=%pwd%reports"
if not exist "%reports_dir%\" mkdir "%reports_dir%"
del /Q "%reports_dir%\*"

echo about to save reports to %reports_dir%
: pull the reports out, save into the reports_dir folder
call ..\util\sqlcmdwrapper.bat -d %positive_db% -i reports-export.sql -h -1 -W -v PWD_DIR="%pwd%" REPORTS_DIR="%reports_dir%"


: if not exist "%tmppng%" echo Couldn't extract AQ image && exit /b
