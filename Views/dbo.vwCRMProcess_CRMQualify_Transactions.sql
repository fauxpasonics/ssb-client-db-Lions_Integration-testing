SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwCRMProcess_CRMQualify_Transactions]
as
SELECT b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_CONTACT_ID, DimCustomerId
--, [b].[SourceSystem]
, MAX(a.MaxTransDate) MaxTransDate
--SELECT a.SSID, a.MaxTransDate, a.Team
--SELECT * 
FROM [stg].[CRMProcess_RecentTrans_SSIDs] a 
INNER JOIN [dbo].[vwDimCustomer_ModAcctId] b ON b.SSID = a.SSID
WHERE b.SSB_CRMSYSTEM_ACCT_ID IS NOT NULL
--AND b.SourceSystem = 'Veritix' 
--AND a.[MaxTransDate] >= DATEADD(YEAR,-2,GETDATE())
GROUP BY b.SSB_CRMSYSTEM_ACCT_ID, b.SSB_CRMSYSTEM_CONTACT_ID, DimCustomerId
--, b.Sourcesystem
-- DROP TABLE #tmpTrans
--SELECT * FROM #tmpTrans
GO
