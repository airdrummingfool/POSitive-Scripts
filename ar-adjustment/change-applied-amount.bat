@echo off
REM - File: change-applied-amount.bat
REM - Description: Makes it easy to change the amout of an applied payment in 5 Star.
REM - Author: Tommy Goode

: Setup
: call util\loadconfig.bat

: Input
set PaymentTNum=
set /P PaymentTNum=Enter the Payment ID:
set ChargeTNum=
set /P ChargeTNum=Enter the Charge ID the payment is currently applied to:
set NewPaymentAmount=
set /P NewPaymentAmount=Enter the amount of payment that should be applied:

: Confirmation
set CusCode=null
for /f "delims=" %%a in ('"call util\sqlcmdwrapper.bat -d %DB% -i %~dp0tnum-to-cuscode.sql -h -1 -W -v TNum=%PaymentTNum%"') do @set CusCode=%%a

set OldPaymentAmount=null
for /f "delims=" %%a in ('"call util\sqlcmdwrapper.bat -d %DB% -i %~dp0paymenttnum-chargetnum-to-applied-amount.sql -h -1 -W"') do @set OldPaymentAmount=%%a

echo "You want to change the amount applied of %CusCode%'s payment %PaymentTNum% to %ChargeTNum%, from $%OldPaymentAmount% to $%NewPaymentAmount%. Is that correct?"
set /P Confirmation=(Y/N)

if /I NOT '%Confirmation%'=='Y' goto Input

: SQL
call util\sqlcmdwrapper.bat -d %DB% -i %~dp0change-applied-amount.sql -h -1 -W 2>&1

: Conclusion
set ChargeNewBalance=null
for /f "delims=" %%a in ('"call util\sqlcmdwrapper.bat -d %DB% -i %~dp0tnum-to-balance.sql -h -1 -W -v TNum=%ChargeTNum%"') do @set ChargeNewBalance=%%a
echo New balance for charge %ChargeTNum% is $%ChargeNewBalance%.

pause
