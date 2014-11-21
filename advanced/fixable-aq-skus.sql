/*
 * Generates a best-guess recommended AQ SKU and compares it to the existing AQ SKU for each item
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
go

SELECT * FROM (
  SELECT ITE_INVNO, ITE_BARCODE AS PRIMARY_SKU, VIN_VINO AS VENDOR_SKU, VED_FORSKU AS VENDOR_ID,
    rtrim(VIN_VINO) + '@' + VED_FORSKU AS RECOMMENDED_AQSKU,
    rtrim(BAR_BARCODE) AS CURRENT_AQSKU, ITE_LONGDESC, VEN_NAME,
    CASE WHEN rtrim(AQ_PRODUCTID) != '' THEN 1 ELSE 0 END AS CURRENT_AQSKU_MATCH
    FROM ITEMS
      LEFT JOIN BARCODES ON ITE_INVNO = BAR_INVNO AND BAR_ID = 2
      JOIN ITPrice ON ITE_INVNO = ITP_INVNO
      JOIN VENDetail ON ITP_PVendorID = VED_V_ID
      JOIN APVEND ON ITP_PVendorID = VEN_V_ID
      LEFT JOIN VENINV ON ITE_INVNO = VIN_INVNO AND ITP_PVendorID = VIN_V_ID
      LEFT JOIN #AQ_SKUs ON BAR_BARCODE = AQ_SKU
  ) AS temp
  WHERE VENDOR_ID != ''
    AND CURRENT_AQSKU != RECOMMENDED_AQSKU
    AND CURRENT_AQSKU_MATCH = 0
    AND EXISTS (SELECT AQ_SKU FROM #AQ_SKUs WHERE AQ_SKU = RECOMMENDED_AQSKU)
  ORDER BY PRIMARY_SKU
