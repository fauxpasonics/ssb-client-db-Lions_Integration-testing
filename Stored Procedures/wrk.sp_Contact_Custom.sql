SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************
Created By: Caeleon Work
Created On: 
Updated By: Stephanie Gerber
Update Date: 2018-06-06
Update Notes: Added actual veritix account number, Added historical archtics account number, Added historical (before Archtics) account number
Reviewed By: Caeleon Work
Review Date: 2018-06-14
Review Notes: Stuff was added. Logic looks good.
**************************************************/

CREATE   PROCEDURE [wrk].[sp_Contact_Custom]
AS 

MERGE INTO dbo.Contact_Custom Target
USING dbo.Contact source
ON source.[SSB_CRMSYSTEM_CONTACT_ID] = target.[SSB_CRMSYSTEM_CONTACT_ID]
WHEN NOT MATCHED BY TARGET THEN
INSERT ([SSB_CRMSYSTEM_ACCT_ID], [SSB_CRMSYSTEM_CONTACT_ID]) VALUES (source.[SSB_CRMSYSTEM_ACCT_ID], Source.[SSB_CRMSYSTEM_CONTACT_ID])
WHEN NOT MATCHED BY SOURCE THEN
DELETE ;

EXEC dbo.sp_CRMProcess_ConcatIDs 'Contact';


 --Update ParentCustomerID From SSBID table
 WITH Accounts as (
SELECT c.SSB_CRMSYSTEM_CONTACT_ID, ssb.ssid, ROW_NUMBER() OVER (PARTITION BY c.SSB_CRMSYSTEM_CONTACT_ID ORDER BY ssb.SSB_CRMSYSTEM_PRIMARY_FLAG, dc.SSCreatedDate) accountrank   FROM dbo.Contact c
INNER JOIN dbo.DimCustomerssbid ssb ON ssb.SSB_CRMSYSTEM_ACCT_ID = c.SSB_CRMSYSTEM_ACCT_ID AND ssb.SourceSystem = 'crm_account' 
INNER JOIN dbo.dimcustomer dc ON dc.DimCustomerId = ssb.DimCustomerId

) 

UPDATE cc SET cc.parentcustomerid = a.SSID, cc.parentcustomeridtype = 'account'
FROM dbo.Contact_Custom cc 
INNER JOIN Accounts a ON a.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID;

--Override SSBID with anything that is already in CRM
UPDATE cc SET parentcustomerid = pc.parentcustomerid, parentcustomeridtype = pc.parentcustomeridtype
FROM dbo.contact_custom cc
INNER JOIN dbo.contact c
ON c.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN Prodcopy.vw_Contact pc
ON pc.contactid = c.crm_id
WHERE pc.parentcustomeridname IS NOT NULL;


--UPDATE a
--SET SeasonTicket_Years = recent.SeasonTicket_Years
----SELECT *
--FROM dbo.[Contact_Custom] a
--INNER JOIN dbo.CRMProcess_DistinctContacts recent ON [recent].[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]

UPDATE a
SET SSID_Winner = CASE WHEN b.sourcesystem = 'Veritix' then CAST(b.AccountID AS nvarchar(100)) ELSE b.[SSID] end, 
	a.new_ssbcrmsystemSSIDWinnerSourceSystem = b.SourceSystem, 
	mobilephone = b.PhoneCell, 
	telephone2 = b.PhoneHome
FROM [dbo].Contact_Custom a
INNER JOIN dbo.[vwCompositeRecord_ModAcctID] b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]

--Owner - Update with CRM baseline
UPDATE a
SET ownerid = pcc.ownerid,  a.owneridtype  = pcc.owneridtype
FROM dbo.Contact_Custom a
INNER JOIN dbo.contact c
ON c.SSB_CRMSYSTEM_CONTACT_ID = a.SSB_CRMSYSTEM_CONTACT_ID
INNER JOIN Prodcopy.vw_Contact pcc
ON pcc.contactid = c.crm_id

--Update SalesRep based on Veritix
UPDATE a
SET OwnerID = su.systemuserid, a.owneridtype = 'systemuser'
FROM [dbo].Contact_Custom a
INNER JOIN dbo.[vwCompositeRecord_ModAcctID] b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]
INNER JOIN Lions_Reporting.prodcopy.SystemUser su ON b.accountrep = su.new_veritixuserid AND su.new_veritixuserid IS NOT NULL AND su.isdisabled = 0

--Update SalesRep based on TM -- new_TMUserID is in place, but not populated due to lack of data on the TM side.
UPDATE a
SET OwnerID = su.systemuserid, a.owneridtype = 'systemuser'
FROM [dbo].Contact_Custom a
INNER JOIN dbo.[vwCompositeRecord_ModAcctID] b ON b.[SSB_CRMSYSTEM_CONTACT_ID] = [a].[SSB_CRMSYSTEM_CONTACT_ID]
inner JOIN Lions_Reporting.prodcopy.SystemUser su ON b.accountrep = su.fullname AND ISNULL(su.fullname,'') != '' AND su.isdisabled = 0




--APPENDS

SELECT ma.SSB_CRMSYSTEM_CONTACT_ID
, MAX(NULLIF([Personicx Lifestage Cluster Code],'')) as lions_dem_PersonicxCluster
, MAX(NULLIF([a].[Business Owner],'')) as lions_dem_BusinessOwner
, MAX(NULLIF(a.Veteran,'')) as lions_dem_Veteran
, MAX(NULLIF(a.[Occupation - Detail - Input Individual],'')) as lions_dem_OccupationDetail
, MAX(NULLIF(a.[Home Property Type Detail (RP)],'')) as lions_dem_HomePropertyType
, MAX(NULLIF(a.[Home Year Built - Actual (RP)],'')) as lions_dem_HomeYearBuilt
, MAX(NULLIF(a.[Home Owner   Renter],'')) as lions_dem_HomeOwnerRenter
, MAX(NULLIF(a.[Home Length of Residence],'')) as lions_dem_HomeLengthofResidence
, MAX(NULLIF(a.[Presence of Children],'')) as lions_dem_PresenceofChildren
, MAX(NULLIF(a.[Age in Two-Year Increments - Input Individual],'')) as str_agerange
, MAX(NULLIF(a.[Occupation - Input Individual],'')) as lions_dem_Occupation
, MAX(NULLIF(a.[Income - Estimated Household],'')) as str_householdincome
, MAX(NULLIF(a.[Home Market Value - Estimated - Ranges],'')) as lions_dem_HomeMarketValue
, MAX(NULLIF(a.[Vehicle - New Car Buyer],'')) as lions_dem_NewCarBuyer
, MAX(NULLIF(a.[Vehicle - Known Owned Number],'')) as lions_dem_KnownOwnedVehicles
, MAX(NULLIF(a.[Vehicle - Dominant Lifestyle Indicator],'')) as lions_dem_DominantVehicleLifestyle
, MAX(NULLIF(a.[Education - Input Individual],'')) as lions_dem_EducationLevel
, MAX(NULLIF(a.[Marital Status],'')) as familystatuscode
INTO #appendstemp
FROM lions.ods.Appends a
INNER JOIN dbo.vwDimCustomer_ModAcctId ma ON a.ETL__SSID = ma.SSID AND ma.SourceSystem = 'Appends'
INNER JOIN dbo.contact_custom cc ON cc.SSB_CRMSYSTEM_CONTACT_ID = ma.SSB_CRMSYSTEM_CONTACT_ID
GROUP BY ma.SSB_CRMSYSTEM_CONTACT_ID


