/*
 * Returns a Description given a POSitive Inventory Number (INVNO)
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

SET NOCOUNT ON;

SELECT TOP 1 BAR_DESCRIPTION
  FROM BARCODES
  WHERE BAR_ID = 1 AND BAR_INVNO = '$(INVNO)';
