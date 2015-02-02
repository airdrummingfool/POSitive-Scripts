/*
 * Quickly fix quote/sales order/etc line items that were merged by POSitive
 *
 * @author: Tommy Goode
 * @copyright: 2015 International Restaurant Distributors, Inc.
 *
 */

UPDATE INVDET
  SET IND_BARCODE = CTE_BARCODE, IND_DESCRIPTION = CTE_DESCRIPTION
  FROM (SELECT ITE_BARCODE AS CTE_BARCODE, ITE_DESCRIPTION AS CTE_DESCRIPTION, ITE_INVNO AS CTE_INVNO FROM ITEMS) AS CTE
  WHERE IND_BARCODE = ''
    AND CTE_INVNO = IND_INVNO
	AND CTE_BARCODE IS NOT NULL
