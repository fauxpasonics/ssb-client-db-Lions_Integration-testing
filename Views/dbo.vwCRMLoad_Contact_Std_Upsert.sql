SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
















CREATE VIEW [dbo].[vwCRMLoad_Contact_Std_Upsert] AS

SELECT u.new_ssbcrmsystemacctid, u.new_ssbcrmsystemcontactid, u.Prefix, u.FirstName, u.LastName, u.Suffix, u.address1_line1, u.address1_city,
	u.address1_stateorprovince, u.address1_postalcode, u.address1_country, u.telephone1, u.LoadType, u.emailaddress1
FROM [dbo].[vwCRMLoad_Contact_Std_Prep] u
left JOIN lions_reporting.prodcopy.contact c WITH (NOLOCK) ON u.firstname = c.firstname AND u.LastName = c.lastname AND ISNULL(u.Suffix,'') = ISNULL(c.suffix,'') AND  c.statecode = 0 AND c.emailaddress1 = u.emailaddress1 AND u.firstname != 'CBFC' AND u.FirstName != 'Suite' AND u.FirstName != 'soldier' AND u.FirstName != 'ticket'
left JOIN lions_reporting.prodcopy.contact d WITH (NOLOCK) ON u.firstname = d.firstname AND u.LastName = d.lastname AND ISNULL(u.Suffix,'') = ISNULL(d.suffix,'') AND  d.statecode = 0 AND isnull(d.address1_line1,'') = isnull(u.address1_line1,'') AND NULLIF(u.address1_line1, ' ') IS NOT NULL AND u.firstname != 'CBFC' AND u.FirstName != 'Suite' AND u.FirstName != 'soldier' AND u.FirstName != 'ticket'
WHERE 1 = 1 AND LoadType = 'Upsert' AND c.contactid IS NULL AND d.contactid IS null




















GO
