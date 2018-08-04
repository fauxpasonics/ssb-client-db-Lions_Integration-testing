SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwCRMLoad_Contact_Std_Prep]
AS 
SELECT --updateme - hashes
	  a.[SSB_CRMSYSTEM_ACCT_ID] new_ssbcrmsystemacctid
	  , a.[SSB_CRMSYSTEM_CONTACT_ID] new_ssbcrmsystemcontactid
	  , NULLIF(a.[Prefix],'') AS Prefix
      , a.[FirstName]
	  , a.[LastName]
	  , a.[Suffix]
      ,NULLIF(a.[AddressPrimaryStreet],' ') as address1_line1
      ,NULLIF(a.[AddressPrimaryCity],'') address1_city
      ,NULLIF(a.[AddressPrimaryState],'') address1_stateorprovince
      ,NULLIF(a.[AddressPrimaryZip],'') address1_postalcode
      ,NULLIF(a.[AddressPrimaryCountry],'') address1_country
      ,NULLIF(a.[Phone],'' )telephone1
      ,a.[crm_id] contactid
	  , NULLIF(a.EmailPrimary,'') AS emailaddress1
	  ,c.[LoadType]	  
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(a.FirstName))),'')) AS Hash_FirstName						--	DCH 2017-02-19
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(a.LastName))),'')) AS Hash_LastName						--	DCH 2017-02-19 
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(a.Suffix))),'')) AS Hash_Suffix 							--	DCH 2017-02-19
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(a.AddressPrimaryStreet))),'')) AS Hash_Address1_Line1 		--	DCH 2017-02-19
	  ,HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(LOWER(REPLACE(REPLACE(REPLACE(REPLACE(a.Phone,')',''),'(',''),'-',''),' ','')))),'')) AS Hash_Telephone1					--	DCH 2017-02-19
  FROM [dbo].Contact a 
INNER JOIN dbo.[CRMLoad_Contact_ProcessLoad_Criteria] c ON [c].[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]


GO
