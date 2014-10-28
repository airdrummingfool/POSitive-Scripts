@echo off
REM - File: update-aq-sku.bat
REM - Description: Runs a SQL script that updates the set AQ SKU
REM - Author: Tommy Goode

call util\loadconfig.bat
set DB=%positive_db%

: Enter Primary SKU of item
set PrimarySKU=null
set /p PrimarySKU="Enter Primary SKU of item: "
echo.

set INVNO=null
for /f "delims=" %%a in ('call util\sqlcmdwrapper.bat -d %DB% -i update-aq-sku\primarysku-to-invno.sql -h -1 -W') do @set INVNO=%%a
if "%INVNO%" == "null" (echo Couldn't find item! && PAUSE && exit /b)

set DESC=null
for /f "delims=" %%a in ('call util\sqlcmdwrapper.bat -d %DB% -i update-aq-sku\invno-to-desc.sql -h -1 -W') do @set DESC=%%a

set CurrentAQSKU=null
for /f "delims=" %%a in ('call util\sqlcmdwrapper.bat -d %DB% -i update-aq-sku\invno-to-aqsku.sql -h -1 -W') do @set CurrentAQSKU=%%a
if "%CurrentAQSKU%" == "null" (set CurrentAQSKU=empty)

set VendorSKU=null
for /f "delims=" %%a in ('call util\sqlcmdwrapper.bat -d %DB% -i update-aq-sku\invno-to-vendorsku.sql -h -1 -W') do @set VendorSKU=%%a
if "%VendorSKU%" == "null" (set VendorSKU=empty)

set VendorID=null
for /f "delims=" %%a in ('call util\sqlcmdwrapper.bat -d %DB% -i update-aq-sku\invno-to-vendorid.sql -h -1 -W') do @set VendorID=%%a
if "%VendorID%" == "null" (set VendorID=empty)

set RecommendedAQSKU=%VendorSKU%@%VendorID%
if "%VendorID%" == "empty" (set RecommendedAQSKU=empty)

echo You are about to update %PrimarySKU%: %DESC% (INVNO is %INVNO%)
echo Current AQ SKU is %CurrentAQSKU%
echo Recommended AQ SKU is %RecommendedAQSKU%
if "%RecommendedAQSKU%" == "empty" (set "RecommendedAQSKU=")

set NewAQSKU=null
set /p NewAQSKU="Enter new AQ SKU (leave empty to use recommended): "
if "%NewAQSKU%" == "null" (echo Using recommended... && set "NewAQSKU=%RecommendedAQSKU%")

call util\sqlcmdwrapper.bat -d %DB% -i update-aq-sku\update-aq-sku.sql -h -1 -W -v INVNO="%INVNO%" NewAQSKU="%NewAQSKU%"

set UpdatedAQSKU=null
for /f "delims=" %%a in ('call util\sqlcmdwrapper.bat -d %DB% -i update-aq-sku\invno-to-aqsku.sql -h -1 -W') do @set UpdatedAQSKU=%%a
echo Updated AQ SKU is %UpdatedAQSKU%

echo.
PAUSE
