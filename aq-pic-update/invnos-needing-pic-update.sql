/*
 * Returns a list of INVNOs that need an AQ picture update
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

 SET NOCOUNT ON;

-- Create temp table linking Pictures table to Products table to INVNOs to existing Pictures
IF OBJECT_ID('dbo.AQ5StarPictureLink', 'U') IS NOT NULL DROP TABLE dbo.AQ5StarPictureLink
SELECT BAR_INVNO AS INVNO, $(positive_db).dbo.prm_ConvertPRMDateTime(CREATEDATE, CREATETIME) AS POSitivePictureDate, DateTag AS AQPictureDate, BlobLink into AQ5StarPictureLink
FROM Pictures
  INNER JOIN Products
    ON rtrim(PictureLink) = rtrim(BlobLink)
  INNER JOIN $(positive_db).dbo.BARCODES
    ON rtrim(BAR_BARCODE) = left(rtrim(Model) + '@' + rtrim(VendorNumber), 20) AND BAR_ID = 2
  LEFT OUTER JOIN $(positive_db).dbo.BINPIC  -- We want entries even if there isn't an existing BINPIC
    ON BAR_INVNO = BIP_ID AND BIP_Type = 2 AND ITEM = 1  -- Assume thumbnail matches big picture, so use ITEM = 1
  -- TODO: column that shows if it's an AQ pic?
go

-- Find the INVNOs of items where POSitivePictureDate < AQPictureDate
SELECT INVNO
  FROM AQ5StarPictureLink
  WHERE POSitivePictureDate < AQPictureDate
    OR POSitivePictureDate IS NULL
  ORDER BY INVNO ASC
