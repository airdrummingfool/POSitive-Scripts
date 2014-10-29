/*
 * Quick checks for common possible problems in POSitive
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

-- Bad Vendor Inventory entries (bad Vendor SKU or empty Vendor ID)
SELECT *
  FROM VENINV
  WHERE VIN_V_ID = 0 OR VIN_VINO like '%@' OR VIN_VINO like '%@%'

 -- Items with bad AQ SKUs
 SELECT *
  FROM BARCODES
  WHERE BAR_ID = 2 AND RTRIM(BAR_BARCODE) NOT LIKE '_%@_%' AND BAR_BARCODE != ''

-- Items with empty Primary Vendor
SELECT ITE_INVNO, ITE_BARCODE, ITE_DESCRIPTION, *
  FROM ITEMS JOIN ITPrice ON ITE_INVNO = ITP_INVNO
  WHERE ITP_PVendorID = 0 AND ITE_INVNO IN (
    SELECT VIN_INVNO
      FROM VENINV
    )

-- Items With no Vendor
SELECT ITE_INVNO, ITE_BARCODE, ITE_DESCRIPTION, *
  FROM ITEMS
  WHERE ITE_INVNO NOT IN (
    SELECT VIN_INVNO
      FROM VENINV
    )
