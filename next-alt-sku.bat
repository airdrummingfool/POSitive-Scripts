@echo off
REM - File: next-alt-sku.bat
REM - Description: Runs a SQL script that finds the next Alt. SKU for POS ops
REM - Author: Tommy Goode

call sqlcmdwrapper.bat -d IRD_MASTER -i next-alt-sku.sql -h -1 -W

PAUSE
