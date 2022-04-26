USE PLANINTDB;


IF OBJECT_ID('dbo.danyDashArr', 'U') IS NOT NULL
  DROP TABLE dbo.danyDashArr 

CREATE TABLE dbo.danyDashArr (
defendantId INT NOT NULL,
firstEvtId INT NOT NULL,
firstEvtDate DATE NULL,
firstEvtYear INT NULL,
dpReason VARCHAR(100) NULL,
screenOutcome VARCHAR(100) NULL,
arrestType VARCHAR(100) NULL,
preArcDivOffer INT NULL DEFAULT 0,
preArcDiv INT NULL DEFAULT 0,
arrestTopChg VARCHAR(200) NULL,
arrestTopChgClean VARCHAR(200) NULL,
arrestTopShort VARCHAR(100) NULL,
arrestTopCat VARCHAR(200) NULL,
arrestTopMg VARCHAR(200) NULL,
scrTopCmid INT NULL,
scrTopCat VARCHAR(80) NULL,
scrTopClass VARCHAR(20) NULL,
scrTopChg VARCHAR(50) NULL,
scrTopTxt VARCHAR(200) NULL,
scrTopMg VARCHAR(200) NULL,
chargeChangeDetail VARCHAR(150) NULL,
isEcab INT DEFAULT 0,
isDp INT DEFAULT 0,
isDat INT NULL DEFAULT 0,
isMj INT NULL DEFAULT 0,
isTos INT NULL DEFAULT 0,
hasMjUnderlying INT NULL DEFAULT 0,
hasTosUnderlying INT NULL DEFAULT 0,
)

INSERT INTO dbo.danyDashArr (
	defendantId,
	firstEvtId,
	firstEvtDate,
	firstEvtYear,
	screenOutcome,
	arrestType,	
	arrestTopChg,
	arrestTopChgClean,
	arrestTopShort,
	arrestTopCat,
	scrTopCmid,
	scrTopCat,
	scrTopClass,
	scrTopChg,
	scrTopTxt,
	chargeChangeDetail,
	isEcab,
	isDp,
	isDat
	)
SELECT DISTINCT
	fe.defendantId,
	fe.firstEvtId,
	fe.firstEvtDate,
	firstEvtYear = YEAR(fe.firstEvtDate),
	screenOutcome = CASE WHEN fe.isDp = 1 THEN 'Decline to Prosecute'
						 WHEN fe.isDp = 0   
							THEN 
								CASE WHEN fe.firstEvtOutcome = 'Deferred Prosecution' THEN fe.firstEvtOutcome
									 WHEN ISNULL(fe.firstEvtOutcome, 'ok') <> 'Deferred Prosecution' THEN 'Prosecute' END
					ELSE 'Unknown' END,
	arrestType = CASE WHEN fe.IsDat= 1 THEN 'DAT' ELSE 'Live Arrest' END,
	fe.arrestTopChg,
	arrestTopChgClean = REPLACE(fe.arrestTopChg, ' ', ''),
	arrestTopShort = CASE WHEN fe.arrestTopChg LIKE 'PL%' THEN LEFT(fe.arrestTopChg, 6)
						  WHEN fe.arrestTopChg LIKE 'LOC%' THEN 'LO'
						  ELSE LEFT(fe.arrestTopChg, PATINDEX('%[^A-z]%', fe.arrestTopChg)-1) END,
	fe.arrestTopCat,
	fe.firstTopCmid,
	fe.firstTopCat,
	fe.firstTopClass,
	fe.firstTopChg,
	fe.firstTopTxt,
    chargeChangeDetail  =  CASE WHEN fe.chargeChangeDetail = 'Charge Change Unknown' THEN 'Change was Unknown'
							    WHEN fe.chargeChangeDetail = 'Downgraded to Misdemeanor' THEN 'Downgraded to a Misdemeanor'
							    WHEN fe.chargeChangeDetail = 'Downgraded to Violation/Infraction' THEN 'Downgraded to a Violation/Infraction'
							    WHEN fe.chargeChangeDetail = 'Upgraded to Felony' THEN 'Upgraded to a Felony'
							    WHEN fe.chargeChangeDetail = 'Upgraded to Misdemeanor' THEN 'Upgraded to a Misdemeanor'
							ELSE fe.chargeChangeDetail END,
	fe.isEcab,
	fe.isDp,
	fe.isDat