UPDATE cc
SET 
--cc.lions_dem_DistancetoStadium = --NOPE
cc.lions_dem_PersonicxCluster = 	CASE	 
			WHEN temp.lions_dem_PersonicxCluster = '1' THEN ' Summit Estates'
			WHEN temp.lions_dem_PersonicxCluster = '2' THEN ' Established Elite'
			WHEN temp.lions_dem_PersonicxCluster = '3' THEN ' Corporate Connections'
			WHEN temp.lions_dem_PersonicxCluster = '4' THEN ' Top Professionals'
			WHEN temp.lions_dem_PersonicxCluster = '5' THEN ' Active & Involved'
			WHEN temp.lions_dem_PersonicxCluster = '6' THEN ' Casual Comfort'
			WHEN temp.lions_dem_PersonicxCluster = '7' THEN ' Active Lifestyles'
			WHEN temp.lions_dem_PersonicxCluster = '8' THEN ' Solid Surroundings'
			WHEN temp.lions_dem_PersonicxCluster = '9' THEN ' Busy Schedules'
			WHEN temp.lions_dem_PersonicxCluster = '10' THEN ' Careers & Travel'
			WHEN temp.lions_dem_PersonicxCluster = '11' THEN ' Schools & Shopping'
			WHEN temp.lions_dem_PersonicxCluster = '12' THEN ' On the Go'
			WHEN temp.lions_dem_PersonicxCluster = '13' THEN ' Work & Play'
			WHEN temp.lions_dem_PersonicxCluster = '14' THEN ' Career Centered'
			WHEN temp.lions_dem_PersonicxCluster = '15' THEN ' Country Ways'
			WHEN temp.lions_dem_PersonicxCluster = '16' THEN ' Country Enthusiasts'
			WHEN temp.lions_dem_PersonicxCluster = '17' THEN ' Firmly Established'
			WHEN temp.lions_dem_PersonicxCluster = '18' THEN ' Climbing the Ladder'
			WHEN temp.lions_dem_PersonicxCluster = '19' THEN ' Country Comfort'
			WHEN temp.lions_dem_PersonicxCluster = '20' THEN ' Carving Out Time'
			WHEN temp.lions_dem_PersonicxCluster = '21' THEN ' Children First'
			WHEN temp.lions_dem_PersonicxCluster = '22' THEN ' Comfortable Cornerstones'
			WHEN temp.lions_dem_PersonicxCluster = '23' THEN ' Good Neighbors'
			WHEN temp.lions_dem_PersonicxCluster = '24' THEN ' Career Building'
			WHEN temp.lions_dem_PersonicxCluster = '25' THEN ' Clubs & Causes'
			WHEN temp.lions_dem_PersonicxCluster = '26' THEN ' Getting Established'
			WHEN temp.lions_dem_PersonicxCluster = '27' THEN ' Tenured Proprietors'
			WHEN temp.lions_dem_PersonicxCluster = '28' THEN ' Community Pillars'
			WHEN temp.lions_dem_PersonicxCluster = '29' THEN ' City Mixers'
			WHEN temp.lions_dem_PersonicxCluster = '30' THEN ' Out & About'
			WHEN temp.lions_dem_PersonicxCluster = '31' THEN ' Mid-Americana'
			WHEN temp.lions_dem_PersonicxCluster = '32' THEN ' Metro Mix'
			WHEN temp.lions_dem_PersonicxCluster = '33' THEN ' Urban Diversity'
			WHEN temp.lions_dem_PersonicxCluster = '34' THEN ' Outward Bound'
			WHEN temp.lions_dem_PersonicxCluster = '35' THEN ' Working & Active'
			WHEN temp.lions_dem_PersonicxCluster = '36' THEN ' Persistent & Productive'
			WHEN temp.lions_dem_PersonicxCluster = '37' THEN ' Firm Foundations'
			WHEN temp.lions_dem_PersonicxCluster = '38' THEN ' Occupational Mix'
			WHEN temp.lions_dem_PersonicxCluster = '39' THEN ' Setting Goals'
			WHEN temp.lions_dem_PersonicxCluster = '40' THEN ' Great Outdoors'
			WHEN temp.lions_dem_PersonicxCluster = '41' THEN ' Rural Adventure'
			WHEN temp.lions_dem_PersonicxCluster = '42' THEN ' Creative Variety'
			WHEN temp.lions_dem_PersonicxCluster = '43' THEN ' Work & Causes'
			WHEN temp.lions_dem_PersonicxCluster = '44' THEN ' Open Houses'
			WHEN temp.lions_dem_PersonicxCluster = '45' THEN ' Offices & Entertainment'
			WHEN temp.lions_dem_PersonicxCluster = '46' THEN ' Rural & Active'
			WHEN temp.lions_dem_PersonicxCluster = '47' THEN ' Rural Parents'
			WHEN temp.lions_dem_PersonicxCluster = '48' THEN ' Farm & Home'
			WHEN temp.lions_dem_PersonicxCluster = '49' THEN ' Home & Garden'
			WHEN temp.lions_dem_PersonicxCluster = '50' THEN ' Rural Community'
			WHEN temp.lions_dem_PersonicxCluster = '51' THEN ' Role Models'
			WHEN temp.lions_dem_PersonicxCluster = '52' THEN ' Stylish & Striving'
			WHEN temp.lions_dem_PersonicxCluster = '53' THEN ' Metro Strivers'
			WHEN temp.lions_dem_PersonicxCluster = '54' THEN ' Work & Outdoors'
			WHEN temp.lions_dem_PersonicxCluster = '55' THEN ' Community Life'
			WHEN temp.lions_dem_PersonicxCluster = '56' THEN ' Metro Active'
			WHEN temp.lions_dem_PersonicxCluster = '57' THEN ' Collegiate Crowd'
			WHEN temp.lions_dem_PersonicxCluster = '58' THEN ' Outdoor Fervor'
			WHEN temp.lions_dem_PersonicxCluster = '59' THEN ' Mobile Mixers'
			WHEN temp.lions_dem_PersonicxCluster = '60' THEN ' Rural & Mobile'
			WHEN temp.lions_dem_PersonicxCluster = '61' THEN ' City Life'
			WHEN temp.lions_dem_PersonicxCluster = '62' THEN ' Movies & Sports'
			WHEN temp.lions_dem_PersonicxCluster = '63' THEN ' Staying Home'
			WHEN temp.lions_dem_PersonicxCluster = '64' THEN ' Practical & Careful'
			WHEN temp.lions_dem_PersonicxCluster = '65' THEN ' Hobbies & Shopping'
			WHEN temp.lions_dem_PersonicxCluster = '66' THEN ' Helping Hands'
			WHEN temp.lions_dem_PersonicxCluster = '67' THEN ' First Steps'
			WHEN temp.lions_dem_PersonicxCluster = '68' THEN ' Staying Healthy'
			WHEN temp.lions_dem_PersonicxCluster = '69' THEN ' Productive Havens'
			WHEN temp.lions_dem_PersonicxCluster = '70' THEN ' Favorably Frugal'
			ELSE NULL END

,cc.lions_dem_BusinessOwner = 			 CASE
			WHEN temp.lions_dem_BusinessOwner = 'A ' THEN ' Accountant'
			WHEN temp.lions_dem_BusinessOwner = 'B ' THEN ' Builder'
			WHEN temp.lions_dem_BusinessOwner = 'C ' THEN ' Contractor'
			WHEN temp.lions_dem_BusinessOwner = 'D ' THEN ' Dealer/Retailer/Storekeeper'
			WHEN temp.lions_dem_BusinessOwner = 'E ' THEN ' Distributor/Wholesaler'
			WHEN temp.lions_dem_BusinessOwner = 'F ' THEN ' Funeral Director'
			WHEN temp.lions_dem_BusinessOwner = 'M ' THEN ' Maker/Manufacturer'
			WHEN temp.lions_dem_BusinessOwner = 'O ' THEN ' Owner'
			WHEN temp.lions_dem_BusinessOwner = 'P ' THEN ' Partner'
			WHEN temp.lions_dem_BusinessOwner = 'S ' THEN ' Self-Employed'
			ELSE NULL END

,cc.lions_dem_Veteran		=			 temp.lions_dem_Veteran

