/*
 * Updates POSitive 5 Star items with data exported from AutoQuotes
 *
 * @author: Devin Spikowski
 * @modified-by: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

-- Create a temporary table to link POSitive 5 Star inventory numbers to AQ product IDs
USE [$(autoquotes_db)]
IF OBJECT_ID('dbo.AQ5StarLink', 'U') IS NOT NULL DROP TABLE dbo.AQ5StarLink
SELECT productid, BAR_INVNO AS invno, BAR_Site AS site
INTO AQ5StarLink
FROM Products INNER JOIN [$(positive_db)].dbo.barcodes
  ON RTRIM(BAR_BARCODE) = LEFT(RTRIM(model) + '@' + RTRIM(vendornumber), 20) AND BAR_ID = 2
GO

-- Begin updating the POSitive 5 Star items
USE [$(positive_db)]

-- Create empty Notes fields for all items that don't have one but have AQ data
DECLARE @max_notes_pid AS int = (SELECT max(NTS_PrimaryID) FROM NOTES)
INSERT INTO NOTES
  SELECT ' ' AS NTS_NOTE, invno as NTS_N_ID, 0 as NTS_ODTE, 0 AS NTS_OTIM, 0 AS NTS_ETIM, '' AS NTS_TICK, '' AS NTS_DESC, 'X' AS NTS_TYPE, '' AS NTS_T_ID, '' AS NTS_CUSTID, '' AS NTS_STATUS, 0 AS NTS_AttachmentType, 0 as NTS_AttachmentID, '' AS NTS_AttachmentFileName, site+'IRD@'+left(REPLACE(newid(), '-', ''), 8) AS NTS_GUID, site as NTS_Site, @max_notes_pid + ROW_NUMBER() over(ORDER BY (SELECT NULL)) AS NTS_PrimaryID, 0 AS NTS_Revision, 0 AS NTS_Invisible
    FROM [$(autoquotes_db)].dbo.AQ5StarLink WHERE invno NOT IN (
      SELECT NTS_N_ID FROM NOTES WHERE NTS_TYPE = 'X'
    )
GO

-- Make sure we've increased UDF size limits (for storing CutsheetLink - this works as long as you don't directly edit the CutsheetLink field in POSitive)
IF (
  SELECT CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'UDFIELDS' AND COLUMN_NAME = 'UDF_UDFLD1'
  ) < 60
  ALTER TABLE UDFIELDS ALTER COLUMN UDF_UDFLD1 char(60)
GO

-- Price Level 1 = List Price
update itprice set itp_price1 = ListPrice
from [$(autoquotes_db)].dbo.Products inner join [$(autoquotes_db)].dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join itprice on itp_invno = invno

-- Last Cost = AQ Net
update itmcount set itc_lastcost = NetPrice
from [$(autoquotes_db)].dbo.Products inner join [$(autoquotes_db)].dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join itmcount on itc_invno = invno
  left join items on invno = ite_invno
where ite_foodstamps != 1  -- We're using the 'Allow Food Stamps' option as 'Disallow Cost Updates'

-- Vendor Cost = AQ Net
update veninv set vin_cost = NetPrice
from [$(autoquotes_db)].dbo.Products inner join [$(autoquotes_db)].dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join veninv on vin_invno = invno
  left join items on invno = ite_invno
where ite_foodstamps != 1  -- We're using the 'Allow Food Stamps' option as 'Disallow Cost Updates'

-- Extended Notes = AQ Spec (Description)
update notes set nts_note = Spec
from [$(autoquotes_db)].dbo.Products inner join [$(autoquotes_db)].dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join notes on nts_n_id = invno and nts_type = 'X'
where nts_type = 'X'

-- Weight
update items set ite_weight = [Weight]
from [$(autoquotes_db)].dbo.Products inner join [$(autoquotes_db)].dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join items on ite_invno = invno

-- Freight Class (currently includes a fix for the POSitive DB not accepting decimal freight classes)
update items set ite_freightclass =
  case
    when isnumeric(freightclass) = 1 then floor(cast(freightclass as float))
    else ite_freightclass
  end
from [$(autoquotes_db)].dbo.Products inner join [$(autoquotes_db)].dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join items on ite_invno = invno

-- UDF Field: Dimensions = HEIGHTxWIDTHxDEPTH
update udfields set udf_udfld1 =
  case
    when ([Height] + [Width] + [Depth]) > 0 then FORMAT([Height], 'G0') + 'x' + FORMAT([Width], 'G0') + 'x' + FORMAT([Depth], 'G0')
    when udf_udfld1 = '0x0x0' then ''
    else udf_udfld1
  end
from [$(autoquotes_db)].dbo.Products inner join [$(autoquotes_db)].dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join udfields on udf_invno = invno and udf_uddes1 = 'Dimensions'
where udf_uddes1 = 'Dimensions'

-- UDF Field: CutsheetLink = AQ Cutsheet Link
update udfields set udf_udfld1 = CutsheetLink
from [$(autoquotes_db)].dbo.Products inner join [$(autoquotes_db)].dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join udfields on udf_invno = invno and udf_uddes1 = 'CutsheetLink'
where udf_uddes1 = 'CutsheetLink'
go
