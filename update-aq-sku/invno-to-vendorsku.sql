/*
 * Returns the Primary Vendor's SKU given a POSitive Inventory Number (INVNO)
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

SET NOCOUNT ON;
DECLARE @INVNO int;
-- SET @INVNO = 2002094; -- Used when testing, otherwise value should be passed in to next line
SET @INVNO = $(INVNO);

SELECT TOP 1 VIN_VINO
  FROM ITPrice JOIN VENINV ON ITP_INVNO = VIN_INVNO AND ITP_PVendorID = VIN_V_ID
  WHERE ITP_INVNO = @INVNO