,cc.lions_dem_OccupationDetail = 		 CASE
			WHEN temp.lions_dem_OccupationDetail = 'A000' THEN 'Professional'
			WHEN temp.lions_dem_OccupationDetail = 'A001' THEN 'Architect'
			WHEN temp.lions_dem_OccupationDetail = 'A002' THEN 'Chemist'
			WHEN temp.lions_dem_OccupationDetail = 'A003' THEN 'Curator'
			WHEN temp.lions_dem_OccupationDetail = 'A004' THEN 'Engineer'
			WHEN temp.lions_dem_OccupationDetail = 'A005' THEN 'Engineer/Aerospace'
			WHEN temp.lions_dem_OccupationDetail = 'A006' THEN 'Engineer/Chemical'
			WHEN temp.lions_dem_OccupationDetail = 'A007' THEN 'Engineer/Civil'
			WHEN temp.lions_dem_OccupationDetail = 'A008' THEN 'Engineer/Electrical/Electronic'
			WHEN temp.lions_dem_OccupationDetail = 'A009' THEN 'Engineer/Field'
			WHEN temp.lions_dem_OccupationDetail = 'A010' THEN 'Engineer/Industrial'
			WHEN temp.lions_dem_OccupationDetail = 'A011' THEN 'Engineer/Mechanical'
			WHEN temp.lions_dem_OccupationDetail = 'A012' THEN 'Geologist'
			WHEN temp.lions_dem_OccupationDetail = 'A013' THEN 'Home Economist'
			WHEN temp.lions_dem_OccupationDetail = 'A014' THEN 'Legal/Attorney/Lawyer'
			WHEN temp.lions_dem_OccupationDetail = 'A015' THEN 'Librarian/Archivist'
			WHEN temp.lions_dem_OccupationDetail = 'A016' THEN 'Medical Doctor/Physician'
			WHEN temp.lions_dem_OccupationDetail = 'A017' THEN 'Pastor'
			WHEN temp.lions_dem_OccupationDetail = 'A018' THEN 'Pilot'
			WHEN temp.lions_dem_OccupationDetail = 'A019' THEN 'Scientist'
			WHEN temp.lions_dem_OccupationDetail = 'A020' THEN 'Statistician/Actuary'
			WHEN temp.lions_dem_OccupationDetail = 'A021' THEN 'Veterinarian'
			WHEN temp.lions_dem_OccupationDetail = 'B000' THEN 'Executive/Upper Management'
			WHEN temp.lions_dem_OccupationDetail = 'B001' THEN 'CEO/CFO/Chairman/Corp Officer'
			WHEN temp.lions_dem_OccupationDetail = 'B002' THEN 'Comptroller'
			WHEN temp.lions_dem_OccupationDetail = 'B003' THEN 'Politician/Legislator/Diplomat'
			WHEN temp.lions_dem_OccupationDetail = 'B004' THEN 'President'
			WHEN temp.lions_dem_OccupationDetail = 'B005' THEN 'Treasurer'
			WHEN temp.lions_dem_OccupationDetail = 'B006' THEN 'Vice President'
			WHEN temp.lions_dem_OccupationDetail = 'C000' THEN 'Middle Management'
			WHEN temp.lions_dem_OccupationDetail = 'C001' THEN 'Account Executive'
			WHEN temp.lions_dem_OccupationDetail = 'C002' THEN 'Director/Art Director'
			WHEN temp.lions_dem_OccupationDetail = 'C003' THEN 'Director/Executive Director'
			WHEN temp.lions_dem_OccupationDetail = 'C004' THEN 'Editor'
			WHEN temp.lions_dem_OccupationDetail = 'C005' THEN 'Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C006' THEN 'Manager/Assistant Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C007' THEN 'Manager/Branch Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C008' THEN 'Manager/Credit Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C009' THEN 'Manager/District Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C010' THEN 'Manager/Division Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C011' THEN 'Manager/General Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C012' THEN 'Manager/Marketing Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C013' THEN 'Manager/Office Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C014' THEN 'Manager/Plant Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C015' THEN 'Manager/Product Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C016' THEN 'Manager/Project Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C017' THEN 'Manager/Property Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C018' THEN 'Manager/Regional Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C019' THEN 'Manager/Sales Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C020' THEN 'Manager/Store Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C021' THEN 'Manager/Traffic Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C022' THEN 'Manager/Warehouse Manager'
			WHEN temp.lions_dem_OccupationDetail = 'C023' THEN 'Planner'
			WHEN temp.lions_dem_OccupationDetail = 'C024' THEN 'Principal/Dean/Educator'
			WHEN temp.lions_dem_OccupationDetail = 'C025' THEN 'Superintendent'
			WHEN temp.lions_dem_OccupationDetail = 'C026' THEN 'Supervisor'
			WHEN temp.lions_dem_OccupationDetail = 'D000' THEN 'White Collar Worker'
			WHEN temp.lions_dem_OccupationDetail = 'D001' THEN 'Accounting/Biller/Billing clerk'
			WHEN temp.lions_dem_OccupationDetail = 'D002' THEN 'Actor/Entertainer/Announcer'
			WHEN temp.lions_dem_OccupationDetail = 'D003' THEN 'Adjuster'
			WHEN temp.lions_dem_OccupationDetail = 'D004' THEN 'Administration/Management'
			WHEN temp.lions_dem_OccupationDetail = 'D005' THEN 'Advertising'
			WHEN temp.lions_dem_OccupationDetail = 'D006' THEN 'Agent'
			WHEN temp.lions_dem_OccupationDetail = 'D007' THEN 'Aide/Assistant'
			WHEN temp.lions_dem_OccupationDetail = 'D008' THEN 'Aide/Assistant/Executive'
			WHEN temp.lions_dem_OccupationDetail = 'D009' THEN 'Aide/Assistant/Office'
			WHEN temp.lions_dem_OccupationDetail = 'D010' THEN 'Aide/Assistant/School'
			WHEN temp.lions_dem_OccupationDetail = 'D011' THEN 'Aide/Assistant/Staff'
			WHEN temp.lions_dem_OccupationDetail = 'D012' THEN 'Aide/Assistant/Technical'
			WHEN temp.lions_dem_OccupationDetail = 'D013' THEN 'Analyst'
			WHEN temp.lions_dem_OccupationDetail = 'D014' THEN 'Appraiser'
			WHEN temp.lions_dem_OccupationDetail = 'D015' THEN 'Artist'
			WHEN temp.lions_dem_OccupationDetail = 'D016' THEN 'Auctioneer'
			WHEN temp.lions_dem_OccupationDetail = 'D017' THEN 'Auditor'
			WHEN temp.lions_dem_OccupationDetail = 'D018' THEN 'Banker'
			WHEN temp.lions_dem_OccupationDetail = 'D019' THEN 'Banker/Loan Office'
			WHEN temp.lions_dem_OccupationDetail = 'D020' THEN 'Banker/Loan Processor'
			WHEN temp.lions_dem_OccupationDetail = 'D021' THEN 'Bookkeeper'
			WHEN temp.lions_dem_OccupationDetail = 'D022' THEN 'Broker'
			WHEN temp.lions_dem_OccupationDetail = 'D023' THEN 'Broker/Stock/Trader'
			WHEN temp.lions_dem_OccupationDetail = 'D024' THEN 'Buyer'
			WHEN temp.lions_dem_OccupationDetail = 'D025' THEN 'Cashier'
			WHEN temp.lions_dem_OccupationDetail = 'D026' THEN 'Caterer'
			WHEN temp.lions_dem_OccupationDetail = 'D027' THEN 'Checker'
			WHEN temp.lions_dem_OccupationDetail = 'D028' THEN 'Claims Examiner/Rep/Adjudicator'
			WHEN temp.lions_dem_OccupationDetail = 'D029' THEN 'Clerk'
			WHEN temp.lions_dem_OccupationDetail = 'D030' THEN 'Clerk/File'
			WHEN temp.lions_dem_OccupationDetail = 'D031' THEN 'Collector'
			WHEN temp.lions_dem_OccupationDetail = 'D032' THEN 'Communications'
			WHEN temp.lions_dem_OccupationDetail = 'D033' THEN 'Conservation/Environment'
			WHEN temp.lions_dem_OccupationDetail = 'D034' THEN 'Consultant/Advisor'
			WHEN temp.lions_dem_OccupationDetail = 'D035' THEN 'Coordinator'
			WHEN temp.lions_dem_OccupationDetail = 'D036' THEN 'Customer Service/Representative'
			WHEN temp.lions_dem_OccupationDetail = 'D037' THEN 'Designer'
			WHEN temp.lions_dem_OccupationDetail = 'D038' THEN 'Detective/Investigator'
			WHEN temp.lions_dem_OccupationDetail = 'D039' THEN 'Dispatcher'
			WHEN temp.lions_dem_OccupationDetail = 'D040' THEN 'Draftsman'
			WHEN temp.lions_dem_OccupationDetail = 'D041' THEN 'Estimator'
			WHEN temp.lions_dem_OccupationDetail = 'D042' THEN 'Expeditor'
			WHEN temp.lions_dem_OccupationDetail = 'D043' THEN 'Finance'
			WHEN temp.lions_dem_OccupationDetail = 'D044' THEN 'Flight Attendant/Steward'
			WHEN temp.lions_dem_OccupationDetail = 'D045' THEN 'Florist'
			WHEN temp.lions_dem_OccupationDetail = 'D046' THEN 'Graphic Designer/Commercial Artist'
			WHEN temp.lions_dem_OccupationDetail = 'D047' THEN 'Hostess/Host/Usher'
			WHEN temp.lions_dem_OccupationDetail = 'D048' THEN 'Insurance/Agent'
			WHEN temp.lions_dem_OccupationDetail = 'D049' THEN 'Insurance/Underwriter'
			WHEN temp.lions_dem_OccupationDetail = 'D050' THEN 'Interior Designer'
			WHEN temp.lions_dem_OccupationDetail = 'D051' THEN 'Jeweler'
			WHEN temp.lions_dem_OccupationDetail = 'D052' THEN 'Marketing'
			WHEN temp.lions_dem_OccupationDetail = 'D053' THEN 'Merchandiser'
			WHEN temp.lions_dem_OccupationDetail = 'D054' THEN 'Model'
			WHEN temp.lions_dem_OccupationDetail = 'D055' THEN 'Musician/Music/Dance'
			WHEN temp.lions_dem_OccupationDetail = 'D056' THEN 'Personnel/Recruiter/Interviewer'
			WHEN temp.lions_dem_OccupationDetail = 'D057' THEN 'Photography'
			WHEN temp.lions_dem_OccupationDetail = 'D058' THEN 'Public Relations'
			WHEN temp.lions_dem_OccupationDetail = 'D059' THEN 'Publishing'
			WHEN temp.lions_dem_OccupationDetail = 'D060' THEN 'Purchasing'
			WHEN temp.lions_dem_OccupationDetail = 'D061' THEN 'Quality Control'
			WHEN temp.lions_dem_OccupationDetail = 'D062' THEN 'Real Estate/Realtor'
			WHEN temp.lions_dem_OccupationDetail = 'D063' THEN 'Receptionist'
			WHEN temp.lions_dem_OccupationDetail = 'D064' THEN 'Reporter'
			WHEN temp.lions_dem_OccupationDetail = 'D065' THEN 'Researcher'
			WHEN temp.lions_dem_OccupationDetail = 'D066' THEN 'Sales'
			WHEN temp.lions_dem_OccupationDetail = 'D067' THEN 'Sales Clerk/Counterman'
			WHEN temp.lions_dem_OccupationDetail = 'D068' THEN 'Security'
			WHEN temp.lions_dem_OccupationDetail = 'D069' THEN 'Surveyor'
			WHEN temp.lions_dem_OccupationDetail = 'D070' THEN 'Technician'
			WHEN temp.lions_dem_OccupationDetail = 'D071' THEN 'Telemarketer/Telephone/Operator'
			WHEN temp.lions_dem_OccupationDetail = 'D072' THEN 'Teller/Bank Teller'
			WHEN temp.lions_dem_OccupationDetail = 'D073' THEN 'Tester'
			WHEN temp.lions_dem_OccupationDetail = 'D074' THEN 'Transcripter/Translator'
			WHEN temp.lions_dem_OccupationDetail = 'D075' THEN 'Travel Agent'
			WHEN temp.lions_dem_OccupationDetail = 'D076' THEN 'Union Member/Rep.'
			WHEN temp.lions_dem_OccupationDetail = 'D077' THEN 'Ward Clerk'
			WHEN temp.lions_dem_OccupationDetail = 'D078' THEN 'Water Treatment'
			WHEN temp.lions_dem_OccupationDetail = 'D079' THEN 'Writer'
			WHEN temp.lions_dem_OccupationDetail = 'E001' THEN 'Blue Collar Worker'
			WHEN temp.lions_dem_OccupationDetail = 'E002' THEN 'Animal Technician/Groomer'
			WHEN temp.lions_dem_OccupationDetail = 'E003' THEN 'Apprentice'
			WHEN temp.lions_dem_OccupationDetail = 'E004' THEN 'Assembler'
			WHEN temp.lions_dem_OccupationDetail = 'E005' THEN 'Athlete/Professional'
			WHEN temp.lions_dem_OccupationDetail = 'E006' THEN 'Attendant'
			WHEN temp.lions_dem_OccupationDetail = 'E007' THEN 'Auto Mechanic'
			WHEN temp.lions_dem_OccupationDetail = 'E008' THEN 'Baker'
			WHEN temp.lions_dem_OccupationDetail = 'E009' THEN 'Barber/Hairstylist/Beautician'
			WHEN temp.lions_dem_OccupationDetail = 'E010' THEN 'Bartender'
			WHEN temp.lions_dem_OccupationDetail = 'E011' THEN 'Binder'
			WHEN temp.lions_dem_OccupationDetail = 'E012' THEN 'Bodyman'
			WHEN temp.lions_dem_OccupationDetail = 'E013' THEN 'Brakeman'
			WHEN temp.lions_dem_OccupationDetail = 'E014' THEN 'Brewer'
			WHEN temp.lions_dem_OccupationDetail = 'E015' THEN 'Butcher/Meat Cutter'
			WHEN temp.lions_dem_OccupationDetail = 'E016' THEN 'Carpenter/Furniture/Woodworking'
			WHEN temp.lions_dem_OccupationDetail = 'E017' THEN 'Chef/Butler'
			WHEN temp.lions_dem_OccupationDetail = 'E018' THEN 'Child Care/Day Care/Babysitter'
			WHEN temp.lions_dem_OccupationDetail = 'E019' THEN 'Cleaner/Laundry'
			WHEN temp.lions_dem_OccupationDetail = 'E020' THEN 'Clerk/Deli'
			WHEN temp.lions_dem_OccupationDetail = 'E021' THEN 'Clerk/Produce'
			WHEN temp.lions_dem_OccupationDetail = 'E022' THEN 'Clerk/Stock'
			WHEN temp.lions_dem_OccupationDetail = 'E023' THEN 'Conductor'
			WHEN temp.lions_dem_OccupationDetail = 'E024' THEN 'Construction'
			WHEN temp.lions_dem_OccupationDetail = 'E025' THEN 'Cook'
			WHEN temp.lions_dem_OccupationDetail = 'E026' THEN 'Cosmetologist'
			WHEN temp.lions_dem_OccupationDetail = 'E027' THEN 'Courier/Delivery/Messenger'
			WHEN temp.lions_dem_OccupationDetail = 'E028' THEN 'Crewman'
			WHEN temp.lions_dem_OccupationDetail = 'E029' THEN 'Custodian'
			WHEN temp.lions_dem_OccupationDetail = 'E030' THEN 'Cutter'
			WHEN temp.lions_dem_OccupationDetail = 'E031' THEN 'Dock Worker'
			WHEN temp.lions_dem_OccupationDetail = 'E032' THEN 'Driver'
			WHEN temp.lions_dem_OccupationDetail = 'E033' THEN 'Driver/Bus Driver'
			WHEN temp.lions_dem_OccupationDetail = 'E034' THEN 'Driver/Truck Driver'
			WHEN temp.lions_dem_OccupationDetail = 'E035' THEN 'Electrician'
			WHEN temp.lions_dem_OccupationDetail = 'E036' THEN 'Fabricator'
			WHEN temp.lions_dem_OccupationDetail = 'E037' THEN 'Factory Workman'
			WHEN temp.lions_dem_OccupationDetail = 'E038' THEN 'Farmer/Dairyman'
			WHEN temp.lions_dem_OccupationDetail = 'E039' THEN 'Finisher'
			WHEN temp.lions_dem_OccupationDetail = 'E040' THEN 'Fisherman/Seaman'
			WHEN temp.lions_dem_OccupationDetail = 'E041' THEN 'Fitter'
			WHEN temp.lions_dem_OccupationDetail = 'E042' THEN 'Food Service'
			WHEN temp.lions_dem_OccupationDetail = 'E043' THEN 'Foreman/Crew leader'
			WHEN temp.lions_dem_OccupationDetail = 'E044' THEN 'Foreman/Shop Foreman'
			WHEN temp.lions_dem_OccupationDetail = 'E045' THEN 'Forestry'
			WHEN temp.lions_dem_OccupationDetail = 'E046' THEN 'Foundry Worker'
			WHEN temp.lions_dem_OccupationDetail = 'E047' THEN 'Furrier'
			WHEN temp.lions_dem_OccupationDetail = 'E048' THEN 'Gardener/Landscaper'
			WHEN temp.lions_dem_OccupationDetail = 'E049' THEN 'Glazier'
			WHEN temp.lions_dem_OccupationDetail = 'E050' THEN 'Grinder'
			WHEN temp.lions_dem_OccupationDetail = 'E051' THEN 'Grocer'
			WHEN temp.lions_dem_OccupationDetail = 'E052' THEN 'Helper'
			WHEN temp.lions_dem_OccupationDetail = 'E053' THEN 'Housekeeper/Maid'
			WHEN temp.lions_dem_OccupationDetail = 'E054' THEN 'Inspector'
			WHEN temp.lions_dem_OccupationDetail = 'E055' THEN 'Installer'
			WHEN temp.lions_dem_OccupationDetail = 'E056' THEN 'Ironworker'
			WHEN temp.lions_dem_OccupationDetail = 'E057' THEN 'Janitor'
			WHEN temp.lions_dem_OccupationDetail = 'E058' THEN 'Journeyman'
			WHEN temp.lions_dem_OccupationDetail = 'E059' THEN 'Laborer'
			WHEN temp.lions_dem_OccupationDetail = 'E060' THEN 'Lineman'
			WHEN temp.lions_dem_OccupationDetail = 'E061' THEN 'Lithographer'
			WHEN temp.lions_dem_OccupationDetail = 'E062' THEN 'Loader'
			WHEN temp.lions_dem_OccupationDetail = 'E063' THEN 'Locksmith'
			WHEN temp.lions_dem_OccupationDetail = 'E064' THEN 'Machinist'
			WHEN temp.lions_dem_OccupationDetail = 'E065' THEN 'Maintenance'
			WHEN temp.lions_dem_OccupationDetail = 'E066' THEN 'Maintenance/Supervisor'
			WHEN temp.lions_dem_OccupationDetail = 'E067' THEN 'Mason/Brick/Etc.'
			WHEN temp.lions_dem_OccupationDetail = 'E068' THEN 'Material Handler'
			WHEN temp.lions_dem_OccupationDetail = 'E069' THEN 'Mechanic'
			WHEN temp.lions_dem_OccupationDetail = 'E070' THEN 'Meter Reader'
			WHEN temp.lions_dem_OccupationDetail = 'E071' THEN 'Mill worker'
			WHEN temp.lions_dem_OccupationDetail = 'E072' THEN 'Millwright'
			WHEN temp.lions_dem_OccupationDetail = 'E073' THEN 'Miner'
			WHEN temp.lions_dem_OccupationDetail = 'E074' THEN 'Mold Maker/Molder/Injection Mold'
			WHEN temp.lions_dem_OccupationDetail = 'E075' THEN 'Oil Industry/Driller'
			WHEN temp.lions_dem_OccupationDetail = 'E076' THEN 'Operator'
			WHEN temp.lions_dem_OccupationDetail = 'E077' THEN 'Operator/Boilermaker'
			WHEN temp.lions_dem_OccupationDetail = 'E078' THEN 'Operator/Crane Operator'
			WHEN temp.lions_dem_OccupationDetail = 'E079' THEN 'Operator/Forklift Operator'
			WHEN temp.lions_dem_OccupationDetail = 'E080' THEN 'Operator/Machine Operator'
			WHEN temp.lions_dem_OccupationDetail = 'E081' THEN 'Packer'
			WHEN temp.lions_dem_OccupationDetail = 'E082' THEN 'Painter'
			WHEN temp.lions_dem_OccupationDetail = 'E083' THEN 'Parts (Auto Etc.)'
			WHEN temp.lions_dem_OccupationDetail = 'E084' THEN 'Pipe fitter'
			WHEN temp.lions_dem_OccupationDetail = 'E085' THEN 'Plumber'
			WHEN temp.lions_dem_OccupationDetail = 'E086' THEN 'Polisher'
			WHEN temp.lions_dem_OccupationDetail = 'E087' THEN 'Porter'
			WHEN temp.lions_dem_OccupationDetail = 'E088' THEN 'Press Operator'
			WHEN temp.lions_dem_OccupationDetail = 'E089' THEN 'Presser'
			WHEN temp.lions_dem_OccupationDetail = 'E090' THEN 'Printer'
			WHEN temp.lions_dem_OccupationDetail = 'E091' THEN 'Production'
			WHEN temp.lions_dem_OccupationDetail = 'E092' THEN 'Repairman'
			WHEN temp.lions_dem_OccupationDetail = 'E093' THEN 'Roofer'
			WHEN temp.lions_dem_OccupationDetail = 'E094' THEN 'Sanitation/Exterminator'
			WHEN temp.lions_dem_OccupationDetail = 'E095' THEN 'Seamstress/Tailor/Handicraft'
			WHEN temp.lions_dem_OccupationDetail = 'E096' THEN 'Setup man'
			WHEN temp.lions_dem_OccupationDetail = 'E097' THEN 'Sheet Metal Worker/Steel Worker'
			WHEN temp.lions_dem_OccupationDetail = 'E098' THEN 'Shipping/Import/Export/Custom'
			WHEN temp.lions_dem_OccupationDetail = 'E099' THEN 'Sorter'
			WHEN temp.lions_dem_OccupationDetail = 'E100' THEN 'Toolmaker'
			WHEN temp.lions_dem_OccupationDetail = 'E101' THEN 'Transportation'
			WHEN temp.lions_dem_OccupationDetail = 'E102' THEN 'Typesetter'
			WHEN temp.lions_dem_OccupationDetail = 'E103' THEN 'Upholstery'
			WHEN temp.lions_dem_OccupationDetail = 'E104' THEN 'Utility'
			WHEN temp.lions_dem_OccupationDetail = 'E105' THEN 'Waiter/Waitress'
			WHEN temp.lions_dem_OccupationDetail = 'E106' THEN 'Welder'
			WHEN temp.lions_dem_OccupationDetail = 'F000' THEN 'Health Services'
			WHEN temp.lions_dem_OccupationDetail = 'F001' THEN 'Chiropractor'
			WHEN temp.lions_dem_OccupationDetail = 'F002' THEN 'Dental Assistant'
			WHEN temp.lions_dem_OccupationDetail = 'F003' THEN 'Dental Hygienist'
			WHEN temp.lions_dem_OccupationDetail = 'F004' THEN 'Dentist'
			WHEN temp.lions_dem_OccupationDetail = 'F005' THEN 'Dietician'
			WHEN temp.lions_dem_OccupationDetail = 'F006' THEN 'Health Care'
			WHEN temp.lions_dem_OccupationDetail = 'F007' THEN 'Medical Assistant'
			WHEN temp.lions_dem_OccupationDetail = 'F008' THEN 'Medical Secretary'
			WHEN temp.lions_dem_OccupationDetail = 'F009' THEN 'Medical Technician'
			WHEN temp.lions_dem_OccupationDetail = 'F010' THEN 'Medical/Paramedic'
			WHEN temp.lions_dem_OccupationDetail = 'F011' THEN 'Nurses Aide/Orderly'
			WHEN temp.lions_dem_OccupationDetail = 'F012' THEN 'Optician'
			WHEN temp.lions_dem_OccupationDetail = 'F013' THEN 'Optometrist'
			WHEN temp.lions_dem_OccupationDetail = 'F014' THEN 'Pharmacist/Pharmacy'
			WHEN temp.lions_dem_OccupationDetail = 'F015' THEN 'Psychologist'
			WHEN temp.lions_dem_OccupationDetail = 'F016' THEN 'Technician/Lab'
			WHEN temp.lions_dem_OccupationDetail = 'F017' THEN 'Technician/X-ray'
			WHEN temp.lions_dem_OccupationDetail = 'F018' THEN 'Therapist'
			WHEN temp.lions_dem_OccupationDetail = 'F019' THEN 'Therapists/Physical'
			WHEN temp.lions_dem_OccupationDetail = 'G001' THEN 'Legal/Paralegal/Assistant'
			WHEN temp.lions_dem_OccupationDetail = 'G002' THEN 'Legal Secretary'
			WHEN temp.lions_dem_OccupationDetail = 'G003' THEN 'Secretary'
			WHEN temp.lions_dem_OccupationDetail = 'G004' THEN 'Typist'
			WHEN temp.lions_dem_OccupationDetail = 'H001' THEN 'Homemaker'
			WHEN temp.lions_dem_OccupationDetail = 'I000' THEN 'Retired'
			WHEN temp.lions_dem_OccupationDetail = 'I001' THEN 'Retired/Pensioner'
			WHEN temp.lions_dem_OccupationDetail = 'K000' THEN 'Military Personnel'
			WHEN temp.lions_dem_OccupationDetail = 'K001' THEN 'Armed Forces'
			WHEN temp.lions_dem_OccupationDetail = 'K002' THEN 'Army Credit Union Trades'
			WHEN temp.lions_dem_OccupationDetail = 'K003' THEN 'Navy Credit Union Trades'
			WHEN temp.lions_dem_OccupationDetail = 'K004' THEN 'Air Force'
			WHEN temp.lions_dem_OccupationDetail = 'K005' THEN 'National Guard'
			WHEN temp.lions_dem_OccupationDetail = 'K006' THEN 'Coast Guard'
			WHEN temp.lions_dem_OccupationDetail = 'K007' THEN 'Marines'
			WHEN temp.lions_dem_OccupationDetail = 'L001' THEN 'Coach'
			WHEN temp.lions_dem_OccupationDetail = 'L002' THEN 'Counselor'
			WHEN temp.lions_dem_OccupationDetail = 'L003' THEN 'Instructor'
			WHEN temp.lions_dem_OccupationDetail = 'L004' THEN 'Lecturer'
			WHEN temp.lions_dem_OccupationDetail = 'L005' THEN 'Professor'
			WHEN temp.lions_dem_OccupationDetail = 'L006' THEN 'Teacher'
			WHEN temp.lions_dem_OccupationDetail = 'L007' THEN 'Trainer'
			WHEN temp.lions_dem_OccupationDetail = 'M001' THEN 'Nurse'
			WHEN temp.lions_dem_OccupationDetail = 'M002' THEN 'Nurse (Registered)'
			WHEN temp.lions_dem_OccupationDetail = 'M003' THEN 'Nurse/LPN'
			WHEN temp.lions_dem_OccupationDetail = 'N000' THEN 'Computer'
			WHEN temp.lions_dem_OccupationDetail = 'N001' THEN 'Computer Operator'
			WHEN temp.lions_dem_OccupationDetail = 'N002' THEN 'Computer Programmer'
			WHEN temp.lions_dem_OccupationDetail = 'N003' THEN 'Computer/Systems Analyst'
			WHEN temp.lions_dem_OccupationDetail = 'N004' THEN 'Data Entry/Key Punch'
			WHEN temp.lions_dem_OccupationDetail = 'P000' THEN 'Civil Service'
			WHEN temp.lions_dem_OccupationDetail = 'P001' THEN 'Air Traffic Control'
			WHEN temp.lions_dem_OccupationDetail = 'P002' THEN 'Civil Service/Government'
			WHEN temp.lions_dem_OccupationDetail = 'P003' THEN 'Corrections/Probation/Parole'
			WHEN temp.lions_dem_OccupationDetail = 'P004' THEN 'Court Reporter'
			WHEN temp.lions_dem_OccupationDetail = 'P005' THEN 'Firefighter'
			WHEN temp.lions_dem_OccupationDetail = 'P006' THEN 'Judge/Referee'
			WHEN temp.lions_dem_OccupationDetail = 'P007' THEN 'Mail Carrier/Postal'
			WHEN temp.lions_dem_OccupationDetail = 'P008' THEN 'Mail/Postmaster'
			WHEN temp.lions_dem_OccupationDetail = 'P009' THEN 'Police/Trooper'
			WHEN temp.lions_dem_OccupationDetail = 'P010' THEN 'Social Worker/Case Worker'
			WHEN temp.lions_dem_OccupationDetail = 'Q001' THEN 'Part Time'
			WHEN temp.lions_dem_OccupationDetail = 'R001' THEN 'Student'
			WHEN temp.lions_dem_OccupationDetail = 'S001' THEN 'Volunteer'
			ELSE NULL END
