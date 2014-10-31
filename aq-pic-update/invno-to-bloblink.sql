/*
 * Returns an AQ BlobLink given a POSitive Inventory Number (INVNO)
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

 SET NOCOUNT ON;

SELECT TOP 1 BlobLink
  FROM AQ5StarPictureLink
  WHERE INVNO = '$(INVNO)';
