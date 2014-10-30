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

-- Bad BinPic (Picture) entries
SELECT *
  FROM BINPIC
  WHERE BIP_ID = 0 OR (BIP_Type = 2 AND BIP_Filename = '') OR BIP_Picture IS NULL

-- Duplicate AutoQuotes SKUs from AQ (not much you can do about this except bug POSitive to increase SKU limits)
SELECT left(rtrim(model) + '@' + rtrim(vendornumber),20), COUNT(left(rtrim(model) + '@' + rtrim(vendornumber),20))
  FROM [$(autoquotes_db)].[dbo].[Products]
  GROUP BY left(rtrim(model) + '@' + rtrim(vendornumber),20)
  HAVING COUNT(left(rtrim(model) + '@' + rtrim(vendornumber),20)) > 1
  ORDER BY COUNT(left(rtrim(model) + '@' + rtrim(vendornumber),20)) desc