,cc.lions_dem_HomePropertyType = 		 CASE
			WHEN temp.lions_dem_HomePropertyType = 'A ' THEN ' Single Family Dwelling Unit'
			WHEN temp.lions_dem_HomePropertyType = 'B ' THEN ' Condo'
			WHEN temp.lions_dem_HomePropertyType = 'C ' THEN ' Cooperative'
			WHEN temp.lions_dem_HomePropertyType = 'D ' THEN ' 2-4 Unite (Duplex, Triplex, Quad)'
			WHEN temp.lions_dem_HomePropertyType = 'E ' THEN ' Miscellaneous Residence (Combo Store/Flat)'
			WHEN temp.lions_dem_HomePropertyType = 'G ' THEN ' Apartment (5+ Units)'
			WHEN temp.lions_dem_HomePropertyType = 'M ' THEN ' Mobile Home'
			WHEN temp.lions_dem_HomePropertyType = 'T ' THEN ' Timeshare'
			ELSE NULL END
,cc.lions_dem_HomeYearBuilt = 			 temp.lions_dem_HomeYearBuilt

,cc.lions_dem_HomeOwnerRenter = 		 CASE
			WHEN temp.lions_dem_HomeOwnerRenter = 'O ' THEN ' Home Owner'
			WHEN temp.lions_dem_HomeOwnerRenter = 'R ' THEN ' Renter'
			ELSE NULL END

