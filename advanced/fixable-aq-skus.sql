/*
 * Generates a best-guess recommended AQ SKU and compares it to the existing AQ SKU for each item
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

SELECT ITE_INVNO, ITE_BARCODE AS PRIMARY_SKU, VIN_VINO AS VENDOR_SKU, VED_FORSKU AS VENDOR_ID,
  RTRIM(VIN_VINO)+'@'+VED_FORSKU AS RECOMMENDED_AQSKU,
  BAR_BARCODE AS CURRENT_AQSKU, ITE_LONGDESC, VEN_NAME
  FROM ITEMS
    LEFT JOIN BARCODES ON ITE_INVNO = BAR_INVNO AND BAR_ID = 2
    JOIN ITPrice ON ITE_INVNO = ITP_INVNO
    JOIN VENDetail ON ITP_PVendorID = VED_V_ID
    JOIN APVEND ON ITP_PVendorID = VEN_V_ID
    LEFT JOIN VENINV ON ITE_INVNO = VIN_INVNO AND ITP_PVendorID = VIN_V_ID
  WHERE VED_FORSKU != ''
    AND RTRIM(VIN_VINO)+'@'+VED_FORSKU != RTRIM(BAR_BARCODE)
    AND ITE_Weight = 0 -- Weight is only set from AQ, so if it's set it must be matching
    AND ITE_FreightClass = 0 -- Freight class is only set from AQ, so if it's set it must be matching
    -- @TODO: set a flag in the ITEMS table when successfully matched to an AQ item
  ORDER BY ITE_BARCODE
