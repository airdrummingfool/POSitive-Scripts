/*
 * Updates POSitive 5 Star items with data exported from AutoQuotes
 *
 * @author: Devin Spikowski
 * @modified-by: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

-- Create a temporary table to link POSitive 5 Star inventory numbers to AQ product IDs
use $(autoquotes_db)
IF OBJECT_ID('dbo.AQ5StarLink', 'U') IS NOT NULL DROP TABLE dbo.AQ5StarLink
select productid, bar_invno as invno into AQ5StarLink
from Products inner join $(positive_db).dbo.barcodes
  on rtrim(bar_barcode) = left(rtrim(model) + '@' + rtrim(vendornumber),20) and bar_id = 2
go

-- Begin updating the POSitive 5 Star items
use $(positive_db)

-- First, make sure we've increased UDF size limits (for storing CutsheetLink - this works as long as you don't directly edit the CutsheetLink field in POSitive)
IF (
  (SELECT CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'UDFIELDS' AND COLUMN_NAME = 'UDF_UDFLD1') < 60)
  ALTER TABLE UDFIELDS ALTER COLUMN UDF_UDFLD1 char(60)
go

-- Price Level 1 = List Price
update itprice set itp_price1 = ListPrice
from $(autoquotes_db).dbo.Products inner join $(autoquotes_db).dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join itprice on itp_invno = invno

-- Last Cost = AQ Net
update itmcount set itc_lastcost = NetPrice
from $(autoquotes_db).dbo.Products inner join $(autoquotes_db).dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join itmcount on itc_invno = invno
  left join items on invno = ite_invno
where ite_foodstamps != 1  -- We're using the 'Allow Food Stamps' option as 'Disallow Cost Updates'

-- Vendor Cost = AQ Net
update veninv set vin_cost = NetPrice
from $(autoquotes_db).dbo.Products inner join $(autoquotes_db).dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join veninv on vin_invno = invno
  left join items on invno = ite_invno
where ite_foodstamps != 1  -- We're using the 'Allow Food Stamps' option as 'Disallow Cost Updates'

-- Extended Notes = AQ Spec (Description)
update notes set nts_note = Spec
from $(autoquotes_db).dbo.Products inner join $(autoquotes_db).dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join notes on nts_n_id = invno and nts_type = 'X'
where nts_type = 'X'

-- Weight
update items set ite_weight = [Weight]
from $(autoquotes_db).dbo.Products inner join $(autoquotes_db).dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join items on ite_invno = invno

-- Freight Class (currently includes a fix for the POSitive DB not accepting decimal freight classes)
update items set ite_freightclass =
  case
    when isnumeric(freightclass) = 1 then floor(cast(freightclass as float))
    else ite_freightclass
  end
from $(autoquotes_db).dbo.Products inner join $(autoquotes_db).dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join items on ite_invno = invno

-- UDF Field: Dimensions = HEIGHTxWIDTHxDEPTH
update udfields set udf_udfld1 =
  case
    when ([Height] + [Width] + [Depth]) > 0 then FORMAT([Height], 'G0') + 'x' + FORMAT([Width], 'G0') + 'x' + FORMAT([Depth], 'G0')
    when udf_udfld1 = '0x0x0' then ''
    else udf_udfld1
  end
from $(autoquotes_db).dbo.Products inner join $(autoquotes_db).dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join udfields on udf_invno = invno and udf_uddes1 = 'Dimensions'
where udf_uddes1 = 'Dimensions'

-- UDF Field: CutsheetLink = AQ Custsheet Link
update udfields set udf_udfld1 = CutsheetLink
from $(autoquotes_db).dbo.Products inner join $(autoquotes_db).dbo.AQ5StarLink on AQ5StarLink.productid = Products.productid
  inner join udfields on udf_invno = invno and udf_uddes1 = 'CutsheetLink'
where udf_uddes1 = 'CutsheetLink'
go