,cc.lions_dem_HomeLengthofResidence = 	 CASE
			WHEN temp.lions_dem_HomeLengthofResidence = '0' THEN ' Less than 1 Year'
			WHEN temp.lions_dem_HomeLengthofResidence = '1' THEN ' 1 Year'
			WHEN temp.lions_dem_HomeLengthofResidence = '2' THEN ' 2 Years'
			WHEN temp.lions_dem_HomeLengthofResidence = '3' THEN ' 3 Years'
			WHEN temp.lions_dem_HomeLengthofResidence = '4' THEN ' 4 years'
			WHEN temp.lions_dem_HomeLengthofResidence = '5' THEN ' 5 Years'
			WHEN temp.lions_dem_HomeLengthofResidence = '6' THEN ' 6 Years'
			WHEN temp.lions_dem_HomeLengthofResidence = '7' THEN ' 7 Years'
			WHEN temp.lions_dem_HomeLengthofResidence = '8' THEN ' 8 Years'
			WHEN temp.lions_dem_HomeLengthofResidence = '9' THEN ' 9 Years'
			WHEN temp.lions_dem_HomeLengthofResidence = '10' THEN ' 10 Years'
			WHEN temp.lions_dem_HomeLengthofResidence = '11' THEN ' 11 Years'
			WHEN temp.lions_dem_HomeLengthofResidence = '12' THEN ' 12 Years'
			WHEN temp.lions_dem_HomeLengthofResidence = '13' THEN ' 13 Years'
			WHEN temp.lions_dem_HomeLengthofResidence = '14' THEN ' 14 Years'
			WHEN temp.lions_dem_HomeLengthofResidence = '15' THEN ' Greater than 14 Years'
			ELSE NULL END

,cc.familystatuscode = 
CASE WHEN temp.familystatuscode IN ('M','A') THEN '2' WHEN temp.familystatuscode IN ('S', 'B') THEN '1'	ELSE NULL END 

--2 = married, 1 = Single  --Updated 02142018 by TCF


,cc.lions_dem_PresenceofChildren = 		 CASE
			WHEN temp.lions_dem_PresenceofChildren = 'Y ' THEN 1
			WHEN temp.lions_dem_PresenceofChildren = 'N ' THEN 0
			ELSE NULL END

            
,cc.str_agerange = 						 CASE
			WHEN temp.str_agerange = '17' THEN ' Age less than 18'
			WHEN temp.str_agerange = '18' THEN ' Age 18 - 19'
			WHEN temp.str_agerange = '20' THEN ' Age 20 - 21'
			WHEN temp.str_agerange = '22' THEN ' Age 22 - 23'
			WHEN temp.str_agerange = '24' THEN ' Age 24 - 25'
			WHEN temp.str_agerange = '26' THEN ' Age 26 - 27'
			WHEN temp.str_agerange = '28' THEN ' Age 28 - 29'
			WHEN temp.str_agerange = '30' THEN ' Age 30 - 31'
			WHEN temp.str_agerange = '32' THEN ' Age 32 - 33'
			WHEN temp.str_agerange = '34' THEN ' Age 34 - 35'
			WHEN temp.str_agerange = '36' THEN ' Age 36 - 37'
			WHEN temp.str_agerange = '38' THEN ' Age 38 - 39'
			WHEN temp.str_agerange = '40' THEN ' Age 40 - 41'
			WHEN temp.str_agerange = '42' THEN ' Age 42 - 43'
			WHEN temp.str_agerange = '44' THEN ' Age 44 - 45'
			WHEN temp.str_agerange = '46' THEN ' Age 46 - 47'
			WHEN temp.str_agerange = '48' THEN ' Age 48 - 49'
			WHEN temp.str_agerange = '50' THEN ' Age 50 - 51'
			WHEN temp.str_agerange = '52' THEN ' Age 52 - 53'
			WHEN temp.str_agerange = '54' THEN ' Age 54 - 55'
			WHEN temp.str_agerange = '56' THEN ' Age 56 - 57'
			WHEN temp.str_agerange = '58' THEN ' Age 58 - 59'
			WHEN temp.str_agerange = '60' THEN ' Age 60 - 61'
			WHEN temp.str_agerange = '62' THEN ' Age 62 - 63'
			WHEN temp.str_agerange = '64' THEN ' Age 64 - 65'
			WHEN temp.str_agerange = '66' THEN ' Age 66 - 67'
			WHEN temp.str_agerange = '68' THEN ' Age 68 - 69'
			WHEN temp.str_agerange = '70' THEN ' Age 70 - 71'
			WHEN temp.str_agerange = '72' THEN ' Age 72 - 73'
			WHEN temp.str_agerange = '74' THEN ' Age 74 - 75'
			WHEN temp.str_agerange = '76' THEN ' Age 76 - 77'
			WHEN temp.str_agerange = '78' THEN ' Age 78 - 79'
			WHEN temp.str_agerange = '80' THEN ' Age 80 - 81'
			WHEN temp.str_agerange = '82' THEN ' Age 82 - 83'
			WHEN temp.str_agerange = '84' THEN ' Age 84 - 85'
			WHEN temp.str_agerange = '86' THEN ' Age 86 - 87'
			WHEN temp.str_agerange = '88' THEN ' Age 88 - 89'
			WHEN temp.str_agerange = '90' THEN ' Age 90 - 91'
			WHEN temp.str_agerange = '92' THEN ' Age 92 - 93'
			WHEN temp.str_agerange = '94' THEN ' Age 94 - 95'
			WHEN temp.str_agerange = '96' THEN ' Age 96 - 97'
			WHEN temp.str_agerange = '98' THEN ' Age 98 - 99'
			WHEN temp.str_agerange = '99' THEN ' Age greater than 99'
			ELSE NULL END	

