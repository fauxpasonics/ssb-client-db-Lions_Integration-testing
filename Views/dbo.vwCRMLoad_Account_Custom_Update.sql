SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vwCRMLoad_Account_Custom_Update]
AS

SELECT  z.[crm_id] accountid
,b.new_ssbcrmsystemssidwinner
,b.new_ssbcrmsystemSSIDWinnerSourceSystem
, b.VX_Ids str_number
, DimCustIDs new_ssbcrmsystemdimcustomerids
--, b.AccountId [new_ssbcrmsystemarchticsids]
-- SELECT *
-- SELECT COUNT(*) 
FROM dbo.[Account_Custom] b 
INNER JOIN dbo.Account z ON b.SSB_CRMSYSTEM_Acct_ID = z.[SSB_CRMSYSTEM_Acct_ID]
LEFT JOIN  prodcopy.vw_Account c ON z.[crm_id] = c.AccountID
----INNER JOIN dbo.CRMLoad_Acct_ProcessLoad_Criteria pl ON b.SSB_CRMSYSTEM_Acct_ID = pl.SSB_CRMSYSTEM_Acct_ID
LEFT JOIN Lions.[dbo].[vw_KeyAccounts] k --updateme
		ON z.crm_ID = k.SSID
WHERE z.[SSB_CRMSYSTEM_Acct_ID] <> z.[crm_id]
AND k.SSID IS NULL
--AND  (HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssbcrmsystemSSIDWinner)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssbcrmsystemssidwinner AS VARCHAR(MAX)))),'')) 
--	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.DimCustIDs)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.new_ssbcrmsystemdimcustomerids AS VARCHAR(MAX)))),'')) 
--	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.new_ssbcrmsystemSSIDWinnerSourceSystem)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.[new_ssbcrmsystemSSIDWinnerSourceSystem] AS VARCHAR(MAX)))),''))
--	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(b.VX_Ids)),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(c.[str_number] AS VARCHAR(MAX)))),''))
--	)
	AND ( 
 ISNULL(b.new_ssbcrmsystemssidwinner,'') != ISNULL(c.new_ssbcrmsystemssidwinner,'')
OR ISNULL(b.new_ssbcrmsystemSSIDWinnerSourceSystem,'') != ISNULL(c.new_ssbcrmsystemSSIDWinnerSourceSystem,'')
OR ISNULL(b.VX_Ids,'') != ISNULL(c.str_number,'')
OR ISNULL(b.DimCustIDs,'') != ISNULL(c.new_ssbcrmsystemdimcustomerids,'')
)

GO
