SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO












CREATE VIEW [dbo].[vwCRMLoad_Contact_Custom_Update]
AS

SELECT  z.[crm_id] contactid
, b.SSID_Winner AS new_ssbcrmsystemssidwinner												--, c.new_ssbcrmsystemssidwinner
, b.new_ssbcrmsystemSSIDWinnerSourceSystem													--, c.new_ssbcrmsystemSSIDWinnerSourceSystem
, NULLIF(b.VX_Ids,'') AS str_number															--, c.str_number
, DimCustIDs new_ssbcrmsystemdimcustomerids													--, c.new_ssbcrmsystemdimcustomerids
, b.AccountId [new_ssbcrmsystemarchticsids]													--, c.[new_ssbcrmsystemarchticsids]
--, NULLIF(z.EmailPrimary,'') AS emailaddress1 --Handled in standard update					--, c.
, b.mobilephone 																			--, c.mobilephone
, b.telephone2 --home phone																	--, c.telephone2
, b.ownerid																					--, c.ownerid
, b.owneridtype																				--, c.owneridtype
, b.parentcustomerid																		--, c.parentcustomerid
, b.parentcustomeridtype																	--, c.parentcustomeridtype
, b.lions_primaryaccountid																	--, c.lions_primaryaccountid
, b.gendercode																				--, c.gendercode
, b.lions_dem_DistancetoStadium																--, c.lions_dem_DistancetoStadium					
, b.lions_dem_PersonicxCluster																--, c.lions_dem_PersonicxCluster					
, b.lions_dem_BusinessOwner																	--, c.lions_dem_BusinessOwner						
, b.lions_dem_Veteran																		--, c.lions_dem_Veteran							
, b.lions_dem_OccupationDetail																--, c.lions_dem_OccupationDetail					
, b.lions_dem_HomePropertyType																--, c.lions_dem_HomePropertyType					
, b.lions_dem_HomeYearBuilt																	--, c.lions_dem_HomeYearBuilt						
, b.lions_dem_HomeOwnerRenter																--, c.lions_dem_HomeOwnerRenter					
, b.lions_dem_HomeLengthofResidence															--, c.lions_dem_HomeLengthofResidence				
, ISNULL(b.familystatuscode, c.familystatuscode) familystatuscode							--, c.familystatuscode							
, b.lions_dem_PresenceofChildren															--, c.lions_dem_PresenceofChildren				
, b.str_agerange																			--, c.str_agerange								
, b.lions_dem_Occupation																	--, c.lions_dem_Occupation						
, b.lions_dem_HomeMarketValue																--, c.lions_dem_HomeMarketValue					
, b.lions_dem_NewCarBuyer																	--, c.lions_dem_NewCarBuyer						
, b.lions_dem_KnownOwnedVehicles															--, c.lions_dem_KnownOwnedVehicles				
, b.lions_dem_DominantVehicleLifestyle														--, c.lions_dem_DominantVehicleLifestyle			
, b.lions_dem_EducationLevel																--, c.lions_dem_EducationLevel		
, b.[lions_dem_hhincome]																	--, c.[lions_dem_hhincome]					
, b.lions_flag_CurrentSeasonTicketMember													--, c.lions_flag_CurrentSeasonTicketMember		
, b.lions_flag_FormerSeasonTicketMember														--, c.lions_flag_FormerSeasonTicketMember			
, b.lions_flag_CurrentGASTM																	--, c.lions_flag_CurrentGASTM						
, b.lions_flag_FormerGASTM																	--, c.lions_flag_FormerGASTM						
, b.lions_flag_CurrentPremiumClubSTM														--, c.lions_flag_CurrentPremiumClubSTM			
, b.lions_flag_FormerPremiumClubSTM															--, c.lions_flag_FormerPremiumClubSTM				
, b.lions_flag_CurrentLogeBoxSTM															--, c.lions_flag_CurrentLogeBoxSTM				
, b.lions_flag_FormerLogeBoxSTM																--, c.lions_flag_FormerLogeBoxSTM					
, b.lions_flag_CurrentTunnelClubSTM															--, c.lions_flag_CurrentTunnelClubSTM				
, b.lions_flag_FormerTunnelClubSTM															--, c.lions_flag_FormerTunnelClubSTM				
, b.lions_flag_CurrentFanPlan																--, c.lions_flag_CurrentFanPlan					
, b.lions_flag_FormerFanPlan																--, c.lions_flag_FormerFanPlan					
, b.lions_flag_CurrentSingleGameBuyer														--, c.lions_flag_CurrentSingleGameBuyer			
, b.lions_flag_FormerSingleGameBuyer														--, c.lions_flag_FormerSingleGameBuyer			
, b.lions_flag_CurrentGroup																	--, c.lions_flag_CurrentGroup						
, b.lions_flag_FormerGroup																	--, c.lions_flag_FormerGroup						
--, b.lions_flag_CurrentSecondaryMarketBuyer												--, c.lions_flag_CurrentSecondaryMarketBuyer		
--, b.lions_flag_FormerSecondaryMarketBuyer													--, c.lions_flag_FormerSecondaryMarketBuyer		
--, b.lions_flag_CurrentEventBuyer															--, c.lions_flag_CurrentEventBuyer				
--, b.lions_flag_FormerEventBuyer															--, c.lions_flag_FormerEventBuyer					
--, b.lions_flag_CurrentLionsFlashRecipient													--, c.lions_flag_CurrentLionsFlashRecipient		
--, b.lions_flag_FormerLionsFlashRecipient													--, c.lions_flag_FormerLionsFlashRecipient		
, b.lions_flag_CurrentSuiteLeaseHolder														--, c.lions_flag_CurrentSuiteLeaseHolder			
, b.lions_flag_FormerSuiteLeaseHolder														--, c.lions_flag_FormerSuiteLeaseHolder			
, b.lions_flag_CurrentSuiteRental															--, c.lions_flag_CurrentSuiteRental				
, b.lions_flag_FormerSuiteRental															--, c.lions_flag_FormerSuiteRental				
--, b.lions_flag_WiFiUser																	--, c.lions_flag_WiFiUser							
--, b.lions_flag_MobileAppDownload															--, c.lions_flag_MobileAppDownload				
--, b.lions_flag_CurrentOnlineMerchBuyer													--, c.lions_flag_CurrentOnlineMerchBuyer			
--, b.lions_flag_FormerOnlineMerchBuyer														--, c.lions_flag_FormerOnlineMerchBuyer			
--, b.lions_flag_CurrentCubClubMember														--, c.lions_flag_CurrentCubClubMember				
--, b.lions_flag_FormerCubClubMember														--, c.lions_flag_FormerCubClubMember				
--, b.lions_flag_CurrentYouthFootballParticipant											--, c.lions_flag_CurrentYouthFootballParticipant	
--, b.lions_flag_FormerYouthFootballParticipant												--, c.lions_flag_FormerYouthFootballParticipant	
--, b.lions_flag_LionsAlumni																--, c.lions_flag_LionsAlumni	
, b.address1_county			

	--, case when ISNULL(b.SSID_Winner									,'') != ISNULL(c.new_ssbcrmsystemssidwinner,'')								 then 1 else 0 end as new_ssbcrmsystemssidwinner
	--, case when ISNULL(b.new_ssbcrmsystemSSIDWinnerSourceSystem		,'') != ISNULL(c.new_ssbcrmsystemSSIDWinnerSourceSystem,'')						 then 1 else 0 end as new_ssbcrmsystemSSIDWinnerSourceSystem
	--, case when ISNULL(b.VX_Ids										,'') != ISNULL(c.str_number,'')													 then 1 else 0 end as str_number
	--, case when ISNULL(b.DimCustIDs									,'') != ISNULL(c.new_ssbcrmsystemdimcustomerids,'')								 then 1 else 0 end as new_ssbcrmsystemdimcustomerids
	----, case when ISNULL(b.AccountId									,'') != ISNULL(c.[new_ssbcrmsystemarchticsids],'')							 then 1 else 0 end as 
	----, case when ISNULL(z.EmailPrimary								,'') != ISNULL(c.emailaddress1,'')												 then 1 else 0 end as 
	--, case when ISNULL(b.mobilephone									,'') != ISNULL(c.mobilephone,'')											 then 1 else 0 end as mobilephone
	--, case when ISNULL(b.telephone2									,'') != ISNULL(c.telephone2,'')													 then 1 else 0 end as telephone2
	--, case when ISNULL(b.ownerid										,'') != ISNULL(CAST(c.ownerid AS NVARCHAR(100)),'')							 then 1 else 0 end as ownerid
	--, case when ISNULL(b.parentcustomerid							,'') != ISNULL(CAST(c.parentcustomerid AS NVARCHAR(100)),'')					 then 1 else 0 end as parentcustomerid
	--, case when ISNULL(b.parentcustomeridtype						,'') != ISNULL(c.parentcustomeridtype,'')										 then 1 else 0 end as parentcustomeridtype
	--, case when ISNULL(b.lions_primaryaccountid						,'') != ISNULL(c.lions_primaryaccountid,'')										 then 1 else 0 end as lions_primaryaccountid
	--, case when ISNULL(b.lions_dem_DistancetoStadium					,'') != ISNULL(c.lions_dem_DistancetoStadium,'')							 then 1 else 0 end as lions_dem_DistancetoStadium
	--, case when ISNULL(b.lions_dem_PersonicxCluster					,'') != ISNULL(c.lions_dem_PersonicxCluster	,'')								 then 1 else 0 end as lions_dem_PersonicxCluster
	--, case when ISNULL(b.lions_dem_BusinessOwner						,'') != ISNULL(c.lions_dem_BusinessOwner,'')								 then 1 else 0 end as lions_dem_BusinessOwner
	--, case when ISNULL(b.lions_dem_Veteran							,'') != ISNULL(c.lions_dem_Veteran,'')											 then 1 else 0 end as lions_dem_Veteran
	--, case when ISNULL(b.lions_dem_OccupationDetail					,'') != ISNULL(c.lions_dem_OccupationDetail,'')									 then 1 else 0 end as lions_dem_OccupationDetail
	--, case when ISNULL(b.lions_dem_HomePropertyType					,'') != ISNULL(c.lions_dem_HomePropertyType,'')									 then 1 else 0 end as lions_dem_HomePropertyType
	--, case when ISNULL(b.lions_dem_HomeYearBuilt						,'') != ISNULL(c.lions_dem_HomeYearBuilt,'')								 then 1 else 0 end as lions_dem_HomeYearBuilt
	--, case when ISNULL(b.lions_dem_HomeOwnerRenter					,'') != ISNULL(c.lions_dem_HomeOwnerRenter,'')									 then 1 else 0 end as lions_dem_HomeOwnerRenter
	--, case when ISNULL(b.lions_dem_HomeLengthofResidence				,'') != ISNULL(c.lions_dem_HomeLengthofResidence,'')						 then 1 else 0 end as lions_dem_HomeLengthofResidence
	--, case when ISNULL(b.familystatuscode, c.familystatuscode)							 != ISNULL(convert(nvarchar(100),c.familystatuscode),'')					 then 1 else 0 end as familystatuscode
	--, case when ISNULL(b.lions_dem_PresenceofChildren				,'') != ISNULL(c.lions_dem_PresenceofChildren,'')								 then 1 else 0 end as lions_dem_PresenceofChildren
	--, case when ISNULL(b.str_agerange								,'') != ISNULL(c.str_agerange,'')												 then 1 else 0 end as str_agerange
	--, case when ISNULL(b.lions_dem_Occupation						,'') != ISNULL(c.lions_dem_Occupation,'')										 then 1 else 0 end as lions_dem_Occupation
	--, case when ISNULL(b.lions_dem_HomeMarketValue					,'') != ISNULL(c.lions_dem_HomeMarketValue,'')									 then 1 else 0 end as lions_dem_HomeMarketValue
	--, case when ISNULL(b.lions_dem_NewCarBuyer						,'') != ISNULL(c.lions_dem_NewCarBuyer,'')										 then 1 else 0 end as lions_dem_NewCarBuyer
	--, case when ISNULL(b.lions_dem_KnownOwnedVehicles				,'') != ISNULL(c.lions_dem_KnownOwnedVehicles,'')								 then 1 else 0 end as lions_dem_KnownOwnedVehicles
	--, case when ISNULL(b.lions_dem_DominantVehicleLifestyle			,'') != ISNULL(c.lions_dem_DominantVehicleLifestyle,'')							 then 1 else 0 end as lions_dem_DominantVehicleLifestyle
	--, case when ISNULL(b.lions_dem_EducationLevel					,'') != ISNULL(c.lions_dem_EducationLevel,'')									 then 1 else 0 end as lions_dem_EducationLevel
	--, case when ISNULL(b.[lions_dem_hhincome]						,'') != ISNULL(c.[lions_dem_hhincome],'')										 then 1 else 0 end as [lions_dem_hhincome]
	----, case when ISNULL(b.lions_flag_CurrentSeasonTicketMember		,'') != ISNULL(c.lions_flag_CurrentSeasonTicketMember		,'')				 then 1 else 0 end as lions_flag_CurrentSeasonTicketMember
	----, case when ISNULL(b.lions_flag_FormerSeasonTicketMember			,'') != ISNULL(c.lions_flag_FormerSeasonTicketMember			,'')		 then 1 else 0 end as lions_flag_FormerSeasonTicketMember
	----, case when ISNULL(b.lions_flag_CurrentGASTM						,'') != ISNULL(c.lions_flag_CurrentGASTM						,'')		 then 1 else 0 end as lions_flag_CurrentGASTM
	----, case when ISNULL(b.lions_flag_FormerGASTM						,'') != ISNULL(c.lions_flag_FormerGASTM						,'')				 then 1 else 0 end as lions_flag_FormerGASTM
	----, case when ISNULL(b.lions_flag_CurrentPremiumClubSTM			,'') != ISNULL(c.lions_flag_CurrentPremiumClubSTM			,'')				 then 1 else 0 end as lions_flag_CurrentPremiumClubSTM
	----, case when ISNULL(b.lions_flag_FormerPremiumClubSTM				,'') != ISNULL(c.lions_flag_FormerPremiumClubSTM				,'')		 then 1 else 0 end as lions_flag_FormerPremiumClubSTM
	----, case when ISNULL(b.lions_flag_CurrentLogeBoxSTM				,'') != ISNULL(c.lions_flag_CurrentLogeBoxSTM				,'')				 then 1 else 0 end as lions_flag_CurrentLogeBoxSTM
	----, case when ISNULL(b.lions_flag_FormerLogeBoxSTM					,'') != ISNULL(c.lions_flag_FormerLogeBoxSTM					,'')		 then 1 else 0 end as lions_flag_FormerLogeBoxSTM
	----, case when ISNULL(b.lions_flag_CurrentTunnelClubSTM				,'') != ISNULL(c.lions_flag_CurrentTunnelClubSTM				,'')		 then 1 else 0 end as lions_flag_CurrentTunnelClubSTM
	----, case when ISNULL(b.lions_flag_FormerTunnelClubSTM				,'') != ISNULL(c.lions_flag_FormerTunnelClubSTM				,'')				 then 1 else 0 end as lions_flag_FormerTunnelClubSTM
	----, case when ISNULL(b.lions_flag_CurrentFanPlan					,'') != ISNULL(c.lions_flag_CurrentFanPlan					,'')				 then 1 else 0 end as lions_flag_CurrentFanPlan
	----, case when ISNULL(b.lions_flag_FormerFanPlan					,'') != ISNULL(c.lions_flag_FormerFanPlan					,'')				 then 1 else 0 end as lions_flag_FormerFanPlan
	----, case when ISNULL(b.lions_flag_CurrentSingleGameBuyer			,'') != ISNULL(c.lions_flag_CurrentSingleGameBuyer			,'')				 then 1 else 0 end as lions_flag_CurrentSingleGameBuyer
	----, case when ISNULL(b.lions_flag_FormerSingleGameBuyer			,'') != ISNULL(c.lions_flag_FormerSingleGameBuyer			,'')				 then 1 else 0 end as lions_flag_FormerSingleGameBuyer
	----, case when ISNULL(b.lions_flag_CurrentGroup						,'') != ISNULL(c.lions_flag_CurrentGroup						,'')		 then 1 else 0 end as lions_flag_CurrentGroup
	----, case when ISNULL(b.lions_flag_FormerGroup						,'') != ISNULL(c.lions_flag_FormerGroup						,'')				 then 1 else 0 end as lions_flag_FormerGroup
	----, case when ISNULL(b.lions_flag_CurrentSecondaryMarketBuyer		,'') != ISNULL(c.lions_flag_CurrentSecondaryMarketBuyer		,'')				 then 1 else 0 end as lions_flag_CurrentSecondaryMarketBuyer
	----, case when ISNULL(b.lions_flag_FormerSecondaryMarketBuyer		,'') != ISNULL(c.lions_flag_FormerSecondaryMarketBuyer		,'')				 then 1 else 0 end as lions_flag_FormerSecondaryMarketBuyer
	----, case when ISNULL(b.lions_flag_CurrentEventBuyer				,'') != ISNULL(c.lions_flag_CurrentEventBuyer				,'')				 then 1 else 0 end as lions_flag_CurrentEventBuyer
	----, case when ISNULL(b.lions_flag_FormerEventBuyer					,'') != ISNULL(c.lions_flag_FormerEventBuyer					,'')		 then 1 else 0 end as lions_flag_FormerEventBuyer
	----, case when ISNULL(b.lions_flag_CurrentLionsFlashRecipient		,'') != ISNULL(c.lions_flag_CurrentLionsFlashRecipient		,'')				 then 1 else 0 end as lions_flag_CurrentLionsFlashRecipient
	----, case when ISNULL(b.lions_flag_FormerLionsFlashRecipient		,'') != ISNULL(c.lions_flag_FormerLionsFlashRecipient		,'')				 then 1 else 0 end as lions_flag_FormerLionsFlashRecipient
	----, case when ISNULL(b.lions_flag_CurrentSuiteLeaseHolder			,'') != ISNULL(c.lions_flag_CurrentSuiteLeaseHolder			,'')				 then 1 else 0 end as lions_flag_CurrentSuiteLeaseHolder
	----, case when ISNULL(b.lions_flag_FormerSuiteLeaseHolder			,'') != ISNULL(c.lions_flag_FormerSuiteLeaseHolder			,'')				 then 1 else 0 end as lions_flag_FormerSuiteLeaseHolder
	----, case when ISNULL(b.lions_flag_CurrentSuiteRental				,'') != ISNULL(c.lions_flag_CurrentSuiteRental				,'')				 then 1 else 0 end as lions_flag_CurrentSuiteRental
	----, case when ISNULL(b.lions_flag_FormerSuiteRental				,'') != ISNULL(c.lions_flag_FormerSuiteRental				,'')				 then 1 else 0 end as lions_flag_FormerSuiteRental
	----, case when ISNULL(b.lions_flag_WiFiUser							,'') != ISNULL(c.lions_flag_WiFiUser							,'')		 then 1 else 0 end as lions_flag_WiFiUser
	----, case when ISNULL(b.lions_flag_MobileAppDownload				,'') != ISNULL(c.lions_flag_MobileAppDownload				,'')				 then 1 else 0 end as lions_flag_MobileAppDownload
	----, case when ISNULL(b.lions_flag_CurrentOnlineMerchBuyer			,'') != ISNULL(c.lions_flag_CurrentOnlineMerchBuyer			,'')				 then 1 else 0 end as lions_flag_CurrentOnlineMerchBuyer
	----, case when ISNULL(b.lions_flag_FormerOnlineMerchBuyer			,'') != ISNULL(c.lions_flag_FormerOnlineMerchBuyer			,'')				 then 1 else 0 end as lions_flag_FormerOnlineMerchBuyer
	----, case when ISNULL(b.lions_flag_CurrentCubClubMember				,'') != ISNULL(c.lions_flag_CurrentCubClubMember				,'')		 then 1 else 0 end as lions_flag_CurrentCubClubMember
	----, case when ISNULL(b.lions_flag_FormerCubClubMember				,'') != ISNULL(c.lions_flag_FormerCubClubMember				,'')				 then 1 else 0 end as lions_flag_FormerCubClubMember
	----, case when ISNULL(b.lions_flag_CurrentYouthFootballParticipant	,'') != ISNULL(c.lions_flag_CurrentYouthFootballParticipant	,'')				 then 1 else 0 end as lions_flag_CurrentYouthFootballParticipant
	----, case when ISNULL(b.lions_flag_FormerYouthFootballParticipant	,'') != ISNULL(c.lions_flag_FormerYouthFootballParticipant	,'')				 then 1 else 0 end as lions_flag_FormerYouthFootballParticipant
	----, case when ISNULL(b.lions_flag_LionsAlumni						,'') != ISNULL(c.lions_flag_LionsAlumni						,'')				 then 1 else 0 end as lions_flag_LionsAlumni

