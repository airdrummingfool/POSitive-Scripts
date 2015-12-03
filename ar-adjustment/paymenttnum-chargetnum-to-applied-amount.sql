/*
 * Returns the amount of a payment applied to a given charge
 *
 * @author: Tommy Goode
 * @copyright: 2015 International Restaurant Distributors, Inc.
 *
 */

SET NOCOUNT ON;
DECLARE @PaymentTNum int = $(PaymentTNum);
DECLARE @ChargeTNum int = $(ChargeTNum);

SELECT TOP 1 CRF_AMNT
  FROM AR_CRF
  WHERE CRF_TNM1 = @PaymentTNum
    AND CRF_TNM2 = @ChargeTNum
