/*
 * Quick checks for common possible AR-related problems in POSitive
 *
 * @author: Tommy Goode
 * @copyright: 2015 International Restaurant Distributors, Inc.
 *
 */

-- ART_PAID != total paid
select CUS_CODE, art_paid, paytotal, abs(art_paid - paytotal) as difference, *
  from ar_trn
    inner join (
      select sum(crf_amnt) as paytotal, crf_tnm2 as chargeref
        from ar_crf
        group by crf_tnm2
	  ) payments on chargeref = art_tnum
    left join CUSMER ON ART_CustID = CUS_CustID
  where art_type = 'chg'
    and art_paid <> paytotal
  order by difference desc

-- Duplicate entries in AR_CRF
select CUS_CODE, *
  from ar_crf
    left join AR_TRN ON CRF_INVOICENO = ART_T_ID
	left join CUSMER ON ART_CustID = CUS_CustID
  where crf_primaryid not in (
    select max(crf_primaryid) from ar_crf
      group by crf_bnm1, crf_bnm2, crf_tnm1, crf_tnm2, crf_amnt, crf_site, CRF_INVOICENO
    )
  order by CUSMER.CUS_CODE
