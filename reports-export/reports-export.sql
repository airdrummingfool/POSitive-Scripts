/*
 * Exports all POSitive reports into $(REPORTS_DIR)
 *
 * @author: Tommy Goode
 * @copyright: 2015 International Restaurant Distributors, Inc.
 *
 */

SET NOCOUNT ON;

-- To allow advanced options to be changed.
EXEC sp_configure 'show advanced options', 1;
GO
-- To update the currently configured value for advanced options.
RECONFIGURE;
GO
-- To enable the feature.
EXEC sp_configure 'xp_cmdshell', 1;
GO
-- To update the currently configured value for this feature.
RECONFIGURE;
GO

DECLARE @reportID int;
DECLARE @reportName VARCHAR(50)
DECLARE @command VARCHAR(2000)

DECLARE report_cursor CURSOR FOR
  SELECT BID_PrimaryID, rtrim(BID_Filename) FROM BINDOC

OPEN report_cursor

FETCH NEXT FROM report_cursor INTO @reportID, @reportName

WHILE @@FETCH_STATUS = 0
BEGIN
  SET @command = 'bcp "SELECT TOP 1 BID_Picture from [' + (SELECT DB_NAME()) + '].dbo.BINDOC WHERE BID_PrimaryID = ' + cast(@reportID AS VARCHAR(32))
  SET @command = @command + '" QUERYOUT "$(REPORTS_DIR)\' + @reportName + '.mrt" -S ' + convert(varchar(20), (SELECT SERVERPROPERTY('ServerName'))) + ' -T -f "$(WD_DIR)\bcp.fmt" -a 50000'
  SET @command = @command + ' >NUL'
  EXEC master.dbo.xp_cmdshell @command
  FETCH NEXT FROM report_cursor INTO @reportID, @reportName
END

CLOSE report_cursor
DEALLOCATE report_cursor

GO

-- To disable the feature and disallow changing of advanced options
EXEC sp_configure 'xp_cmdshell', 0;
EXEC sp_configure 'show advanced options', 0;
-- To update the currently configured value for this feature.
RECONFIGURE;
GO