FROM dms.dbo.planning_fe2 fe 
JOIN dms.dbo.planning_defSummary2 def on def.screenId = fe.PlanningFirstEvtID -- exclude Extradition/weird Screened cases
WHERE 
/* remove cases that did not come through ECAB at any point */
(CASE WHEN fe.caseType IN ('Emerged from Existing Case',
						   'N/A Presentation') 
	OR fe.origDefId IS NOT NULL -- backstop for Emerged from Existing Case
	OR fe.isConfidential = 1 -- backstop for N/A Presentation
	THEN 0 ELSE 1 END ) = 1
AND (fe.firstEvtType = 'ECAB'
	OR fe.ecabEventId IS NOT NULL -- backstop for ECAB
	)
AND YEAR(fe.firstEvtDate) >= 2013


/* screen major group */
UPDATE dbo.danyDashArr
SET scrTopMg = c.MajorGroup
FROM dbo.danyDashArr arr
JOIN dms.dbo.planning_charges2 c On c.chargeModificationId = arr.scrTopCmid

/* arrest major group */
-- non-PL major groups
UPDATE dbo.danyDashArr
SET arrestTopMg =  arrestTopShort
FROM planintdb.dbo.danyDashArr 
WHERE arrestTopShort NOT LIKE 'PL%'

-- code from planning_charges2
UPDATE dbo.danyDashArr
SET arrestTopMg = CASE WHEN arrestTopShort = 'VTL'
						THEN 'VTL'
					   WHEN arrestTopShort = 'PL 160'
						THEN 'Robbery'
					   WHEN arrestTopShort = 'PL 265'
						THEN 'Weapons'
					   WHEN arrestTopShort = 'PL 155'
						THEN 
							CASE WHEN arrestTopChgClean like 'PL15525%' 
									THEN 'Petit Larceny'
								ELSE 'Grand Larceny' END
					   WHEN arrestTopShort = 'PL 265'
						THEN 'Weapons'
					   WHEN arrestTopShort = 'PL 220'
						THEN 'Drugs'
					   WHEN arrestTopShort = 'PL 221'
					    THEN 'Marijuana'
					   WHEN arrestTopShort = 'PL 120'
						THEN 'Assault'
					   WHEN arrestTopShort = 'PL 140'
						 THEN CASE WHEN arrestTopChgClean LIKE 'PL14005%' OR arrestTopChgClean like 'PL14010%' 
									OR arrestTopChgClean like 'PL14015%' OR arrestTopChgClean like 'PL14017%'
									THEN 'Trespass'	 
									ELSE 'Burglary' END
					   WHEN arrestTopShort = 'PL 130'
					    THEN 'Sex Offense'
					   WHEN arrestTopShort = 'PL 135'
					    THEN 'Kidnapping/Coercion'
					   WHEN arrestTopShort = 'PL 125'
					    THEN 'Homicide'
					   WHEN arrestTopShort = 'PL 190'
					    THEN 'Other Fraud'
					   WHEN arrestTopShort = 'PL 145'
					    THEN 'Mischief'
					  WHEN arrestTopShort = 'PL 150'
					    THEN 'Arson' 
					  WHEN arrestTopShort in ('PL 170', 'PL 175')
					    THEN 'Forgery'
					  WHEN arrestTopShort = 'PL 105'
					   THEN 'Conspiracy'
					  WHEN arrestTopShort = 'PL 200'
					   THEN 'Bribery'
					  WHEN arrestTopShort = 'PL 205'
					   THEN CASE WHEN arrestTopChgClean like 'PL20530%' 
								  THEN 'Resisting Arrest'
							  ELSE 'Escape/Custody' END
					  WHEN arrestTopShort = 'PL 215'
					   THEN 'Judicial Offense'
					  WHEN arrestTopShort = 'PL 225'
					   THEN 'Gambling'
					  WHEN arrestTopShort = 'PL 230'
					   THEN 'Prostitution/Patronizing'
					  WHEN arrestTopShort = 'PL 235'
					   THEN 'Obscenity'
					  WHEN arrestTopShort = 'PL 165'
						THEN CASE WHEN arrestTopChgClean like 'PL1654%'OR arrestTopChgClean like 'PL1655%' OR arrestTopChgClean like 'PL1656%'
									THEN 'Stolen Property'
								  ELSE 'Theft' END
					  WHEN arrestTopShort = 'PL 240' 
						THEN CASE WHEN arrestTopChgClean like 'PL24020%'
							THEN 'Disorderly Conduct'
						 ELSE 'Public Order' END
					  WHEN arrestTopShort = 'AC'
					    THEN 'Admin. Code'
					ELSE 'Other ' + arrestTopCat END -- concat with NULL is NULL
