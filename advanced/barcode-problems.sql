/*
 * Quick checks for common possible barcode-related problems in POSitive
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

-- Duplicate AutoQuotes SKUs from AQ (not much you can do about this except ask POSitive to increase SKU limits)
SELECT AQ_SKU, COUNT(AQ_SKU)
  FROM #AQ_SKUs
  GROUP BY AQ_SKU
  HAVING COUNT(AQ_SKU) > 1
  ORDER BY COUNT(AQ_SKU) desc

-- List all non-matches
SELECT * FROM BARCODES
  WHERE BAR_ID = 2
    AND BAR_BARCODE <> ''
    AND NOT EXISTS (
      SELECT AQ_SKU FROM #AQ_SKUs
        WHERE AQ_SKU = rtrim(BAR_BARCODE)
    )
  ORDER BY BAR_BARCODE

-- List all AQ SKUs with whitespace problems (i.e. would match up to AutoQuotes data if whitespaces were ignored)
SELECT BAR_BARCODE AS FIVESTAR_AQ_SKU, AQ_SKU AS GOOD_AQ_SKU, *
  FROM BARCODES
  JOIN #AQ_SKUs ON replace(BAR_BARCODE, ' ', '') = replace(AQ_SKU, ' ', '')
  WHERE BAR_ID = 2
    AND BAR_TYPE = 'I'
    AND AQ_SKU != BAR_BARCODE
    AND AQ_SKU IS NOT NULL
  -- ORDER BY makes this query super slow

-- List all Vendor IDs that are off by whitespace from a valid AQ SKU (can be fixed automatically)
SELECT VIN_VINO AS CURRENT_VENDOR_SKU, left(BAR_BARCODE, charindex('@', BAR_BARCODE) - 1) AS CORRECT_VENDOR_SKU, *
  FROM BARCODES
    INNER JOIN ITPrice ON BAR_INVNO = ITP_INVNO
    INNER JOIN VENINV ON VIN_INVNO = BAR_INVNO AND ITP_PVendorID = VIN_V_ID
  WHERE BAR_ID = 2
    AND BAR_TYPE = 'I'
    AND VIN_INVNO = BAR_INVNO
    AND ITP_PVendorID = VIN_V_ID
    AND charindex('@', BAR_BARCODE) > 0
    AND VIN_VINO != left(BAR_BARCODE, charindex('@', BAR_BARCODE) - 1)
    AND VIN_VINO = replace(left(BAR_BARCODE, charindex('@', BAR_BARCODE) - 1), ' ', '')
    AND EXISTS (SELECT * FROM #AQ_SKUs WHERE rtrim(AQ_SKU) = rtrim(BAR_BARCODE))
  ORDER BY CORRECT_VENDOR_SKU

-- Items where the Vendor SKU doesn't match the Vendor SKU derived from a correct AQ SKU (must be fixed manually)
SELECT VIN_VINO AS CURRENT_VENDOR_SKU, left(BAR_BARCODE, charindex('@', BAR_BARCODE) - 1) AS AQ_VENDOR_SKU, *
  FROM BARCODES
    INNER JOIN ITPrice ON BAR_INVNO = ITP_INVNO
    INNER JOIN VENINV ON VIN_INVNO = BAR_INVNO AND ITP_PVendorID = VIN_V_ID
  WHERE BAR_ID = 2
    AND BAR_TYPE = 'I'
    AND VIN_INVNO = BAR_INVNO
    AND ITP_PVendorID = VIN_V_ID
    AND charindex('@', BAR_BARCODE) > 0
    AND VIN_VINO != left(BAR_BARCODE, charindex('@', BAR_BARCODE) - 1)
    AND VIN_VINO != replace(left(BAR_BARCODE, charindex('@', BAR_BARCODE) - 1), ' ', '')
    AND EXISTS (SELECT * FROM #AQ_SKUs WHERE rtrim(AQ_SKU) = rtrim(BAR_BARCODE))
  ORDER BY AQ_VENDOR_SKU

-- Primary SKUs that have @[####] in them (i.e. created by an AQ import)
SELECT *
  FROM BARCODES
  WHERE BAR_ID = 1
    AND BAR_TYPE = 'I'
    AND charindex('@', BAR_BARCODE) > 0
    AND isnumeric(right(rtrim(BAR_BARCODE), (len(BAR_BARCODE) - charindex('@', BAR_BARCODE)))) = 1
  ORDER BY BAR_BARCODE

-- Barcode entries that don't match up to items in ITPrice
SELECT *
  FROM BARCODES
  WHERE BAR_ID != 2
  AND NOT EXISTS (SELECT * FROM ITPrice WHERE ITP_INVNO = BAR_INVNO)
