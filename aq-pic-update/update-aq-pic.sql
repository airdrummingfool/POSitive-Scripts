/*
 * Updates a POSitive item's image and thumbnail, given INVNO, paths to the images, and site
 *
 * @author: Tommy Goode
 * @copyright: 2014 International Restaurant Distributors, Inc.
 *
 */

DECLARE @maxpid AS int = (SELECT max(BIP_PrimaryID) FROM BINPIC WHERE BIP_Site = '$(site)')
DECLARE @img AS varbinary(max) = (SELECT * FROM OPENROWSET(BULK '$(tmpjpg)', SINGLE_BLOB) as img)
DECLARE @thumb AS varbinary(max) = (SELECT * FROM OPENROWSET(BULK '$(tmpthmb)', SINGLE_BLOB) as img)
DECLARE @primarysku AS varchar(20) = (SELECT rtrim(BAR_BARCODE) FROM BARCODES WHERE BAR_INVNO = $(INVNO) AND BAR_ID = 1)
DECLARE @imgdate AS datetime = (SELECT dateadd(ss, 1, AQPictureDate) FROM [$(autoquotes_db)].dbo.AQ5StarPictureLink WHERE INVNO = $(INVNO))  -- Add 1 second to the AQPicture date because we lose precision when we store in PRM split date/time format

-- Insert/update the main image
IF EXISTS (SELECT * FROM BINPIC WHERE BIP_ID = $(INVNO) AND ITEM = 1)
  UPDATE BINPIC SET BIP_Picture = @img, CREATEDATE = dbo.prm_ToPRMDate(@imgdate), CREATETIME = dbo.prm_ToPRMTime(@imgdate), LASTWRITTENDATE = dbo.prm_ToPRMDate(getdate()), LASTWRITTENTIME = dbo.prm_ToPRMTime(getdate())
    WHERE BIP_ID = $(INVNO) AND BIP_Type = 2 AND ITEM = 1
ELSE
  INSERT INTO BINPIC
    VALUES ($(INVNO), 2, 1, '', @primarysku+'.jpg', '.jpg', dbo.prm_ToPRMDate(@imgdate), dbo.prm_ToPRMTime(@imgdate), dbo.prm_ToPRMDate(getdate()), dbo.prm_ToPRMTime(getdate()), dbo.prm_ToPRMDate(getdate()), dbo.prm_ToPRMTime(getdate()), '$(site)'+'AQ@'+left(REPLACE(newid(),'-',''),9), '$(site)', @maxpid+1, @img)

-- Then do the same thing with the thumbnail image
set @maxpid = (SELECT max(BIP_PrimaryID) FROM BINPIC WHERE BIP_Site = '$(site)');
IF EXISTS (SELECT * FROM BINPIC WHERE BIP_ID = $(INVNO) AND ITEM = 2)
  UPDATE BINPIC SET BIP_Picture = @thumb, CREATEDATE = dbo.prm_ToPRMDate(@imgdate), CREATETIME = dbo.prm_ToPRMTime(@imgdate), LASTWRITTENDATE = dbo.prm_ToPRMDate(getdate()), LASTWRITTENTIME = dbo.prm_ToPRMTime(getdate())
    WHERE BIP_ID = $(INVNO) AND BIP_Type = 2 AND ITEM = 2
ELSE
  INSERT INTO BINPIC
    VALUES ($(INVNO), 2, 2, '', @primarysku+'_THUMBNAIL.jpg', '.jpg', dbo.prm_ToPRMDate(@imgdate), dbo.prm_ToPRMTime(@imgdate), dbo.prm_ToPRMDate(getdate()), dbo.prm_ToPRMTime(getdate()), dbo.prm_ToPRMDate(getdate()), dbo.prm_ToPRMTime(getdate()), '$(site)'+'AQ@'+left(REPLACE(newid(),'-',''),9), '$(site)', @maxpid+1, @thumb)