FROM planintdb.dbo.danyDashArr

/* 
isMJ is defined as any case where the top charge is MJ poss:
- Unlawful Possession Of Marijuana
- Criminal Possession of Marijuana in the Fifth Degree - DNA Eligible Only With Prior Conviction
- Attempted Criminal Possession of marijuana in the Fifth Degree
- Attempted Unlawful Possession of Marijuana

and underlying charge is also a MJ poss charge (same as top charge options):
- Unlawful Possession Of Marijuana
- Criminal Possession of Marijuana in the Fifth Degree - DNA Eligible Only With Prior Conviction
- Attempted Criminal Possession of marijuana in the Fifth Degree
- Attempted Unlawful Possession of Marijuana

EXCLUSIONS:
These are not coded into the flag to be consistent with isToS where exclusions are also not coded into the flag

*/

UPDATE dbo.danyDashArr
SET isMj = 1
FROM dbo.danyDashArr arr
WHERE 
	arr.scrTopCmid in (817,7444, 815, 7619)
AND (CASE WHEN EXISTS (SELECT 1 
					   FROM dms.dbo.eventlinkcharge elc
					   WHERE
							elc.eventid = arr.firstEvtID
					    AND elc.chargemodificationid NOT IN (817, 7444, 815, 7619)
		 ) THEN 0 ELSE 1 END) = 1

/* see if underlying charge is MJ pss and top charge is not MJ pss */
UPDATE dbo.danyDashArr
SET hasMjUnderlying = 1
FROM dbo.danyDashArr arr
WHERE 
	EXISTS (SELECT arr.firstEvtId
			 FROM dms.dbo.eventLinkCharge elc
			 WHERE 
				 elc.eventID = arr.firstEvtID
			 AND elc.chargePriority <> 1
			 AND elc.chargeModificationID IN (817,7444, 815, 7619))
AND arr.scrTopCmid NOT IN (817,7444, 815, 7619)

/* 
   isToS is defined as any case where the top charge is ToS 
   and underlying charge is trespass, where the arraignment headline is 
   not taxi/cab/uber/lyft 

   EXCLUSIONS: not coded into isToS flag
 */
UPDATE dbo.danyDashArr
SET isTos = 1
FROM dbo.danyDashArr arr
LEFT JOIN dms.dbo.eventlinkcharge elc ON elc.eventid = arr.firstEvtID
									 AND elc.ChargePriority = 2
WHERE 
	arr.scrTopCmid IN (20880, 20881, 372, 9835, 25678) --tos
AND (elc.chargeModificationId IN (22548, 23484, 25677, 100197, 7900, 7216, 7354, 223)  --trespass
	OR
	 elc.ChargeModificationID IS NULL)
						
/* mark is ToS = 0 where arraignment headline is taxi - not the correct type of ToS */
;WITH tmp AS (
SELECT
	arr.defendantId,
	[Text] = CASE WHEN arr.isDp = 1 
					  THEN  REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(sd.dpLanguage, ''), CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ''), CHAR(11), '') 
				  ELSE 
					   REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(sd.arraignmentHeadline, ''), CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ''), CHAR(11), '')  
				  END
FROM dbo.danyDashArr arr
JOIN dms.dbo.screeningDetail sd on sd.DefendantID = arr.DefendantId
)
UPDATE dbo.danyDashArr
SET isTos = 0
FROM dbo.danyDashArr arr 
JOIN tmp on tmp.defendantId = arr.defendantId
WHERE 
	(CASE WHEN [Text] LIKE '%taxi%'
			OR [Text] LIKE '%lyft%'
			OR [Text] LIKE '%uber%'
			OR [Text] LIKE '% cab %'
			OR [Text] LIKE '% cab'
			OR [Text] LIKE 'cab %'
	THEN 1 ELSE 0 END) = 1
	
			
