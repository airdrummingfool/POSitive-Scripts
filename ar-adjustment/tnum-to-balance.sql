/*
 * Returns the balance of a given AR transaction number
 *
 * @author: Tommy Goode
 * @copyright: 2015 International Restaurant Distributors, Inc.
 *
 */

SET NOCOUNT ON;
DECLARE @TNum int = $(TNum);

SELECT TOP 1 ART_BALA
  FROM AR_TRN
  WHERE ART_TNUM = @TNum
