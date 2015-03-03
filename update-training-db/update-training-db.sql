/*
 * Backs up the master db and restores it over the training db
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

BACKUP DATABASE [$(MASTER_DB)]
  TO DISK = '$(TEMP_DIR)\master-to-training-db.bak'
GO

RESTORE DATABASE [$(TRAINING_DB)]
  FROM DISK = '$(TEMP_DIR)\master-to-training-db.bak'
  WITH REPLACE
GO
