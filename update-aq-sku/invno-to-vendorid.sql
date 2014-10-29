/*
 * Returns the Primary Vendor's AQ ID given a POSitive Inventory Number (INVNO)
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

SET NOCOUNT ON;
DECLARE @INVNO int;
-- SET @INVNO = 2001922; -- Used when testing, otherwise value should be passed in to next line
SET @INVNO = $(INVNO);

SELECT VED_FORSKU
  FROM ITPrice JOIN VENDetail  ON ITP_PVendorID = VED_V_ID
  WHERE ITP_INVNO = @INVNO
