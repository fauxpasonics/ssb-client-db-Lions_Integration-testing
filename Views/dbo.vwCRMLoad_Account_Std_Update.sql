SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vwCRMLoad_Account_Std_Update] AS

SELECT a.new_ssbcrmsystemacctid, a.Name, a.address1_line1, a.address1_city, a.address1_stateorprovince, a.address1_postalcode, a.address1_country, a.telephone1, a.accountid, LoadType, a.emailaddress1
--,b.Name, b.address1_line1, b.address1_city, b.address1_stateorprovince, b.address1_postalcode, b.address1_country, b.telephone1, b.accountid,  b.emailaddress1
FROM [dbo].[vwCRMLoad_Account_Std_Prep] a
JOIN prodcopy.vw_account b on a.accountid = b.accountid
Left join Lions.[dbo].[vw_KeyAccounts] k --updateme
		ON a.accountid = k.SSID
WHERE LoadType = 'Update'
AND k.SSID is NULL
AND  (HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(a.Name ))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(b.Name ))),'')) 
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(a.address1_line1 ))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(b.address1_line1 ))),'')) 
	Or HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(REPLACE(REPLACE(REPLACE(REPLACE(a.telephone1,')',''),'(',''),'-',''),' ','') ))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(REPLACE(REPLACE(REPLACE(REPLACE(b.telephone1,')',''),'(',''),'-',''),' ','') ))),'') )
	Or HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(a.emailaddress1 ))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(b.emailaddress1 ))),'')) 
	)
GO
