/*
 * Deletes an applied payment amount from a charge
 *
 * @author: Devin Spikowski
 * @modified-by: Tommy Goode
 * @copyright: 2015 International Restaurant Distributors, Inc.
 *
 */


-- delete  an applied payment
DECLARE @PaymentTNum int = $(PaymentTNum)
DECLARE @ChargeTNum int = $(ChargeTNum)
DECLARE @PaymentAmount decimal(13,4) = $(PaymentAmount)

DELETE FROM AR_CRF
  WHERE CRF_TNM1 = @PaymentTNum
    AND CRF_TNM2 = @ChargeTNum
    AND CRF_AMNT = @PaymentAmount

DECLARE @TotalPaid decimal(13,4) = isnull((SELECT sum(CRF_AMNT) FROM AR_CRF WHERE CRF_TNM2 = @ChargeTNum), 0)
DECLARE @TotalApplied decimal(13,4) = isnull((SELECT sum(CRF_AMNT) FROM AR_CRF WHERE CRF_TNM1 = @PaymentTNum), 0)

UPDATE AR_TRN
  SET
    ART_OPCL =
      CASE ART_TTOT - @TotalPaid
        WHEN 0 THEN 'C'
        ELSE 'O'
      END,
    ART_BALA = ART_TTOT - @TotalPaid,
    ART_PAID = @TotalPaid
  WHERE ART_TNUM = @ChargeTNum

UPDATE AR_TRN
  SET
    ART_OPCL =
      CASE ART_TTOT - @TotalApplied
        WHEN 0 THEN 'C'
        ELSE 'O'
      END,
    ART_BALA = ART_TTOT - @TotalApplied,
    ART_PAID = @TotalApplied
  WHERE ART_TNUM = @PaymentTNum
