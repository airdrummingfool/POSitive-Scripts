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
  WHERE VIN_V_ID = 0 OR VIN_VINO like '%@%'

-- Items with Vendor(s) assigned but no Primary Vendor
SELECT ITE_INVNO, ITE_BARCODE, ITE_DESCRIPTION, *
  FROM ITEMS JOIN ITPrice ON ITE_INVNO = ITP_INVNO
  WHERE ITP_PVendorID = 0 AND ITE_INVNO IN (
    SELECT VIN_INVNO
      FROM VENINV
    )

-- Items with a Primary Vendor that doesn't exist
SELECT ITE_INVNO, ITE_BARCODE, ITE_DESCRIPTION, ITP_PVendorID, *
  FROM ITEMS
    JOIN ITPrice ON ITE_INVNO = ITP_INVNO
  WHERE ITP_PVendorID != 0 AND ITP_PVendorID NOT IN (
    SELECT VEN_V_ID
      FROM APVEND
    )

-- Items with a Primary Vendor that is not in the assigned Vendor list
SELECT ITE_INVNO, ITE_BARCODE, ITE_DESCRIPTION, ITP_PVendorID, VEN_NAME, *
  FROM ITEMS
    JOIN ITPrice ON ITE_INVNO = ITP_INVNO
    LEFT JOIN APVEND ON ITP_PVendorID = VEN_V_ID
  WHERE ITP_PVendorID NOT IN (
    SELECT VIN_V_ID
      FROM VENINV
      WHERE VIN_INVNO = ITE_INVNO
    )

-- Items With no Vendor(s) assigned
SELECT ITE_INVNO, ITE_BARCODE, ITE_DESCRIPTION, *
  FROM ITEMS
  WHERE ITE_INVNO NOT IN (
    SELECT VIN_INVNO
      FROM VENINV
    )

-- Items that don't have an ITPrice entry
SELECT ITE_INVNO, ITE_BARCODE, ITE_DESCRIPTION, *
  FROM ITEMS
  WHERE ITE_INVNO NOT IN (
    SELECT ITP_INVNO
      FROM ITPrice
    )

-- Bad BinPic (Picture) entries
SELECT *
  FROM BINPIC
  WHERE BIP_ID = 0 OR (BIP_Type = 2 AND BIP_Filename = '') OR BIP_Picture IS NULL
