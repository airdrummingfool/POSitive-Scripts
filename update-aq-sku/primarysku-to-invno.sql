/*
 * Returns a POSitive Inventory Number (INVNO) given a Primary SKU
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

SET NOCOUNT ON;

SELECT TOP 1 BAR_INVNO
  FROM BARCODES
  WHERE BAR_ID = 1 AND rtrim(BAR_BARCODE) = rtrim('$(PrimarySKU)');
