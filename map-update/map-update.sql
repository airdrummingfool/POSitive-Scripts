/*
 * Calculate updated MAP Pricing for inventory items
 *  @note: Assumes VendorID matches AQ Vendor ID (truncated to 6 characters).
 *
 *  @author: Tommy Goode
 *  @copyright: 2015 International Restaurant Distributors, Inc.
 *
 */

SET NOCOUNT ON;
-- USE [$(positive_db)]

--
-- Beverage Air
--  * Description : Constant multiple of 0.3825 on all Beverage Air products
--  * Last updated: 2014/09/24
--
DECLARE @invno int;
DECLARE @aqList decimal;

DECLARE bevair_cursor CURSOR FOR
  SELECT ITP_INVNO, ITP_PRICE1
    FROM ITPrice
	WHERE ITP_PRICE1 > 0
	  AND ITP_PVendorID = (
	    SELECT VEN_V_ID
	      FROM APVEND
	      WHERE VEN_U_ID = 'BEVAIR'
	    )

OPEN bevair_cursor
FETCH NEXT FROM bevair_cursor INTO @invno, @aqList

WHILE @@FETCH_STATUS = 0
BEGIN
  UPDATE UDFIELDS set UDF_UDFLD1 = FORMAT(ROUND(@aqList * 0.3825, 2), 'F2')
    WHERE UDF_UDDES1 = 'MAP'
    AND UDF_INVNO = @invno
  FETCH NEXT FROM bevair_cursor INTO @invno, @aqList
END

CLOSE bevair_cursor
DEALLOCATE bevair_cursor

GO
--
-- /Beverage Air
--

--
-- MasterBilt
--  * Description : Constant multiplier of 0.4861 OFF for FUSION and FUSION PLUS products
--  * Last updated: 2010/05/21
DECLARE @invno int;
DECLARE @aqList decimal;

DECLARE masterbilt_fusion_cursor CURSOR FOR
  SELECT ITP_INVNO, ITP_PRICE1
    FROM ITPrice
	  LEFT JOIN UDFIELDS ON UDF_INVNO = ITP_INVNO AND UDF_UDDES1 = 'MAP'
	  LEFT JOIN NOTES ON NTS_N_ID = ITP_INVNO AND NTS_TYPE = 'X'
	WHERE ITP_PRICE1 > 0
	  AND ITP_PVendorID = (
	    SELECT VEN_V_ID
	      FROM APVEND
	      WHERE VEN_U_ID = 'MASTRB'
	    )
	  AND (NTS_NOTE LIKE 'Fusion™%' OR NTS_NOTE LIKE 'Fusion Plus™')

OPEN masterbilt_fusion_cursor
FETCH NEXT FROM masterbilt_fusion_cursor INTO @invno, @aqList

WHILE @@FETCH_STATUS = 0
BEGIN
  UPDATE UDFIELDS set UDF_UDFLD1 = FORMAT(ROUND(@aqList * 1.0-0.4861, 2), 'F2')
    WHERE UDF_UDDES1 = 'MAP'
    AND UDF_INVNO = @invno
  FETCH NEXT FROM masterbilt_fusion_cursor INTO @invno, @aqList
END

CLOSE masterbilt_fusion_cursor
DEALLOCATE masterbilt_fusion_cursor

GO
--
-- /MasterBilt
--

--
-- True Mfg
--  * Description : 50/10/15 off all True products
--  * Last updated: 2011/05/01
--
DECLARE @invno int;
DECLARE @aqList decimal;

DECLARE true_cursor CURSOR FOR
  SELECT ITP_INVNO, ITP_PRICE1
    FROM ITPrice
	WHERE ITP_PRICE1 > 0
	  AND ITP_PVendorID = (
	    SELECT VEN_V_ID
	      FROM APVEND
	      WHERE VEN_U_ID = 'TRUE'
	    )

OPEN true_cursor
FETCH NEXT FROM true_cursor INTO @invno, @aqList

WHILE @@FETCH_STATUS = 0
BEGIN
  UPDATE UDFIELDS set UDF_UDFLD1 = FORMAT(ROUND(@aqList * 0.5 * 0.9 * 0.85, 2), 'F2')
    WHERE UDF_UDDES1 = 'MAP'
    AND UDF_INVNO = @invno
  FETCH NEXT FROM true_cursor INTO @invno, @aqList
END

CLOSE true_cursor
DEALLOCATE true_cursor

GO
--
-- /True
--