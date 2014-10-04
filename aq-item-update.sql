--
-- Begin POSitive Item Update Script
--

-- Create a temporary table to link POSitive item numbers to AQ product IDs
use aqexport
IF OBJECT_ID('dbo.AQ5starLink', 'U') IS NOT NULL DROP TABLE dbo.AQ5starLink
select productid, bar_invno as invno into AQ5starLink
from products inner join ird_master.dbo.barcodes 
	on bar_barcode = left(rtrim(model) + '@' + rtrim(vendornumber),20) and bar_id = 2
go


use ird_master
-- Price Level 1 = List Price
update itprice set itp_price1 = ListPrice
from aqexport.dbo.products inner join aqexport.dbo.aq5starlink on aq5starlink.productid = products.productid
	inner join itprice on itp_invno = invno

-- Last Cost = AQ Net
update itmcount set itc_lastcost = NetPrice
from aqexport.dbo.products inner join aqexport.dbo.aq5starlink on aq5starlink.productid = products.productid
	inner join itmcount on itc_invno = invno

-- Vendor Cost = AQ Net
update veninv set vin_cost = NetPrice
from aqexport.dbo.products inner join aqexport.dbo.aq5starlink on aq5starlink.productid = products.productid
	inner join veninv on vin_invno = invno

-- Extended Notes = AQ Spec (Description)
update notes set nts_note = Spec
from aqexport.dbo.products inner join aqexport.dbo.aq5starlink on aq5starlink.productid = products.productid
	inner join notes on nts_n_id = invno and nts_type = 'X'
where nts_type = 'X'

-- Weight and Freight Class (currently includes a fix for the POSitive DB not accepting decimal freight classes)
update items set ite_weight = [Weight], ite_freightclass = case when isnumeric(freightclass) = 1 then floor(cast(freightclass as float)) else 0 end
from aqexport.dbo.products inner join aqexport.dbo.aq5starlink on aq5starlink.productid = products.productid
	inner join items on ite_invno = invno

-- UDF Field: Dimensions = HEIGHTxWIDTHxDEPTH
update udfields set udf_udfld1 = FORMAT([Height], 'G0') + 'x' + FORMAT([Width], 'G0') + 'x' + FORMAT([Depth], 'G0')
from aqexport.dbo.products inner join aqexport.dbo.aq5starlink on aq5starlink.productid = products.productid
	inner join udfields on udf_invno = invno and udf_uddes1 = 'Dimensions'
where udf_uddes1 = 'Dimensions'

-- UDF Field: CutsheetLink = AQ Custsheet Link
update udfields set udf_udfld1 = CutsheetLink
from aqexport.dbo.products inner join aqexport.dbo.aq5starlink on aq5starlink.productid = products.productid
	inner join udfields on udf_invno = invno and udf_uddes1 = 'CutsheetLink'
where udf_uddes1 = 'CutsheetLink'
go
