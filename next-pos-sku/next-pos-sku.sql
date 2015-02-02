/*
 * Generates the next sequential numeric Alt. SKU, ignoring Alt. SKUs that are similar to the Primary SKU
 *  e.g. Alt SKU = [Primary SKU]@[VendorID] or vice versa
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

SET NOCOUNT ON;

SELECT TOP 1 SRS_SKU+1
  FROM ird_vShowroomSKUByINVNO
  ORDER BY SRS_SKU DESC
