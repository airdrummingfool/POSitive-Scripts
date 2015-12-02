/*
 * Returns a customer code given an AR transaction number
 *
 * @author: Tommy Goode
 * @copyright: 2015 International Restaurant Distributors, Inc.
 *
 */

SET NOCOUNT ON;
DECLARE @TNum int = $(TNum);

SELECT TOP 1 CUS_CODE
  FROM CUSMER
  WHERE CUS_CustID = (SELECT ART_CustID FROM AR_TRN WHERE ART_TNUM = @TNum)
