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

-- Count all AQ SKUs before
SELECT 'Good AQ SKUs before: ', count(*)
  FROM BARCODES
    WHERE BAR_ID = 2
	  AND BAR_BARCODE IN (SELECT AQ_SKU from #AQ_SKUs)

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

-- Fix Vendor SKUs when they're only off by whitespace from a known-good AQ SKU
--  Note: we don't fix Vendor SKUs when off by more than whitespace because
--  we could be using a generic AQ item for multiple specific vendor items
--  e.g. S104PCP@2127 for both S104PCPR and S104PCPY (same item, different colors)
UPDATE VENINV
  SET VIN_VINO = rtrim(left(BAR_BARCODE, charindex('@', BAR_BARCODE) - 1))
  FROM BARCODES
    INNER JOIN ITPrice ON BAR_INVNO = ITP_INVNO
  WHERE BAR_ID = 2
    AND BAR_TYPE = 'I'
    AND VIN_INVNO = BAR_INVNO
    AND ITP_PVendorID = VIN_V_ID
    AND charindex('@', BAR_BARCODE) > 0
    AND VIN_VINO != rtrim(left(BAR_BARCODE, charindex('@', BAR_BARCODE) - 1))
    AND VIN_VINO = replace(left(BAR_BARCODE, charindex('@', BAR_BARCODE) - 1), ' ', '')
    AND EXISTS (SELECT * FROM #AQ_SKUs WHERE rtrim(AQ_SKU) = rtrim(BAR_BARCODE))
GO

-- Update any empty AQ SKU that we can generate and verify
UPDATE BARCODES
  SET BAR_BARCODE = rtrim(AQ_SKU)
  FROM ITPrice
    INNER JOIN VENDetail ON ITP_PVendorID = VED_V_ID
    INNER JOIN VENINV ON ITP_INVNO = VIN_INVNO AND ITP_PVendorID = VIN_V_ID
    INNER JOIN #AQ_SKUs ON rtrim(AQ_SKU) = left(rtrim(VIN_VINO) + '@' + VED_FORSKU, 20)
  WHERE ITP_INVNO = BAR_INVNO
    AND BAR_BARCODE = ''
    AND BAR_ID = 2
    AND BAR_TYPE = 'I'
GO

-- Count all good AQ SKUs after
SELECT 'Good AQ SKUs after: ', count(*)
  FROM BARCODES
    WHERE BAR_ID = 2
	  AND BAR_BARCODE IN (SELECT AQ_SKU from #AQ_SKUs)
