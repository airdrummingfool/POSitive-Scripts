SET NOCOUNT ON;DECLARE @INVNO int;
-- SET @INVNO = 2001922; -- Used when testing, otherwise value should be passed in to next line
SET @INVNO = $(INVNO);SELECT TOP 1 CASE WHEN BAR_BARCODE='' THEN 'empty' ELSE BAR_BARCODE END  FROM BARCODES  WHERE BAR_ID = 2 AND BAR_INVNO = @INVNO