SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [wrk].[MergeDimCustomertoContact_dev]
AS

/*
SELECT * FROM dbo.[Contact] WHERE [DimCustIDs] IS NULL 
*/

--Capturing Temp for Downstream Bucketing. Needs to be moved to step before Account and Contact prep
TRUNCATE TABLE  wrk.tmp_DownstreamBucketing

INSERT INTO wrk.tmp_DownstreamBucketing
SELECT b.new, b.old, b.actiontype, b.mdm_run_dt, b.dimcustomerid, b.primaryflag, ma.SSB_CRMSYSTEM_CONTACT_ID, ma.SourceSystem, ma.SSID
FROM lions.mdm.downstream_bucketting b
LEFT JOIN dbo.vwDimCustomer_ModAcctId ma
ON b.dimcustomerid = ma.DimCustomerId
LEFT JOIN lions.mdm.PrimaryFlagRanking_Contact r
ON r.dimcustomerid = b.dimcustomerid
LEFT JOIN lions_Integration.dbo.Contact dbo
ON dbo.SSB_CRMSYSTEM_CONTACT_ID = ma.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN  [wrk].DownstreamBucketing_Timestamp idts ON 1=1
WHERE 1=1
AND b.mdm_run_dt > idts.[LastEnd]
AND ma.SourceSystem IN ('CRM_Contact', 'CRM_Account')


--Contact Specific
--Find all Splits where GUID changed
SELECT t.*, c.crm_id 
INTO #Splits
FROM wrk.tmp_DownstreamBucketing t
INNER JOIN dbo.contact_dev c
ON t.old = c.ssb_crmsystem_contact_id
WHERE t.actiontype = 'Contact split' AND t.old != t.new

--Update the Old GUID to the New GUID where the New GUID did not already exist in dbo.contact
UPDATE c
SET ssb_crmsystem_contact_id = dsb.new
FROM dbo.contact_dev c
INNER JOIN wrk.tmp_DownstreamBucketing dsb
ON dsb.old = c.ssb_crmsystem_contact_id
LEFT JOIN dbo.contact_dev n
ON n.ssb_crmsystem_contact_id = dsb.new
WHERE n.ssb_crmsystem_contact_id IS null









--Merges should take care of themselves here
DELETE a
--SELECT COUNT(*) 
FROM dbo.contact_dev a
LEFT JOIN dbo.[vwDimCustomer_ModAcctId] b ON [b].[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]
WHERE b.[DimCustomerId] IS NULL 

DELETE a
--SELECT COUNT(*) 
FROM dbo.contact_dev a
LEFT JOIN [dbo].[vwCRMProcess_DistinctContacts_CriteriaMet] b ON [b].[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]
WHERE b.[SSB_CRMSYSTEM_CONTACT_ID] IS NULL 


--peform merge ..update all contact ids that are eligible and cross them
-- TRUNCATE TABLE dbo.Account
MERGE INTO dbo.contact_dev AS target
USING  stg.Contact AS SOURCE 
ON target.[SSB_CRMSYSTEM_CONTACT_ID] = source.[SSB_CRMSYSTEM_CONTACT_ID]
WHEN MATCHED THEN UPDATE SET
TARGET.IsBusinessAccount = SOURCE.IsBusinessAccount
, TARGET.FullName = SOURCE.FullName
, TARGET.[Prefix] = SOURCE.[Prefix]
, TARGET.FirstName = SOURCE.FirstName
, TARGET.LastName = SOURCE.LastName
, TARGET.Suffix = SOURCE.Suffix
, TARGET.[AddressPrimaryStreet] = SOURCE.[AddressPrimaryStreet]
, TARGET.[AddressPrimaryCity] = SOURCE.[AddressPrimaryCity]
, TARGET.[AddressPrimaryState] = SOURCE.[AddressPrimaryState]
, TARGET.[AddressPrimaryZip] = SOURCE.[AddressPrimaryZip]
, TARGET.[AddressPrimaryCountry] = SOURCE.[AddressPrimaryCountry]
, TARGET.Phone = SOURCE.Phone
, TARGET.[EmailPrimary] = SOURCE.[EmailPrimary]
, TARGET.MDM_UpdatedDate = SOURCE.MDM_UpdatedDate
, TARGET.CRMProcess_UpdatedDate = SOURCE.CRMProcess_UpdatedDate
WHEN NOT MATCHED THEN 
INSERT 
(
		  SSB_CRMSYSTEM_ACCT_ID
        , SSB_CRMSYSTEM_CONTACT_ID
		, IsBusinessAccount
        , FullName
		, [Prefix]
        , FirstName
        , LastName
		, Suffix
        , [AddressPrimaryStreet]
		, [AddressPrimaryCity]
		, [AddressPrimaryState]
		, [AddressPrimaryZip]
		, [AddressPrimaryCountry]
		, Phone
        , [EmailPrimary]
        , MDM_UpdatedDate
        , CRMProcess_UpdatedDate
		, crm_id
)
VALUES
(
		  SOURCE.SSB_CRMSYSTEM_ACCT_ID
		, SOURCE.SSB_CRMSYSTEM_CONTACT_ID
		, SOURCE.IsBusinessAccount
		, SOURCE.FullName
		, SOURCE.[Prefix]
		, SOURCE.FirstName
		, SOURCE.LastName
		, SOURCE.Suffix
		, SOURCE.[AddressPrimaryStreet]
		, SOURCE.[AddressPrimaryCity]
		, SOURCE.[AddressPrimaryState]
		, SOURCE.[AddressPrimaryZip]
		, SOURCE.[AddressPrimaryCountry]
		, SOURCE.Phone
		, SOURCE.EmailPrimary
		, SOURCE.MDM_UpdatedDate
		, SOURCE.CRMProcess_UpdatedDate
		, source.[SSB_CRMSYSTEM_CONTACT_ID]
);






GO
