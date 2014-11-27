/*
 * Fix AQ SKUs in bulk
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

-- Create a temporary table to list all possible correct AQ SKUs
-- Assumes your AQ DB is called 'AQEXPORT'
IF OBJECT_ID('tempdb..#AQ_SKUs') IS NOT NULL DROP TABLE #AQ_SKUs
SELECT ProductId AS AQ_PRODUCTID, left(rtrim(Model) + '@' + rtrim(VendorNumber), 20) AS AQ_SKU into #AQ_SKUs
  FROM AQEXPORT.dbo.Products
GO

-- Clear all AQ SKUs that don't match up to anything in AutoQuotes
UPDATE BARCODES
  SET BAR_BARCODE = ''
  WHERE BAR_ID = 2
    AND BAR_TYPE = 'I'
    AND BAR_BARCODE <> ''
    AND NOT EXISTS (
      SELECT AQ_SKU FROM #AQ_SKUs WHERE AQ_SKU = rtrim(BAR_BARCODE)
    )
GO

-- Create empty AQ SKUs for all items that don't have one
DECLARE @maxpid AS int = (SELECT max(BAR_PrimaryID) FROM BARCODES)
INSERT INTO BARCODES
  SELECT '' AS BAR_BARCODE, BAR_INVNO, BAR_TYPE, BAR_C_ID, BAR_DEPARTMENT, BAR_DESCRIPTION, 2 AS BAR_ID, BAR_Active, BAR_DisplayDesc, BAR_Quantity, BAR_DisplayQuan, BAR_UM, 1 AS BAR_DisplayFlag, BAR_DisplayName, BAR_Site+left(REPLACE(newid(), '-', ''), 12) AS BAR_GUID, BAR_Site, @maxpid + ROW_NUMBER() over(ORDER BY (SELECT NULL)) AS BAR_PrimaryID, BAR_PriceInvno, BAR_PriceGroupID, BAR_PriceLevel, BAR_DisplaySKU
    FROM BARCODES WHERE BAR_ID = 1 AND BAR_TYPE = 'I' AND BAR_INVNO NOT IN (
      SELECT BAR_INVNO FROM BARCODES WHERE BAR_ID = 2 AND BAR_TYPE = 'I'
    )
GO

-- Update any empty AQ SKU that we can generate and verify
UPDATE BARCODES
  SET BAR_BARCODE = left(rtrim(VIN_VINO) + '@' + VED_FORSKU, 20)
  FROM ITPrice
    LEFT JOIN VENDetail ON ITP_PVendorID = VED_V_ID
    LEFT JOIN VENINV ON ITP_INVNO = VIN_INVNO AND ITP_PVendorID = VIN_V_ID
  WHERE ITP_INVNO = BAR_INVNO
    AND BAR_BARCODE = ''
    AND BAR_ID = 2
    AND BAR_TYPE = 'I'
    AND EXISTS (SELECT * FROM #AQ_SKUs WHERE rtrim(AQ_SKU) = left(rtrim(VIN_VINO) + '@' + VED_FORSKU, 20))
GO
