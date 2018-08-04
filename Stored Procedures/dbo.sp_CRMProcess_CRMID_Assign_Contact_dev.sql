SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[sp_CRMProcess_CRMID_Assign_Contact_dev]
AS

DECLARE @ObjectType NVARCHAR(100) SET @ObjectType = 'Contact'
DECLARE @SourceSystem NVARCHAR(100) SET @SourceSystem = 'CRM_Contact'

--Wipe out crm_id where CRM record has been deleted
UPDATE a
SET crm_Id = a.SSB_CRMSYSTEM_CONTACT_ID
FROM dbo.contact_dev a
LEFT JOIN prodcopy.contact b
ON a.crm_id = b.contactid
WHERE b.contactid IS NULL 
OR b.statecode = 1


--Wipe out crm_ids where the existing crm_id is no longer the #1 ranked CRM record in MDM
SELECT t.*, c.crm_id--, r.ss_ranking
INTO #Merges
FROM wrk.tmp_DownstreamBucketing t
inner JOIN dbo.contact_dev c
ON t.new = c.ssb_crmsystem_contact_id
INNER JOIN lions.mdm.PrimaryFlagRanking_Contact r
ON r.ssid = c.crm_id
WHERE t.actiontype = 'Contact merge'
AND r.ss_ranking != 1
ORDER BY r.ss_ranking DESC


UPDATE dbo.contact_dev
SET crm_id = c.ssb_crmsystem_contact_id
FROM dbo.contact_dev c
INNER JOIN #Merges m
ON m.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID


--update crm_ids based on source system ranking
UPDATE a
SET [crm_id] =  b.ssid 
-- SELECT COUNT(*) 
FROM dbo.contact_dev a
INNER JOIN dbo.[vwDimCustomer_ModAcctId] b ON a.SSB_CRMSYSTEM_contact_ID = b.SSB_CRMSYSTEM_contact_ID AND b.SourceSystem = 'CRM_Contact'
INNER JOIN lions.mdm.PrimaryFlagRanking_Contact r
ON b.DimCustomerId = r.dimcustomerid AND r.ss_ranking = 1
LEFT JOIN (SELECT crm_id FROM dbo.contact WHERE crm_id <> [SSB_CRMSYSTEM_CONTACT_ID]) c ON b.ssid = c.[crm_id]
WHERE  a.[crm_id] != b.ssid --updateme
 AND c.[crm_id] IS NULL 



 --records in dbo.contact where the ss_ranking is not being taken into account. For QA purposes only
 --SELECT c.SSB_CRMSYSTEM_CONTACT_ID, c.crm_id, r.ranking, rc.ssid 
 --FROM dbo.contact c
 --INNER JOIN dbo.vwDimCustomer_ModAcctId ma
 --ON c.SSB_CRMSYSTEM_CONTACT_ID = ma.SSB_CRMSYSTEM_CONTACT_ID AND ma.SourceSystem = 'crm_contact' AND c.crm_id = ma.SSID
 --INNER JOIN lions.mdm.PrimaryFlagRanking_Contact r
 --ON ma.DimCustomerId = r.dimcustomerid 
 --INNER JOIN lions.mdm.PrimaryFlagRanking_Contact rc ON rc.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID AND rc.sourcesystem = 'CRM_Contact' AND rc.ss_ranking = 1
 --where r.ss_ranking != 1


--This is really just for handling GUID changes and is from the old standard. The downstream bucketing should be accounting for this.
UPDATE a
SET a.crm_id = b.contactid
-- SELECT COUNT(*)
FROM dbo.contact_dev a
INNER JOIN prodcopy.vw_contact b ON a.SSB_CRMSYSTEM_contact_ID = b.new_ssbcrmsystemcontactid
LEFT JOIN (SELECT [crm_id] FROM dbo.contact WHERE crm_id <> [SSB_CRMSYSTEM_CONTACT_ID]) c ON b.contactid = c.crm_id
WHERE ISNULL(a.[crm_id], '') != b.contactid 
AND c.crm_id IS NULL	
---and b.id = '0033800002JUEoUAAX'






 --Needs to be moved to the last steps before push (after all downstream bucketing steps have completed


 UPDATE [wrk].DownstreamBucketing_Timestamp
 SET lastend = laststart
FROM  [wrk].DownstreamBucketing_Timestamp




GO