,cc.lions_dem_Occupation = 				 CASE
			WHEN temp.lions_dem_Occupation = '1' THEN ' Professional/Technical'
			WHEN temp.lions_dem_Occupation = '2' THEN ' Administration/Managerial'
			WHEN temp.lions_dem_Occupation = '3' THEN ' Sales/Service'
			WHEN temp.lions_dem_Occupation = '4' THEN ' Clerical/White Collar'
			WHEN temp.lions_dem_Occupation = '5' THEN ' Craftsman/Blue Collar'
			WHEN temp.lions_dem_Occupation = '6' THEN ' Student'
			WHEN temp.lions_dem_Occupation = '7' THEN ' Homemaker'
			WHEN temp.lions_dem_Occupation = '8' THEN ' Retired'
			WHEN temp.lions_dem_Occupation = '9' THEN ' Farmer'
			WHEN temp.lions_dem_Occupation = 'A ' THEN ' Military'
			WHEN temp.lions_dem_Occupation = 'B ' THEN ' Religious'
			WHEN temp.lions_dem_Occupation = 'C ' THEN ' Self Employed'
			WHEN temp.lions_dem_Occupation = 'D ' THEN ' Self Employed - Professional/Technical'
			WHEN temp.lions_dem_Occupation = 'E ' THEN ' Self Employed - Administration/Managerial'
			WHEN temp.lions_dem_Occupation = 'F ' THEN ' Self Employed - Sales/Service'
			WHEN temp.lions_dem_Occupation = 'G ' THEN ' Self Employed - Clerical/White Collar'
			WHEN temp.lions_dem_Occupation = 'H ' THEN ' Self Employed - Craftsman/Blue Collar'
			WHEN temp.lions_dem_Occupation = 'I ' THEN ' Self Employed - Student'
			WHEN temp.lions_dem_Occupation = 'J ' THEN ' Self Employed - Homemaker'
			WHEN temp.lions_dem_Occupation = 'K ' THEN ' Self Employed - Retired'
			WHEN temp.lions_dem_Occupation = 'L ' THEN ' Self Employed - Other'
			WHEN temp.lions_dem_Occupation = 'V ' THEN ' Educator'
			WHEN temp.lions_dem_Occupation = 'W ' THEN ' Financial Professional'
			WHEN temp.lions_dem_Occupation = 'X ' THEN ' Legal Professional'
			WHEN temp.lions_dem_Occupation = 'Y ' THEN ' Medical Professional'
			WHEN temp.lions_dem_Occupation = 'Z ' THEN ' Other'
			ELSE NULL END

,cc.[lions_dem_hhincome] = 				 CASE 
			WHEN temp.str_householdincome = '1' THEN ' Less than $15,000'
			WHEN temp.str_householdincome = '2' THEN ' $15,000 - $19,999'
			WHEN temp.str_householdincome = '3' THEN ' $20,000 - $29,999'
			WHEN temp.str_householdincome = '4' THEN ' $30,000 - $39,999'
			WHEN temp.str_householdincome = '5' THEN ' $40,000 - $49,999'
			WHEN temp.str_householdincome = '6' THEN ' $50,000 - $74,999'
			WHEN temp.str_householdincome = '7' THEN ' $75,000 - $99,999'
			WHEN temp.str_householdincome = '8' THEN ' $100,000 - $124,999'
			WHEN temp.str_householdincome = '9' THEN ' Greater than $124,999'
			ELSE NULL END




,cc.lions_dem_HomeMarketValue = 		 CASE
			WHEN temp.lions_dem_HomeMarketValue = 'A ' THEN ' $1,000 - $24,999'
			WHEN temp.lions_dem_HomeMarketValue = 'B ' THEN ' $25,000 - $49,999'
			WHEN temp.lions_dem_HomeMarketValue = 'C ' THEN ' $50,000 - $74,999'
			WHEN temp.lions_dem_HomeMarketValue = 'D ' THEN ' $75,000 - $99,999'
			WHEN temp.lions_dem_HomeMarketValue = 'E ' THEN ' $100,000 - $124,999'
			WHEN temp.lions_dem_HomeMarketValue = 'F ' THEN ' $125,000 - $149,999'
			WHEN temp.lions_dem_HomeMarketValue = 'G ' THEN ' $150,000 - $174,999'
			WHEN temp.lions_dem_HomeMarketValue = 'H ' THEN ' $175,000 - $199,999'
			WHEN temp.lions_dem_HomeMarketValue = 'I ' THEN ' $200,000 - $224,999'
			WHEN temp.lions_dem_HomeMarketValue = 'J ' THEN ' $225,000 - $249,999'
			WHEN temp.lions_dem_HomeMarketValue = 'K ' THEN ' $250,000 - $274,999'
			WHEN temp.lions_dem_HomeMarketValue = 'L ' THEN ' $275,000 - $299,999'
			WHEN temp.lions_dem_HomeMarketValue = 'M ' THEN ' $300,000 - $349,999'
			WHEN temp.lions_dem_HomeMarketValue = 'N ' THEN ' $350,000 - $399,999'
			WHEN temp.lions_dem_HomeMarketValue = 'O ' THEN ' $400,000 - $449,999'
			WHEN temp.lions_dem_HomeMarketValue = 'P ' THEN ' $450,000 - $499,999'
			WHEN temp.lions_dem_HomeMarketValue = 'Q ' THEN ' $500,000 - $749,999'
			WHEN temp.lions_dem_HomeMarketValue = 'R ' THEN ' $750,000 - $999,999'
			WHEN temp.lions_dem_HomeMarketValue = 'S ' THEN ' $1,000,000 Plus'
			ELSE NULL END

,cc.lions_dem_NewCarBuyer = 			 CASE WHEN temp.lions_dem_NewCarBuyer = 'Y' THEN 1 WHEN temp.lions_dem_NewCarBuyer = 'N' THEN 0 ELSE NULL END

,cc.lions_dem_KnownOwnedVehicles = 		 CASE
			WHEN temp.lions_dem_KnownOwnedVehicles = '1' THEN ' 1 Car'
			WHEN temp.lions_dem_KnownOwnedVehicles = '2' THEN ' 2 Cars'
			WHEN temp.lions_dem_KnownOwnedVehicles = '3' THEN ' 3 or More Cars'
			ELSE NULL END

,cc.lions_dem_DominantVehicleLifestyle = CASE
			WHEN temp.lions_dem_DominantVehicleLifestyle = 'A ' THEN ' Luxury / Upper sporty Classification'
			WHEN temp.lions_dem_DominantVehicleLifestyle = 'B ' THEN ' Truck Classification'
			WHEN temp.lions_dem_DominantVehicleLifestyle = 'C ' THEN ' Sport Utility Vehicle Classification'
			WHEN temp.lions_dem_DominantVehicleLifestyle = 'D ' THEN ' Mini-Van Classification'
			WHEN temp.lions_dem_DominantVehicleLifestyle = 'E ' THEN ' Regular Classification (Mid-Size / Small)'
			WHEN temp.lions_dem_DominantVehicleLifestyle = 'F ' THEN ' Upper Classification (Mid-Size / Large)'
			WHEN temp.lions_dem_DominantVehicleLifestyle = 'G ' THEN ' Basic Sporty Classification'
			ELSE NULL END
            
,cc.lions_dem_EducationLevel = 			 CASE
			WHEN temp.lions_dem_EducationLevel = '1' THEN ' Completed High School'
			WHEN temp.lions_dem_EducationLevel = '2' THEN ' Completed College'
			WHEN temp.lions_dem_EducationLevel = '3' THEN ' Completed Graduate School'
			WHEN temp.lions_dem_EducationLevel = '4' THEN ' Attended Vocational/Technical'
			ELSE NULL END

FROM contact_custom cc 
INNER JOIN #appendstemp temp ON cc.ssb_crmsystem_contact_id = temp.ssb_crmsystem_contact_id

DROP TABLE #appendstemp

--DistanceToStadium
SELECT SSB_CRMSYSTEM_CONTACT_ID,
       cr.AddressPrimaryZip,
       AddressPrimaryLongitude Longitude,
       AddressPrimaryLatitude Latitude,
       geography::STPointFromText(
                                     'POINT(' + CAST(ISNULL(NULLIF(AddressPrimaryLongitude,''),0) AS VARCHAR(20)) + ' '
                                     + CAST(ISNULL(NULLIF(AddressPrimaryLatitude,''),0) AS VARCHAR(20)) + ')',
                                     4326
                                 ) Geolocation
INTO #temp1
FROM dbo.vwCompositeRecord_ModAcctID cr
    JOIN dbo.DimCustomer dc
        ON dc.SSID = cr.SSID;

DECLARE @Centroid GEOGRAPHY;

-- Track_LionsStadium
SELECT @Centroid
    = geography::STPointFromText(
                                    'POINT(' + CAST('-83.2457616' AS VARCHAR(20)) + ' '
                                    + CAST('42.3103154' AS VARCHAR(20)) + ')',
                                    4326
                                );
--FROM CentralIntelligence.[dbo].[zip_codes_database] WHERE Zipcode = '30228'


UPDATE cc
SET cc.lions_dem_DistancetoStadium= ROUND(Geolocation.STDistance(@Centroid) * 0.00062137, 2)
FROM dbo.Contact_Custom cc
    JOIN #temp1 t1
        ON t1.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID;

DROP TABLE #temp1

/******************************
Custom Ticket Fields -- Veritix Specific
CTW 01/08/18
********************************/