/* see if underlying charge is TOS */
UPDATE dbo.danyDashArr
SET hasTosUnderlying = 1
FROM dbo.danyDashArr arr
WHERE 
	arr.scrTopCmid NOT IN (20880, 20881, 372, 9835, 25678) -- top charge is not ToS
	 -- trespass underlying charge exists or null
AND EXISTS (SELECT 1
			FROM dbo.danyDashArr arr2
				-- note this is a left join to allow for null check
			LEFT JOIN dms.dbo.eventlinkcharge elc ON elc.eventid = arr2.firstevtid
													AND elc.chargepriority > 1
			WHERE 
				elc.chargemodificationid IN (22548, 23484, 25677, 100197, 7900, 7216, 7354, 223) -- trespass
				OR elc.ChargeModificationID IS NULL
			AND arr2.defendantid = arr.defendantid)
-- ToS underlying charge
AND EXISTS (SELECT 1
			FROM dbo.danyDashArr arr2
			JOIN dms.dbo.eventLinkCharge elc ON elc.eventId = arr2.firstevtId
											AND elc.chargepriority > 1
			WHERE 
				elc.chargemodificationId IN (20880, 20881, 372, 9835, 25678)
			AND arr2.defendantId = arr.defendantId) 
					
/* remove cases where ToS is car-related - not the correct type of ToS */
;WITH tmp AS (
SELECT
	arr.defendantid,
	[Text] = CASE WHEN arr.isDp = 1 
					  THEN REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(sd.dpLanguage, ''), CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ''), CHAR(11), '') 
				  ELSE 
					  REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(sd.arraignmentHeadline, ''), CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ''), CHAR(11), '')  
				  END
FROM dbo.danyDashArr arr
JOIN dms.dbo.screeningDetail sd on sd.defendantId = arr.defendantId
)
UPDATE dbo.danyDashArr
SET HasTosUnderlying = 0
FROM dbo.danyDashArr arr 
JOIN tmp on tmp.defendantid = arr.defendantid
WHERE 
	[Text] LIKE '%taxi%'
 OR [Text] LIKE '%lyft%'
 OR [Text] LIKE '%uber%'
 OR [Text] LIKE '% cab %'
 OR [Text] LIKE '% cab'
 OR [Text] LIKE 'cab %'

/* check hasunderlyingToS flag works by checking dp language/arraignment headline 
	SELECT 	
	[Text] = case when arr.isdp = 1 
                  then replace(replace(REPLACE(REPLACE(isnull(sd.DPLanguage, ''), CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ''), CHAR(11), '') 
              else 
			      replace(replace(REPLACE(REPLACE(isnull(sd.arraignmentheadline, ''), CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ''), CHAR(11), '')  
		      end,
	* 
	FROM dbo.danyDashArr 	arr		      
		left join ScreeningDetail sd on sd.DefendantID = arr.DefendantId
	WHERE HasTosUnderlying = 1 
*/


UPDATE dbo.danyDashArr
SET dpReason = firstEvtOutcomeReason
FROM dbo.danyDashArr arr
JOIN dms.dbo.planning_fe2 fe on fe.defendantID = arr.defendantID
WHERE arr.screenOutcome = 'Decline to Prosecute'


UPDATE dbo.danyDashArr
SET preArcDivOffer = 1
FROM dbo.danyDashArr arr
JOIN (SELECT cf.defendantId
	  FROM dms.dbo.caseflagConfirmed cf
	  JOIN dms.dbo.caseFlagTypeLU flag ON flag.caseFlagTypeId = cf.caseFlagTypeId
	  WHERE flag.caseFlagType IN ('Project Reset', 'Project Green Light', 'Manhattan Hope')
	  ) div ON div.defendantID = arr.defendantID

	  
