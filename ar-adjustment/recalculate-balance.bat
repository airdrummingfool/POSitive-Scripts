@echo off
REM - File: recalculate-balance.bat
REM - Description: Makes it easy to recalculate the balance of any AR transaction in 5 Star.
REM - Author: Tommy Goode

: Setup
: call util\loadconfig.bat

: Input
set TNum=
set /P TNum=Enter the Transaction ID:

: Confirmation
set CusCode=null
for /f "delims=" %%a in ('call util\sqlcmdwrapper.bat -d %DB% -i %~dp0tnum-to-cuscode.sql -h -1 -W') do @set CusCode=%%a

set Balance=null
for /f "delims=" %%a in ('call util\sqlcmdwrapper.bat -d %DB% -i %~dp0tnum-to-balance.sql -h -1 -W') do @set Balance=%%a

echo Transaction ID %TNum%, which has a balance of $%Balance% and belongs to %CusCode%. Is that correct?
set /P Confirmation=(Y/N)

if /I NOT '%Confirmation%'=='Y' goto Input

: SQL
call util\sqlcmdwrapper.bat -d %DB% -i %~dp0recalculate-balance.sql -h -1 -W 2>&1

: Conclusion
set NewBalance=null
for /f "delims=" %%a in ('call util\sqlcmdwrapper.bat -d %DB% -i %~dp0tnum-to-balance.sql -h -1 -W') do @set NewBalance=%%a
echo New balance for transaction %TNum% is $%NewBalance%.

pause
