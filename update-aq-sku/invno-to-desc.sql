SET NOCOUNT ON;

SELECT TOP 1 BAR_DESCRIPTION
  FROM BARCODES
  WHERE BAR_ID = 1 AND BAR_INVNO = '$(INVNO)';