UPDATE dbo.danyDashArr
SET dpReason = CASE WHEN dpReason LIKE '%Unlicensed General Vending%'
						OR
						 dpReason LIKE '%MJ Possession%'
						OR
						 dpReason LIKE '%Unlicensed Food Vending%'
						OR 
						 dpReason LIKE '%theft of service%'
						OR 
						 dpReason LIKE '%farebeat%'
						OR
						 dpReason LIKE '%gravity knif%' --TODO: this was eventoutcomereason in discretion -- double check with Michelle that discretion had a typo 
						OR 
						dpReason like '%non-penal law%'
				THEN 'Office Declination Policy'
					WHEN dpReason LIKE '%Diversion%'
						OR
						 dpReason LIKE '%Green Light%'
				THEN 'Pre-Arraignment Diversion' 
				/* switch: instead of Dping cases for further investigation we are now deferring those cases */
					WHEN dpReason LIKE '%further invest%'THEN 'Further Investigation Needed'
					WHEN dpReason LIKE '%lacks%merit%' THEN 'Lacks Prosecutorial Merit'
					WHEN dpReason LIKE '%DAT%' THEN 'DAT Processing Issue'
					WHEN dpReason LIKE '%insuff%corrob%' THEN 'Insufficient Corroboration'
					WHEN dpReason LIKE '%neces%element%' THEN 'Cannot Prove Element of Crime' --- revisit the language
					WHEN dpReason LIKE '%lacks%jurisd%' THEN 'Lacks Jurisdiction'
					WHEN DPreason LIKE '%officer%unavail%' THEN 'Office Unavailable'
					WHEN sd.dpLanguage LIKE '%covid%' THEN 'COVID-19'
				ELSE 'Other' END
FROM dbo.danyDashArr arr
LEFT JOIN dms.dbo.screeningDetail sd ON sd.defendantId = arr.defendantId
WHERE arr.isDp = 1

UPDATE dbo.danyDashArr
SET dpReason = 'Office Declination Policy'
FROM dbo.danyDashArr arr
JOIN dms.dbo.planning_fe2 f On f.defendantId = arr.defendantId
LEFT JOIN dms.dbo.screeningDetail sd ON sd.defendantId = arr.defendantId
WHERE 
	arr.isDP = 1
AND (dpLanguage LIKE '%assembly%' 
 OR dpLanguage LIKE '%obstruct%gov%' 
 OR dpLanguage LIKE '%resist%'
 OR dpLanguage LIKE '%protest%'
 OR dpLanguage LIKE '%june%2020%')
AND arr.firstEvtDate >= '2020-04-01'


UPDATE dbo.danyDashArr
SET preArcDiv = 1
FROM dbo.danyDashArr arr
JOIN dms.dbo.activity a ON a.defendantId = arr.defendantId 
JOIN dms.dbo.activityOutcome ao ON ao.activityId = a.activityId
JOIN dms.dbo.activityOutcomeTypeLU typ ON typ.activityOutcomeTypeId = ao.activityOutcomeTypeId
JOIN dms.dbo.caseFlagTypeLu flag On flag.caseFlagTypeId = typ.caseFlagTypeId
WHERE 
	flag.caseFlagType in ('Project Reset', 'Manhattan Hope') 
AND typ.activityOutcome IN ('Completed', 
							'Program Complete')

UPDATE dbo.danyDashArr
SET preArcDiv = 1
FROM dbo.danyDashArr arr
JOIN planning_fe2 f On f.defendantId = arr.defendantId
WHERE 
	PreArcDiv = 0
AND DPReason = 'Pre-Arraignment Diversion' 

/* 
Removing NULLs 
All columns filtered in dashboard cannot have NULLs 
*/
UPDATE dbo.danyDashArr
SET arrestTopCat = CASE 
		WHEN arrestTopCat IN (
				'Felony',
				'Misdemeanor',
				'Violation/Infraction'
				)
			THEN arrestTopCat
			ELSE 'Unknown'
		END,
	arrestTopMg = ISNULL(arrestTopMg, 'Unknown'), -- there is no 'other unknown' major group cat with arresttopmg s
	arrestTopShort = ISNULL(arrestTopShort, 'Unknown'),
	scrTopCat = CASE 
		WHEN scrTopCat IN (
				'Felony',
				'Misdemeanor',
				'Violation/Infraction'
				)
			THEN scrTopCat
		ELSE 'Unknown'
		END,
	scrTopMg = CASE WHEN scrTopMg = 'Other Unknown' OR scrTopMg IS NULL THEN 'Unknown' ELSE scrTopMg END
FROM dbo.danyDashArr

SELECT
*
FROM dbo.danyDashArr 
