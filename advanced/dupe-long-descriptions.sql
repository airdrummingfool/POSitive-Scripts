/*
 * Lists items that have the same long description as another item
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

SELECT ITE_BARCODE as Barcode, ITE_LONGDESC as LongDescription, * FROM ITEMS
  WHERE ITE_LONGDESC IN (
    SELECT ITE_LONGDESC
	  FROM ITEMS JOIN VENINV ON ITEMS.ITE_INVNO = VENINV.VIN_INVNO
	  GROUP BY ITE_LONGDESC, VIN_V_ID
	  HAVING count(ITE_LONGDESC) > 1
  )
  ORDER BY ITE_LONGDESC, ITE_BARCODE
