SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CRMProcess_ConcatIDs]
@ObjectType VARCHAR(50)
AS

--DECLARE @ObjectType varchar(50) SET @ObjectType = 'Account'


/*
EXEC [dbo].[sp_CRMProcess_ConcatIDs] 'Account'
Select * from wrk.customerWorkingList
EXEC [dbo].[sp_CRMProcess_ConcatIDs] 'Contact'
Select * from stg.Contact
*/


SELECT        CASE WHEN @ObjectType = 'Account' THEN ssb_crmsystem_contactacct_id ELSE [SSB_CRMSYSTEM_CONTACT_ID] END GUID, CAST(a.DimCustomerId AS VARCHAR(100)) AS DimCustomerID, CAST(a.SSID AS VARCHAR(50)) AS SSID
, a.SourceSystem
INTO #tmpDimCustIDs
--DROP table #tmpDimCustIDs
FROM            dbo.DimCustomerssbid AS a 
WHERE        (1 = 1) 
--AND a.SourceSystem NOT LIKE 'Lead_%'
--AND SSID = '68:857237'
--AND a.[SSB_CRMSYSTEM_CONTACT_ID] = '4EAEED5A-E90E-4733-9AD5-07B1AF6E9724'
AND (a.[SSB_CRMSYSTEM_ACCT_ID] IN (SELECT SSB_CRMSYSTEM_ACCT_ID FROM DBO.vwCRMProcess_DistinctAccounts_CriteriaMet)
OR a.[SSB_CRMSYSTEM_CONTACT_ID] IN (SELECT SSB_CRMSYSTEM_CONTACT_ID FROM DBO.vwCRMProcess_DistinctContacts_CriteriaMet))
--AND [a].[SSB_CRMSYSTEM_ACCT_ID] = '7509A514-BB5F-42E7-8891-2EB8A1399ED3'
AND a.SourceSystem NOT LIKE '%SFDC%' AND a.SourceSystem NOT LIKE '%CRM%' --updateme
-- AND a.SSB_CRMSYSTEM_ACCT_PRIMARY_FLAG = 0
-- DROP TABLE #tmpDimCustIDs
-- SELECT * FROM #tmpDimCustIDs

TRUNCATE TABLE stg.tbl_CRMProcess_NonWinners

INSERT INTO [stg].tbl_CRMProcess_NonWinners
        ( [GUID] ,
          [DimCustomerID] ,
          [SourceSystem] ,
          [SSID],
		  CustomID1,
		  Primary_Flag,
		  AccountID
        )
SELECT GUID, a.DimCustomerID, a.[SourceSystem], CAST(a.SSID as varchar(50)) AS SSID, b.AccountId CustomID1, SSB_CRMSYSTEM_ACCT_PRIMARY_FLAG, AccountID
FROM #tmpDimCustIDs a 
INNER JOIN dbo.[vwDimCustomer_ModAcctId] b ON [b].[DimCustomerId] = [a].[DimCustomerID]
WHERE 1=1
--AND [a].[SSB_CRMSYSTEM_ACCT_ID] = '7509A514-BB5F-42E7-8891-2EB8A1399ED3'

TRUNCATE TABLE stg.[tbl_CRMProcess_ConcatIDs]

INSERT INTO stg.tbl_CRMProcess_ConcatIDs (GUID, ConcatIDs1, ConcatIDs2, ConcatIDs3, ConcatIDs4, ConcatIDs5, DimCust_ConcatIDs)
SELECT [GUID]
,ISNULL(LEFT(STUFF((    SELECT  ', ' + AccountID  AS [text()]
FROM stg.tbl_CRMProcess_NonWinners TM
WHERE TM.[GUID] = z.[GUID] AND tm.[SourceSystem] = 'TM'
ORDER BY SSID
FOR XML PATH('')), 1, 1, ''),8000),'') AS ConcatIDs1
,ISNULL(LEFT(STUFF((    SELECT  ', ' + AccountID  AS [text()]
FROM stg.tbl_CRMProcess_NonWinners TM
WHERE TM.[GUID] = z.[GUID] AND tm.[SourceSystem] = 'TM'
ORDER BY SSID
FOR XML PATH('')), 1, 1, ''),8000),'') AS ConcatIDs2
--,ISNULL(LEFT(STUFF((    SELECT  ', ' + CustomID1  AS [text()]
--FROM (SELECT CustomID1,[GUID], MAX(CAST(Primary_Flag as int)) Primary_Flag 
--		FROM stg.tbl_CRMProcess_NonWinners WHERE [SourceSystem] = 'Veritix' GROUP by CustomID1,[GUID]) acct
--WHERE acct.[GUID] = z.[GUID] 
--ORDER BY Primary_Flag desc, ', ' + CustomID1
--FOR XML PATH('')), 1, 1, ''),8000),'') AS ConcatIDs2
, '' ConcatIDs3
, '' ConcatIDs4
, '' ConcatIDs5
,LEFT(STUFF((    SELECT  ', ' + DimCustomerID  AS [text()]
FROM #tmpDimCustIDs DimCust
WHERE DimCust.GUID = z.GUID
ORDER BY [DimCustomerID]
FOR XML PATH('')), 1, 1, '' ),8000) as DimCustID_LoserString
--INTO #tmpA
FROM (SELECT DISTINCT GUID FROM [stg].tbl_CRMProcess_NonWinners
--WHERE GUID IN ('000001EC-E616-49AE-981A-A9B82F293D8B')
) z
-- Drop Table #LoserSSIDs
-- SELECT * FROM #tmpA Where Len(ConcatIDs1) > 8000
--SELECT * FROM stg.[tbl_CRMProcess_ConcatIDs] WHERE GUID = '4EAEED5A-E90E-4733-9AD5-07B1AF6E9724'

IF @ObjectType = 'Account'
UPDATE a
SET VX_Ids = ISNULL(LTRIM([b].[ConcatIDs1]),'')
, [AccountId] = ISNULL(LTRIM([b].[ConcatIDs2]),'')
, DimCustIDs = ISNULL(LTRIM([b].[DimCust_ConcatIDs]),'')
--, GP_Ids = ISNULL(LTRIM([b].[DimCust_ConcatIDs]),'')
-- SELECT b.* 
FROM dbo.Account_Custom a
INNER JOIN stg.[tbl_CRMProcess_ConcatIDs] b ON a.SSB_CRMSYSTEM_ACCT_ID = b.GUID

IF @ObjectType = 'Contact'
UPDATE a
SET VX_Ids = ISNULL(LTRIM([b].[ConcatIDs1]),'')
, [AccountId] = ISNULL(LTRIM([b].[ConcatIDs2]),'')
, DimCustIDs = ISNULL(LTRIM([b].[DimCust_ConcatIDs]),'')
--, GP_Ids = ISNULL(LTRIM([b].[DimCust_ConcatIDs]),'')
-- SELECT b.* 
FROM dbo.[Contact_Custom] a
INNER JOIN stg.[tbl_CRMProcess_ConcatIDs] b ON a.[SSB_CRMSYSTEM_CONTACT_ID] = b.GUID


IF @ObjectType = 'Contact'
UPDATE a
SET lions_primaryaccountid = CASE WHEN a.VX_Ids LIKE '%,%' THEN SUBSTRING(a.VX_Ids,1,CHARINDEX(',',a.VX_Ids,1)-1) ELSE a.VX_Ids end
-- SELECT b.* 
FROM dbo.[Contact_Custom] a
INNER JOIN stg.[tbl_CRMProcess_ConcatIDs] b ON a.[SSB_CRMSYSTEM_CONTACT_ID] = b.GUID








GO
