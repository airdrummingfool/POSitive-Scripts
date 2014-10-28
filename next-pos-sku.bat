@echo off
REM - File: next-pos-sku.bat
REM - Description: Runs a SQL script that finds the next POS SKU (next sequential numeric Alt. SKU)
REM - Author: Tommy Goode

call util\loadconfig.bat
call util\sqlcmdwrapper.bat -d %positive_db% -i next-pos-sku\next-pos-sku.sql -h -1 -W

PAUSE