--, c.new_ssbcrmsystemssidwinner, c.new_ssbcrmsystemSSIDWinnerSourceSystem, c.str_number, c.new_ssbcrmsystemdimcustomerids, c.emailaddress1, c.mobilephone, c.telephone2, c.ownerid, c.owneridtype, c.parentcustomerid, c.parentcustomeridtype
-- SELECT *
-- SELECT b.new_ssbcrmsystemSSIDWinnerSourceSystem, COUNT(*) 
FROM dbo.[Contact_Custom] b 
INNER JOIN dbo.Contact z ON b.SSB_CRMSYSTEM_CONTACT_ID = z.[SSB_CRMSYSTEM_CONTACT_ID]
LEFT JOIN  prodcopy.vw_contact c ON z.[crm_id] = c.contactID
--INNER JOIN dbo.CRMLoad_Contact_ProcessLoad_Criteria pl ON b.SSB_CRMSYSTEM_CONTACT_ID = pl.SSB_CRMSYSTEM_CONTACT_ID
WHERE 1=1
AND z.[SSB_CRMSYSTEM_CONTACT_ID] <> z.[crm_id]
--	)
		AND ( 1=2
		OR ISNULL(b.SSID_Winner									,'') != ISNULL(c.new_ssbcrmsystemssidwinner,'')
		OR ISNULL(b.new_ssbcrmsystemSSIDWinnerSourceSystem		,'') != ISNULL(c.new_ssbcrmsystemSSIDWinnerSourceSystem,'')
		OR ISNULL(b.VX_Ids										,'') != ISNULL(c.str_number,'')
		OR ISNULL(b.DimCustIDs									,'') != ISNULL(c.new_ssbcrmsystemdimcustomerids,'')
		--OR ISNULL(b.AccountId									,'') != ISNULL(c.[new_ssbcrmsystemarchticsids],'')
		--OR ISNULL(z.EmailPrimary								,'') != ISNULL(c.emailaddress1,'')
		OR ISNULL(b.mobilephone									,'') != ISNULL(c.mobilephone,'')
		OR ISNULL(b.telephone2									,'') != ISNULL(c.telephone2,'')
		OR ISNULL(b.ownerid										,'') != ISNULL(CAST(c.ownerid AS NVARCHAR(100)),'')
		OR ISNULL(b.parentcustomerid							,'') != ISNULL(CAST(c.parentcustomerid AS NVARCHAR(100)),'')
		OR ISNULL(b.parentcustomeridtype						,'') != ISNULL(c.parentcustomeridtype,'')
		OR ISNULL(b.lions_primaryaccountid						,'') != ISNULL(c.lions_primaryaccountid,'')
		OR ISNULL(b.lions_dem_DistancetoStadium					,'') != ISNULL(c.lions_dem_DistancetoStadium,'')
		OR ISNULL(b.lions_dem_PersonicxCluster					,'') != ISNULL(c.lions_dem_PersonicxCluster	,'')
		OR ISNULL(b.lions_dem_BusinessOwner						,'') != ISNULL(c.lions_dem_BusinessOwner,'')
		OR ISNULL(b.lions_dem_Veteran							,'') != ISNULL(c.lions_dem_Veteran,'')
		OR ISNULL(b.lions_dem_OccupationDetail					,'') != ISNULL(c.lions_dem_OccupationDetail,'')
		OR ISNULL(b.lions_dem_HomePropertyType					,'') != ISNULL(c.lions_dem_HomePropertyType,'')
		OR ISNULL(b.lions_dem_HomeYearBuilt						,'') != ISNULL(c.lions_dem_HomeYearBuilt,'')
		OR ISNULL(b.lions_dem_HomeOwnerRenter					,'') != ISNULL(c.lions_dem_HomeOwnerRenter,'')
		OR ISNULL(b.lions_dem_HomeLengthofResidence				,'') != ISNULL(c.lions_dem_HomeLengthofResidence,'')
		OR ISNULL(b.familystatuscode, c.familystatuscode)							 != ISNULL(convert(nvarchar(100),c.familystatuscode),'')	-- DCH 2017-09-16
		OR ISNULL(b.lions_dem_PresenceofChildren				,'') != ISNULL(c.lions_dem_PresenceofChildren,'')
		OR ISNULL(b.str_agerange								,'') != ISNULL(c.str_agerange,'')
		OR ISNULL(b.lions_dem_Occupation						,'') != ISNULL(c.lions_dem_Occupation,'')
		OR ISNULL(b.lions_dem_HomeMarketValue					,'') != ISNULL(c.lions_dem_HomeMarketValue,'')
		OR ISNULL(b.lions_dem_NewCarBuyer						,'') != ISNULL(c.lions_dem_NewCarBuyer,'')
		OR ISNULL(b.lions_dem_KnownOwnedVehicles				,'') != ISNULL(c.lions_dem_KnownOwnedVehicles,'')
		OR ISNULL(b.lions_dem_DominantVehicleLifestyle			,'') != ISNULL(c.lions_dem_DominantVehicleLifestyle,'')
		OR ISNULL(b.lions_dem_EducationLevel					,'') != ISNULL(c.lions_dem_EducationLevel,'')
		OR ISNULL(b.[lions_dem_hhincome]						,'') != ISNULL(c.[lions_dem_hhincome],'')
		OR ISNULL(b.lions_flag_CurrentSeasonTicketMember		,'') != ISNULL(c.lions_flag_CurrentSeasonTicketMember		,'')
		OR ISNULL(b.lions_flag_FormerSeasonTicketMember			,'') != ISNULL(c.lions_flag_FormerSeasonTicketMember			,'')
		OR ISNULL(b.lions_flag_CurrentGASTM						,'') != ISNULL(c.lions_flag_CurrentGASTM						,'')
		OR ISNULL(b.lions_flag_FormerGASTM						,'') != ISNULL(c.lions_flag_FormerGASTM						,'')
		OR ISNULL(b.lions_flag_CurrentPremiumClubSTM			,'') != ISNULL(c.lions_flag_CurrentPremiumClubSTM			,'')
		OR ISNULL(b.lions_flag_FormerPremiumClubSTM				,'') != ISNULL(c.lions_flag_FormerPremiumClubSTM				,'')
		OR ISNULL(b.lions_flag_CurrentLogeBoxSTM				,'') != ISNULL(c.lions_flag_CurrentLogeBoxSTM				,'')
		OR ISNULL(b.lions_flag_FormerLogeBoxSTM					,'') != ISNULL(c.lions_flag_FormerLogeBoxSTM					,'')
		OR ISNULL(b.lions_flag_CurrentTunnelClubSTM				,'') != ISNULL(c.lions_flag_CurrentTunnelClubSTM				,'')
		OR ISNULL(b.lions_flag_FormerTunnelClubSTM				,'') != ISNULL(c.lions_flag_FormerTunnelClubSTM				,'')
		OR ISNULL(b.lions_flag_CurrentFanPlan					,'') != ISNULL(c.lions_flag_CurrentFanPlan					,'')
		OR ISNULL(b.lions_flag_FormerFanPlan					,'') != ISNULL(c.lions_flag_FormerFanPlan					,'')
		OR ISNULL(b.lions_flag_CurrentSingleGameBuyer			,'') != ISNULL(c.lions_flag_CurrentSingleGameBuyer			,'')
		OR ISNULL(b.lions_flag_FormerSingleGameBuyer			,'') != ISNULL(c.lions_flag_FormerSingleGameBuyer			,'')
		OR ISNULL(b.lions_flag_CurrentGroup						,'') != ISNULL(c.lions_flag_CurrentGroup						,'')
		OR ISNULL(b.lions_flag_FormerGroup						,'') != ISNULL(c.lions_flag_FormerGroup						,'')
		--OR ISNULL(b.lions_flag_CurrentSecondaryMarketBuyer		,'') != ISNULL(c.lions_flag_CurrentSecondaryMarketBuyer		,'')
		--OR ISNULL(b.lions_flag_FormerSecondaryMarketBuyer		,'') != ISNULL(c.lions_flag_FormerSecondaryMarketBuyer		,'')
		--OR ISNULL(b.lions_flag_CurrentEventBuyer				,'') != ISNULL(c.lions_flag_CurrentEventBuyer				,'')
		--OR ISNULL(b.lions_flag_FormerEventBuyer					,'') != ISNULL(c.lions_flag_FormerEventBuyer					,'')
		--OR ISNULL(b.lions_flag_CurrentLionsFlashRecipient		,'') != ISNULL(c.lions_flag_CurrentLionsFlashRecipient		,'')
		--OR ISNULL(b.lions_flag_FormerLionsFlashRecipient		,'') != ISNULL(c.lions_flag_FormerLionsFlashRecipient		,'')
		OR ISNULL(b.lions_flag_CurrentSuiteLeaseHolder			,'') != ISNULL(c.lions_flag_CurrentSuiteLeaseHolder			,'')
		OR ISNULL(b.lions_flag_FormerSuiteLeaseHolder			,'') != ISNULL(c.lions_flag_FormerSuiteLeaseHolder			,'')
		OR ISNULL(b.lions_flag_CurrentSuiteRental				,'') != ISNULL(c.lions_flag_CurrentSuiteRental				,'')
		OR ISNULL(b.lions_flag_FormerSuiteRental				,'') != ISNULL(c.lions_flag_FormerSuiteRental				,'')
		--OR ISNULL(b.lions_flag_WiFiUser							,'') != ISNULL(c.lions_flag_WiFiUser							,'')
		--OR ISNULL(b.lions_flag_MobileAppDownload				,'') != ISNULL(c.lions_flag_MobileAppDownload				,'')
		--OR ISNULL(b.lions_flag_CurrentOnlineMerchBuyer			,'') != ISNULL(c.lions_flag_CurrentOnlineMerchBuyer			,'')
		--OR ISNULL(b.lions_flag_FormerOnlineMerchBuyer			,'') != ISNULL(c.lions_flag_FormerOnlineMerchBuyer			,'')
		--OR ISNULL(b.lions_flag_CurrentCubClubMember				,'') != ISNULL(c.lions_flag_CurrentCubClubMember				,'')
		--OR ISNULL(b.lions_flag_FormerCubClubMember				,'') != ISNULL(c.lions_flag_FormerCubClubMember				,'')
		--OR ISNULL(b.lions_flag_CurrentYouthFootballParticipant	,'') != ISNULL(c.lions_flag_CurrentYouthFootballParticipant	,'')
		--OR ISNULL(b.lions_flag_FormerYouthFootballParticipant	,'') != ISNULL(c.lions_flag_FormerYouthFootballParticipant	,'')
		--OR ISNULL(b.lions_flag_LionsAlumni						,'') != ISNULL(c.lions_flag_LionsAlumni						,'')
		OR ISNULL(b.address1_county								,'') != ISNULL(c.address1_county, '')


)




GO