IF OBJECT_ID('tempdb..#flgstg') IS NOT NULL
	DROP TABLE #flgstg
SELECT DISTINCT ssbid.SSB_CRMSYSTEM_CONTACT_ID, dtt.TicketTypeName, dpt.PlanTypeName, ds.SeasonYear, dez.EventZoneName, dpc.PriceCodeDesc, do.OfferDesc, dst.SectionName, CASE WHEN SectionName BETWEEN '200' AND '214'
OR SectionName BETWEEN '227' AND '234' OR SectionName BETWEEN '330' AND '332' OR dst.SectionName = 'Field Level Seating' THEN 'Club' ELSE 'Non-Club' END AS Club
INTO #flgstg
FROM lions.dbo.FactTicketSales fts (NOLOCK)
JOIN lions.dbo.DimTicketType dtt (NOLOCK) ON dtt.DimTicketTypeId = fts.DimTicketTypeId
JOIN lions.dbo.DimPlanType dpt (NOLOCK) ON dpt.DimPlanTypeId = fts.DimPlanTypeId
JOIN lions.dbo.DimTicketCustomer dtc (NOLOCK) ON dtc.DimTicketCustomerId = fts.DimTicketCustomerId
JOIN lions.dbo.dimcustomerssbid ssbid (NOLOCK) ON LEFT(dtc.ETL__SSID,CHARINDEX('.',dtc.ETL__SSID)-1) = ssbid.SSID
JOIN lions.dbo.DimSeason ds (NOLOCK) ON ds.DimSeasonId = fts.DimSeasonId
JOIN lions.dbo.DimPriceCode dpc (NOLOCK) ON dpc.DimPriceCodeId = fts.DimPriceCodeId
JOIN lions.dbo.DimEventZone dez (NOLOCK) ON dez.DimEventZoneId = fts.DimEventZoneId
JOIN lions.dbo.DimOffer do (NOLOCK) ON do.DimOfferId = fts.DimOfferId
JOIN lions.dbo.DimSeat dst (NOLOCK) ON dst.DimSeatId = fts.DimSeatId_Start
WHERE dez.EventZoneName NOT LIKE 'Parking%'
ORDER BY ssbid.SSB_CRMSYSTEM_CONTACT_ID, ds.SeasonYear

DECLARE @SeasonYear INT
SET @SeasonYear = CASE WHEN MONTH(GETDATE()) IN (4,5,6,7,8,9,10,11,12) THEN YEAR(GETDATE()) ELSE YEAR(GETDATE()) - 1 END

IF OBJECT_ID('tempdb..#stg2') IS NOT NULL
	DROP TABLE #stg2
SELECT SSB_CRMSYSTEM_CONTACT_ID, 
--CASE WHEN SeasonYear = @SeasonYear 
--AND TicketTypeName='Full Season' THEN 1 ELSE 0 END AS CurrentSeasonTicketMember,
CASE WHEN SeasonYear <@SeasonYear 
AND TicketTypeName='Full Season' THEN 1 ELSE 0 END AS FormerSeasonTicketMember,
--CASE WHEN SeasonYear = @SeasonYear 
--AND TicketTypeName= 'Full Season' AND EventZoneName = 'Admissions' AND Club != 'Club' THEN 1 ELSE 0 END AS CurrentSeasonGASTM,
CASE WHEN SeasonYear < @SeasonYear 
AND TicketTypeName= 'Full Season' AND EventZoneName = 'Admissions' AND Club != 'Club' THEN 1 ELSE 0 END AS FormerSeasonGASTM,
--CASE WHEN SeasonYear = @SeasonYear 
--AND TicketTypeName= 'Full Season' AND EventZoneName = 'Admissions' AND Club = 'Club' THEN 1 ELSE 0 END AS CurrentSeasonClubSTM,
CASE WHEN SeasonYear < @SeasonYear 
AND TicketTypeName= 'Full Season' AND EventZoneName = 'Admissions' AND Club = 'Club' THEN 1 ELSE 0 END AS FormerSeasonClubSTM,
--CASE WHEN SeasonYear = @SeasonYear
--AND TicketTypeName='Fan Plan' THEN 1 ELSE 0 END AS CurrentFanPlan,
CASE WHEN SeasonYear <@SeasonYear AND TicketTypeName='Fan Plan' THEN 1 ELSE 0 END AS FormerFanPlan,
--CASE WHEN SeasonYear = @SeasonYear AND TicketTypeName LIKE 'Single Game%' THEN 1 ELSE 0 END AS CurrentSGB,
CASE WHEN SeasonYear <@SeasonYear AND TicketTypeName LIKE 'Single Game%' THEN 1 ELSE 0 END AS FormerSGB,
--CASE WHEN SeasonYear = @SeasonYear AND TicketTypeName = 'Group' THEN 1 ELSE 0 END AS CurrentGroup,
CASE WHEN SeasonYear <@SeasonYear AND TicketTypeName = 'Group' THEN 1 ELSE 0 END AS FormerGroup,
--CASE WHEN SeasonYear = @SeasonYear AND PriceCodeDesc LIKE '%Tunnel Club%' AND PriceCodeDesc NOT LIKE '%Wait List' THEN 1 ELSE 0 END AS CurrentTunnelClub,
CASE WHEN SeasonYear <@SeasonYear AND PriceCodeDesc LIKE '%Tunnel Club%' AND PriceCodeDesc NOT LIKE '%Wait List' THEN 1 ELSE 0 END AS FormerTunnelClub,
--CASE WHEN SeasonYear = @SeasonYear AND PriceCodeDesc LIKE '%Loge%' THEN 1 ELSE 0 END AS CurrentLoge,
CASE WHEN SeasonYear <@SeasonYear AND PriceCodeDesc LIKE '%Loge%' THEN 1 ELSE 0 END AS FormerLoge,
--CASE WHEN SeasonYear = @SeasonYear AND TicketTypeName = 'Suite License' THEN 1 ELSE 0 END AS CurrentSuiteLease,
CASE WHEN SeasonYear <@SeasonYear AND TicketTypeName = 'Suite License' THEN 1 ELSE 0 END AS FormerSuiteLease,
--CASE WHEN SeasonYear = @SeasonYear AND TicketTypeName IN ('Suite Rental','Suite Premium') THEN 1 ELSE 0 END AS CurrentSuiteRental,
CASE WHEN SeasonYear <@SeasonYear AND TicketTypeName IN ( 'Suite Rental','Suite Premium') THEN 1 ELSE 0 END AS FormerSuiteRental
INTO #stg2
FROM #flgstg
ORDER BY SSB_CRMSYSTEM_CONTACT_ID

IF OBJECT_ID('tempdb..#finaltbl') IS NOT NULL
	DROP TABLE #finaltbl
SELECT SSB_CRMSYSTEM_CONTACT_ID,
       --MAX(CurrentSeasonTicketMember) CurrentSTM,
       MAX(FormerSeasonTicketMember) FormerSTM,
       --MAX(CurrentSeasonGASTM) CurrentGASTM,
       MAX(FormerSeasonGASTM) FormerGASTM,
       --MAX(CurrentSeasonClubSTM) CurrentClubSTM,
       MAX(FormerSeasonClubSTM) FormerClubSTM,
       --MAX(CurrentFanPlan) CurrentFanPlan,
       MAX(FormerFanPlan) FormerFanPlan,
       --MAX(CurrentSGB) CurrentSGB,
       MAX(FormerSGB) FormerSGB,
       --MAX(CurrentGroup) CurrentGroup,
       MAX(FormerGroup) FormerGroup,
       --MAX(CurrentTunnelClub) CurrentTunnelClub,
       MAX(FormerTunnelClub) FormerTunnelClub,
       --MAX(CurrentLoge) CurrentLoge,
       MAX(FormerLoge) FormerLoge,
       --MAX(CurrentSuiteLease) CurrentSuiteLease,
       MAX(FormerSuiteLease) FormerSuiteLease,
       --MAX(CurrentSuiteRental) CurrentSuiteRental,
       MAX(FormerSuiteRental) FormerSuiteRental
INTO #finaltbl
FROM #stg2
GROUP BY SSB_CRMSYSTEM_CONTACT_ID;

UPDATE c
SET 
--c.lions_flag_CurrentSeasonTicketMember = f.CurrentSTM,
c.lions_flag_FormerSeasonTicketMember = f.FormerSTM,
--c.lions_flag_CurrentGASTM = f.CurrentGASTM,
c.lions_flag_FormerGASTM = f.FormerGASTM,
--c.lions_flag_CurrentPremiumClubSTM = f.CurrentClubSTM,
c.lions_flag_FormerPremiumClubSTM = f.FormerClubSTM,
--c.lions_flag_CurrentLogeBoxSTM = f.CurrentLoge,
c.lions_flag_FormerLogeBoxSTM = f.FormerLoge,
--c.lions_flag_CurrentTunnelClubSTM = f.CurrentTunnelClub,
c.lions_flag_FormerTunnelClubSTM = f.FormerTunnelClub,
--c.lions_flag_CurrentFanPlan = f.CurrentFanPlan,
c.lions_flag_FormerFanPlan = f.FormerFanPlan,
--c.lions_flag_CurrentSingleGameBuyer = f.CurrentSGB,
c.lions_flag_FormerSingleGameBuyer = f.FormerSGB,
--c.lions_flag_CurrentGroup = f.CurrentGroup,
c.lions_flag_FormerGroup = f.FormerGroup,
--c.lions_flag_CurrentSuiteLeaseHolder = f.CurrentSuiteLease,
c.lions_flag_FormerSuiteLeaseHolder = f.FormerSuiteLease,
--c.lions_flag_CurrentSuiteRental = f.CurrentSuiteRental,
c.lions_flag_FormerSuiteRental = f.FormerSuiteRental
FROM dbo.Contact_Custom c
JOIN #finaltbl f ON f.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID



/******************************
Custom Ticket Fields -- TM Specific
CTW 03/20/18
********************************/

IF OBJECT_ID('tempdb..#flgstgTM') IS NOT NULL
	DROP TABLE #flgstgTM
