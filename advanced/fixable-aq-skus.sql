-- Comparing Best Guess AQ SKUs to Actual

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
    AND RTRIM(VIN_VINO)+'@'+VED_FORSKU != BAR_BARCODE
    AND ITE_Weight = 0 -- Weight is only set from AQ, so if it's set it must be matching
    AND ITE_FreightClass = 0 -- Freight class is only set from AQ, so if it's set it must be matching
  ORDER BY ITE_BARCODE

 -- From Primary SKU: IIF((CHARINDEX('@', ITE_BARCODE) != 0), LEFT(ITE_BARCODE, CHARINDEX('@', ITE_BARCODE)-1), ITE_BARCODE)