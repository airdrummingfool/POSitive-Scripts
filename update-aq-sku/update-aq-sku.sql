/*
 * Updates or creates an entry for an item's AQ SKU
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

DECLARE @maxpid AS int = (select max(BAR_PrimaryID) from BARCODES)

IF EXISTS (SELECT * FROM BARCODES WHERE BAR_ID = 2 AND BAR_INVNO = $(INVNO))
  UPDATE BARCODES SET BAR_BARCODE = UPPER('$(NewAQSKU)') WHERE BAR_ID = 2 AND BAR_INVNO = $(INVNO)
ELSE
  INSERT INTO BARCODES
    SELECT UPPER('$(NewAQSKU)'), BAR_INVNO, BAR_TYPE, BAR_C_ID, BAR_DEPARTMENT, BAR_DESCRIPTION, 2, BAR_Active, BAR_DisplayDesc, BAR_Quantity, BAR_DisplayQuan, BAR_UM, 1, BAR_DisplayName, BAR_Site+left(REPLACE(newid(),'-',''),12), BAR_Site, @maxpid+1, BAR_PriceInvno, BAR_PriceGroupID, BAR_PriceLevel, BAR_DisplaySKU
      FROM BARCODES WHERE BAR_ID = 1 AND BAR_INVNO = $(INVNO)