SELECT DISTINCT ssbid.SSB_CRMSYSTEM_CONTACT_ID, dtt.TicketTypeName, dtt.Config_Category1 TicketTypeCategory, dpt.PlanTypeName, ds.SeasonYear, dtc.TicketClassName, dtc.Config_Category1 TicketClassCategory, dtc.TicketClass
INTO #flgstgTM
FROM lions.dbo.FactTicketSales_V2 fts (NOLOCK)
JOIN lions.dbo.DimTicketType_V2 dtt (NOLOCK) ON dtt.DimTicketTypeId = fts.DimTicketTypeId
JOIN lions.dbo.DimPlanType_V2 dpt (NOLOCK) ON dpt.DimPlanTypeId = fts.DimPlanTypeId
JOIN lions.dbo.DimSeason_V2 ds (NOLOCK) ON ds.DimSeasonId = fts.DimSeasonId
JOIN lions.dbo.DimTicketClass_V2 dtc (NOLOCK) ON dtc.DimTicketClassId = fts.DimTicketClassId
JOIN lions.dbo.DimCustomer dc (NOLOCK) ON dc.AccountId = fts.ETL__SSID_TM_acct_id AND dc.SourceSystem = 'TM' AND dc.CustomerType = 'Primary'
JOIN lions.dbo.dimcustomerssbid ssbid (NOLOCK) ON ssbid.DimCustomerId = dc.DimCustomerId
WHERE dtc.TicketClassName != 'Parking'
ORDER BY ssbid.SSB_CRMSYSTEM_CONTACT_ID, ds.SeasonYear

DECLARE @SeasonYearTM INT
SET @SeasonYearTM = CASE WHEN MONTH(GETDATE()) IN (4,5,6,7,8,9,10,11,12) THEN YEAR(GETDATE()) ELSE YEAR(GETDATE()) - 1 END

IF OBJECT_ID('tempdb..#stg2TM') IS NOT NULL
	DROP TABLE #stg2TM
SELECT SSB_CRMSYSTEM_CONTACT_ID, CASE WHEN SeasonYear = @SeasonYear 
AND TicketTypeCategory='Full Season' THEN 1 ELSE 0 END AS CurrentSeasonTicketMember,
--CASE WHEN SeasonYear <@SeasonYear 
--AND TicketTypeCategory='Full Season' THEN 1 ELSE 0 END AS FormerSeasonTicketMember,
CASE WHEN SeasonYear = @SeasonYear 
AND TicketTypeCategory= 'Full Season' AND TicketClassCategory NOT IN ('Club', 'Field Level') THEN 1 ELSE 0 END AS CurrentSeasonGASTM,
--CASE WHEN SeasonYear < @SeasonYear 
--AND TicketTypeCategory= 'Full Season' AND TicketClassCategory NOT IN ('Club', 'Field Level') THEN 1 ELSE 0 END AS FormerSeasonGASTM,
CASE WHEN SeasonYear = @SeasonYear 
AND TicketTypeCategory= 'Full Season' AND TicketClassCategory NOT IN ('Club', 'Field Level') THEN 1 ELSE 0 END AS CurrentSeasonClubSTM,
--CASE WHEN SeasonYear < @SeasonYear 
--AND TicketTypeCategory= 'Full Season' AND TicketClassCategory NOT IN ('Club', 'Field Level') THEN 1 ELSE 0 END AS FormerSeasonClubSTM,
CASE WHEN SeasonYear = @SeasonYear
AND TicketTypeName='Fan Plan' THEN 1 ELSE 0 END AS CurrentFanPlan,
--CASE WHEN SeasonYear <@SeasonYear 
--AND TicketTypeName='Fan Plan' THEN 1 ELSE 0 END AS FormerFanPlan,
CASE WHEN SeasonYear = @SeasonYear 
AND TicketTypeCategory = 'Single Game' THEN 1 ELSE 0 END AS CurrentSGB,
--CASE WHEN SeasonYear <@SeasonYear 
--AND TicketTypeCategory = 'Single Game' THEN 1 ELSE 0 END AS FormerSGB,
CASE WHEN SeasonYear = @SeasonYear 
AND TicketTypeCategory = 'Group' THEN 1 ELSE 0 END AS CurrentGroup,
--CASE WHEN SeasonYear <@SeasonYear 
--AND TicketTypeCategory = 'Group' THEN 1 ELSE 0 END AS FormerGroup,
--CASE WHEN SeasonYear = @SeasonYear AND PriceCodeDesc LIKE '%Tunnel Club%' AND PriceCodeDesc NOT LIKE '%Wait List' THEN 1 ELSE 0 END AS CurrentTunnelClub,
--CASE WHEN SeasonYear <@SeasonYear AND PriceCodeDesc LIKE '%Tunnel Club%' AND PriceCodeDesc NOT LIKE '%Wait List' THEN 1 ELSE 0 END AS FormerTunnelClub,
0 AS CurrentTunnelClub,
--NULL AS FormerTunnelClub,
CASE WHEN SeasonYear = @SeasonYear 
AND TicketClassCategory = 'Loge' THEN 1 ELSE 0 END AS CurrentLoge,
--CASE WHEN SeasonYear <@SeasonYear 
--AND TicketTypeCategory = 'Loge' THEN 1 ELSE 0 END AS FormerLoge,
CASE WHEN SeasonYear = @SeasonYear 
AND TicketTypeName = 'Suite License' THEN 1 ELSE 0 END AS CurrentSuiteLease,
--CASE WHEN SeasonYear <@SeasonYear 
--AND TicketTypeName = 'Suite License' THEN 1 ELSE 0 END AS FormerSuiteLease,
CASE WHEN SeasonYear = @SeasonYear 
AND TicketTypeName IN ('Suite Rental','Suite Premium') THEN 1 ELSE 0 END AS CurrentSuiteRental
--,CASE WHEN SeasonYear <@SeasonYear 
--AND TicketTypeName IN ( 'Suite Rental','Suite Premium') THEN 1 ELSE 0 END AS FormerSuiteRental
INTO #stg2TM
FROM #flgstgTM
ORDER BY SSB_CRMSYSTEM_CONTACT_ID

IF OBJECT_ID('tempdb..#finaltblTM') IS NOT NULL
    DROP TABLE #finaltblTM;
SELECT SSB_CRMSYSTEM_CONTACT_ID,
       MAX(CurrentSeasonTicketMember) CurrentSTM,
--       MAX(FormerSeasonTicketMember) FormerSTM,
       MAX(CurrentSeasonGASTM) CurrentGASTM,
--       MAX(FormerSeasonGASTM) FormerGASTM,
       MAX(CurrentSeasonClubSTM) CurrentClubSTM,
--       MAX(FormerSeasonClubSTM) FormerClubSTM,
       MAX(CurrentFanPlan) CurrentFanPlan,
--       MAX(FormerFanPlan) FormerFanPlan,
       MAX(CurrentSGB) CurrentSGB,
--       MAX(FormerSGB) FormerSGB,
       MAX(CurrentGroup) CurrentGroup,
--       MAX(FormerGroup) FormerGroup,
       MAX(CurrentTunnelClub) CurrentTunnelClub,
--       MAX(FormerTunnelClub) FormerTunnelClub,
       MAX(CurrentLoge) CurrentLoge,
--       MAX(FormerLoge) FormerLoge,
       MAX(CurrentSuiteLease) CurrentSuiteLease,
--       MAX(FormerSuiteLease) FormerSuiteLease,
       MAX(CurrentSuiteRental) CurrentSuiteRental
--       ,MAX(FormerSuiteRental) FormerSuiteRental
INTO #finaltblTM
FROM #stg2TM
GROUP BY SSB_CRMSYSTEM_CONTACT_ID;

UPDATE c
SET c.lions_flag_CurrentSeasonTicketMember = f.CurrentSTM,
--c.lions_flag_FormerSeasonTicketMember = f.FormerSTM,
c.lions_flag_CurrentGASTM = f.CurrentGASTM,
--c.lions_flag_FormerGASTM = f.FormerGASTM,
c.lions_flag_CurrentPremiumClubSTM = f.CurrentClubSTM,
--c.lions_flag_FormerPremiumClubSTM = f.FormerClubSTM,
c.lions_flag_CurrentLogeBoxSTM = f.CurrentLoge,
--c.lions_flag_FormerLogeBoxSTM = f.FormerLoge,
c.lions_flag_CurrentTunnelClubSTM = f.CurrentTunnelClub,
--c.lions_flag_FormerTunnelClubSTM = f.FormerTunnelClub,
c.lions_flag_CurrentFanPlan = f.CurrentFanPlan,
--c.lions_flag_FormerFanPlan = f.FormerFanPlan,
c.lions_flag_CurrentSingleGameBuyer = f.CurrentSGB,
--c.lions_flag_FormerSingleGameBuyer = f.FormerSGB,
c.lions_flag_CurrentGroup = f.CurrentGroup,
--c.lions_flag_FormerGroup = f.FormerGroup,
c.lions_flag_CurrentSuiteLeaseHolder = f.CurrentSuiteLease,
--c.lions_flag_FormerSuiteLeaseHolder = f.FormerSuiteLease,
c.lions_flag_CurrentSuiteRental = f.CurrentSuiteRental
--,c.lions_flag_FormerSuiteRental = f.FormerSuiteRental
FROM dbo.Contact_Custom c
JOIN #finaltblTM f ON f.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID

/***************************
County Field
CTW 01/08/18
****************************/

UPDATE c
SET c.address1_county = cr.AddressPrimaryCounty
FROM dbo.Contact_Custom c
JOIN dbo.vwCompositeRecord_ModAcctID cr ON cr.SSB_CRMSYSTEM_CONTACT_ID = c.SSB_CRMSYSTEM_CONTACT_ID

EXEC dbo.sp_CRMLoad_Contact_ProcessLoad_Criteria


/***************************
Account Numbers 
CTW 06/06/18
****************************/

--default for new records being created that don't have an owner --Process Load Criteria sproc must run before this in order for this to work.
UPDATE contact_custom 
SET ownerid = '3BD5B80F-673A-E711-811D-C4346BACA998', owneridtype = 'systemuser'
--SELECT COUNT(*)
 FROM contact_custom cc
INNER JOIN dbo.CRMLoad_Contact_ProcessLoad_Criteria pl
ON pl.SSB_CRMSYSTEM_CONTACT_ID = cc.SSB_CRMSYSTEM_CONTACT_ID
WHERE pl.LoadType = 'upsert' AND cc.ownerid IS NULL

GO
