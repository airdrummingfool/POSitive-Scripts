/*
 * Find Primary SKUs that are the same except for an @[Vendor ID] in one,
 *  which means that it was likely an imported AutoQuotes item that needs merging
 *
 * @author: Tommy Goode
 * @copyright: 2015 International Restaurant Distributors, Inc.
 *
 */

 SELECT BC1.BAR_BARCODE AS IMPORTED_BARCODE, BC2.BAR_BARCODE AS EXISTING_BARCODE, BC1.BAR_DESCRIPTION, BC2.BAR_DESCRIPTION, *
  FROM BARCODES AS BC1
     INNER JOIN BARCODES AS BC2
	   ON rtrim(left(BC1.BAR_BARCODE, charindex('@', BC1.BAR_BARCODE) - 1)) = BC2.BAR_BARCODE
	     AND BC1.BAR_INVNO <> BC2.BAR_INVNO
    LEFT JOIN ITPrice AS ITP1 ON BC1.BAR_INVNO = ITP1.ITP_INVNO
	LEFT JOIN ITPrice AS ITP2 ON BC2.BAR_INVNO = ITP2.ITP_INVNO
  WHERE BC1.BAR_ID = 1
    AND BC2.BAR_ID = 1
    AND charindex('@', BC1.BAR_BARCODE) > 0
	AND isnumeric(right(rtrim(BC1.BAR_BARCODE), (len(BC1.BAR_BARCODE) - charindex('@', BC1.BAR_BARCODE)))) = 1
	-- AND ITP1.ITP_PVendorID = ITP2.ITP_PVendorID (can't do this until primary vendor gets set correctly on import)
