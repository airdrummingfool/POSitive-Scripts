/*
 * Moves an applied payment amount from one charge to another
 *
 * @author: Devin Spikowski
 * @modified-by: Tommy Goode
 * @copyright: 2015 International Restaurant Distributors, Inc.
 *
 */

DECLARE @PaymentTNum as int = $(PaymentTNum)
DECLARE @OldChargeTNum as int = $(OldChargeTNum)
DECLARE @NewChargeTNum as int = $(NewChargeTNum)

UPDATE AR_CRF
  SET CRF_TNM2 = @NewChargeTNum, CRF_TID2 = (SELECT ART_T_ID FROM AR_TRN WHERE ART_TNUM = @NewChargeTNum)
  WHERE CRF_TNM2 = @OldChargeTNum AND CRF_TNM1 = @PaymentTNum

DECLARE @oldChargeTotalPaid as decimal(13,4) = isnull((SELECT sum(CRF_AMNT) FROM AR_CRF WHERE CRF_TNM2 = @OldChargeTNum), 0)
DECLARE @newChargeTotalPaid as decimal(13,4) = isnull((SELECT sum(CRF_AMNT) FROM AR_CRF WHERE CRF_TNM2 = @NewChargeTNum), 0)

UPDATE AR_TRN
  SET
    ART_OPCL =
      CASE ART_TTOT - @oldChargeTotalPaid
        WHEN 0 THEN 'C'
        ELSE 'O'
      END,
    ART_BALA = ART_TTOT - @oldChargeTotalPaid,
    ART_PAID = @oldChargeTotalPaid
  WHERE ART_TNUM = @OldChargeTNum

UPDATE AR_TRN
  SET
    ART_OPCL =
      CASE ART_TTOT - @newChargeTotalPaid
        WHEN 0 THEN 'C'
        ELSE 'O'
      END,
    ART_BALA = ART_TTOT - @newChargeTotalPaid,
    ART_PAID = @newChargeTotalPaid
  WHERE ART_TNUM = @NewChargeTNum
