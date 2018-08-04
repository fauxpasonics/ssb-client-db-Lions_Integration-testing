SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[vwCRMLoad_Contact_Std_Update] AS
--updateme - Hashes
SELECT a.new_ssbcrmsystemacctid, a.new_ssbcrmsystemcontactid, a.Prefix, a.FirstName, a.LastName, a.Suffix, a.address1_line1, a.address1_city, a.address1_stateorprovince, a.address1_postalcode, a.address1_country
, a.telephone1, a.contactid, LoadType, a.emailaddress1
--, b.FirstName, b.LastName, b.Suffix, b.address1_line1, b.address1_city, b.address1_stateorprovince, b.address1_postalcode, b.address1_country, b.emailaddress1
--, b.telephone1
--,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(a.FirstName))),'') )				, HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(b.FirstName))),'')) 
--	, HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(a.LastName))),'') )		, HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(b.LastName))),'')) 
--	, HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(a.Suffix))),'') )			, HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(b.Suffix))),'')) 
--	, HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(a.address1_line1))),'') )  , HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(b.address1_line1))),'')) 
--	, HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(REPLACE(REPLACE(REPLACE(REPLACE(a.telephone1,')',''),'(',''),'-',''),' ','')))),'') )  , HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(b.telephone1))),'')) 
--	, HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(a.emailaddress1))),'') )  , HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(Lower(b.emailaddress1))),'')) 

FROM [dbo].[vwCRMLoad_Contact_Std_Prep] a
JOIN prodcopy.vw_contact b ON a.contactid = b.contactID
LEFT JOIN dbo.vw_KeyAccounts k ON k.SSID = a.contactid
WHERE LoadType = 'Update'
AND k.ssid IS null
--AND (
--a.Hash_FirstName !=  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(b.FirstName))),'')) 
--OR a.Hash_lastname !=  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(b.lastname))),'')) 
--OR a.Hash_suffix !=  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(b.suffix))),'')) 
--OR a.Hash_Address1_Line1 !=  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(b.address1_line1))),'')) 
--OR a.Hash_Telephone1 !=  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(b.telephone1))),'')) 
--)
AND ( 
 ISNULL(a.Prefix,'') != ISNULL(b.salutation,'')
OR ISNULL(a.FirstName,'') != ISNULL(b.FirstName,'')
OR ISNULL(a.LastName,'') != ISNULL(b.LastName,'')
OR ISNULL(a.Suffix,'') != ISNULL(b.Suffix,'')
OR ISNULL(a.address1_line1,'') != ISNULL(b.address1_line1,'')
OR ISNULL(a.address1_city,'') != ISNULL(b.address1_city,'')
OR ISNULL(a.address1_stateorprovince,'') != ISNULL(b.address1_stateorprovince,'')
OR ISNULL(a.address1_postalcode,'') != ISNULL(b.address1_postalcode,'')
OR ISNULL(a.address1_country,'') != ISNULL(b.address1_country,'')
OR ISNULL(a.telephone1,'') != ISNULL(b.telephone1,'')
OR ISNULL(a.emailaddress1,'') != ISNULL(b.emailaddress1,'')
)


GO
