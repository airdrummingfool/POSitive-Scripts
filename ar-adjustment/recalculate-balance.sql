/*
 * Recalculates the balance of a given transaction
 *
 * @author: Devin Spikowski
 * @modified-by: Tommy Goode
 * @copyright: 2015 International Restaurant Distributors, Inc.
 *
 */

SET NOCOUNT ON;
DECLARE @TNum AS int = $(TNum)
DECLARE @totalApplied AS decimal(13,4) = isnull((SELECT sum(CRF_AMNT) FROM AR_CRF WHERE CRF_TNM2 = @TNum or CRF_TNM1 = @TNum), 0)
select @totalApplied

UPDATE AR_TRN
  SET
    ART_OPCL =
      CASE ART_TTOT - @totalApplied
        WHEN 0 THEN 'C'
        ELSE 'O'
      END,
    ART_BALA = ART_TTOT - @totalApplied, ART_PAID = @totalApplied
  WHERE ART_TNUM = @TNum AND ART_OPCL IN ('C', 'O')
