USE PLANINTDB;

/* drop table */
IF OBJECT_ID('dbo.danyDashCohort', 'U') IS NOT NULL
DROP TABLE dbo.danyDashCohort

/* insert base info from first event */
CREATE TABLE dbo.danyDashCohort (
	cohort INT NOT NULL,
	planningDefSummaryId INT NOT NULL,
	defendantId INT UNIQUE NULL,
	subsequentDefId INT NULL,
	caseStatus VARCHAR(150) NULL,
	caseStatusDetail VARCHAR(200) NULL,
	activityStatus VARCHAR(150) NULL,
	nextScheduledCourtAppearance DATE NULL,
	nextOnFor VARCHAR(200) NULL,
	nextOnPart VARCHAR(200) NULL,
	arrestDate DATE NULL,
	screenId INT NULL,
	screenDate DATE NULL,
	screenOutcome VARCHAR(200) NULL,
	screenChargeChange VARCHAR(200) NULL,
	ccArraignId INT NULL,
	ccArraignDate DATE NULL,
	bailRequested INT NULL DEFAULT 0,
	bailSet INT NULL DEFAULT 0,
	ccArraignOutcome VARCHAR(150) NULL,
	ccArraignRelease VARCHAR(150) NULL,
	indictId INT NULL,
	indDate DATE NULL,
	indType VARCHAR(150) NULL DEFAULT 'Not Indicted',
	scArraignEvtId INT NULL,
	scArraignDate DATE NULL,
	defTrialCount INT NULL,
	dispoId INT NULL,
	dispoDate DATE NULL,
	disposition VARCHAR(200) NULL,
	dispoDetail VARCHAR(200) NULL, 
	sentenceId INT NULL,
	sentenceDate DATE NULL,
	sentence VARCHAR(100) NULL DEFAULT 'Not Sentenced',
	instantCmid INT NULL, --pre dispo
	instTopCat VARCHAR(20) NULL,
	instTopCat2 VARCHAR(100) NULL,
	--instTopClass VARCHAR(20) NULL,
	--instTopTxt VARCHAR(500) NULL,
	instTopMg VARCHAR(200) NULL,
	instTopVfo INT NULL DEFAULT 0,
	instantCaseType VARCHAR(150) NULL,
	dispoCmid INT NULL,
	dispoTopCat VARCHAR(150) NULL,
	dispoCaseType VARCHAR(150) NULL,
    --timeToDispo VARCHAR(150) NULL,
	isIndicted INT NULL DEFAULT 0,
	isTried INT NULL DEFAULT 0,
	--defTrialCount INT NULL DEFAULT 0,
	is730 INT NULL DEFAULT 0,
	isOutOnWarrant INT NULL DEFAULT 0,
	benchWarranted INT NULL DEFAULT 0,
	detainedPreTr INT NULL DEFAULT 0,
	--daysDetainedPreTr INT NULL DEFAULT 0,
	--inCustody INT NULL DEFAULT 0,
	caseReopened INT NULL DEFAULT 0,
	reopenId INT NULL,
	reopenDate DATE NULL,
	reopenOutcome VARCHAR(200) NULL
)

/* insert all cases since 2013 */
INSERT INTO dbo.danyDashCohort (
	cohort,
	defendantId,
	planningDefSummaryId,
	caseStatus,
	caseStatusDetail,
	activityStatus,
	nextScheduledCourtAppearance,
	nextOnFor,
	nextOnPart,
	arrestDate,
	screenId,
	screenDate,
	screenOutcome,
	screenChargeChange,
	ccArraignId,
	ccArraignDate,
	ccArraignOutcome,
	indictId,
	indDate,
	indType,
	scArraignEvtId,
	scArraignDate,
	defTrialCount,
	dispoId,
	dispoDate,
	disposition,
	sentenceId,
	sentenceDate,
	sentence,
	instantCmid,
	instTopCat,
	instantCaseType,
	dispoCmid,
	dispoTopCat,
	dispoCaseType,
	isIndicted,
	isTried,
	is730,
	isOutOnWarrant,
	benchWarranted,
	detainedPreTr,
	caseReopened,
	reopenId,
	reopenDate,
	reopenOutcome
)
SELECT 
	cohort = YEAR(def.screenDate),
	def.defendantId,
	def.planningDefSummaryId,
	def.caseStatus,
	def.caseStatusDetail,
	def.activityStatus,
	def.nextScheduledCourtAppearance,
	def.nextOnFor,
	def.nextOnPart,
	def.arrestDate,
	def.screenId,
	def.screenDate,
	def.screenOutcome,
	def.screenChargeChange,
	def.ccArraignId,
	def.ccArraignDate,
	def.ccArraignOutcome,
	def.indictId,
	def.indDate,
	def.indType,
	def.scArraignEvtId,
	def.scArraignDate,
	def.defTrialCount,
	def.dispoId,
	def.dispoDate,
	/* deferred prosecutions marked as disposition (but should not be) so we're nulling them out here */
	CASE WHEN def.caseStatus = 'Deferred Prosecution' THEN NULL ELSE def.disposition END,
	def.sentenceId,
	def.sentenceDate,
	def.sentence,
	def.instantCmid,
	def.instTopCat,
	def.instantCaseType,
	def.dispoCmid,
	def.dispoTopCat,
	def.dispoCaseType,
	CASE WHEN def.IndictId IS NOT NULL THEN 1 ELSE 0 END AS isIndicted,
	def.isTried,
	def.is730,
	def.isOutOnWarrant,
	def.benchWarranted,
	def.detainedPreTr,
	def.caseReopened,
	def.reopenId,
	def.reopenDate,
	def.reopenOutcome
FROM dms.dbo.planning_defSummary2  def
JOIN dms.dbo.planning_fe2 pf on pf.PlanningFirstEvtID = def.screenId -- hard join (fe2 is the base for defSummary2)
WHERE 
	(CASE WHEN pf.caseType IN ('Extradition',
							'N/A Presentation')
							 OR pf.isConfidential = 1 -- backstop for N/A Presentation
							 THEN 0 ELSE 1 END ) = 1
AND YEAR(def.screenDate) BETWEEN 2013 AND YEAR( getDate() )-1

/* add arraignments data missing from defSummary table */
UPDATE dbo.danyDashCohort
SET 
	ccArraignRelease = pa.releaseStatus,
	bailRequested = ISNULL(pa.bailReq, 0),
	bailSet = CASE WHEN dollarBail = 1 THEN 0 ELSE ISNULL(pa.bailSet,0) END
FROM dbo.danyDashCohort c
	JOIN dms.dbo.planning_arraignments2 pa ON pa.planningArraignmentsId = c.ccArraignId

/* add dispo data missing from defSummary table */
UPDATE dbo.danyDashCohort
SET 
	dispoDetail = CASE WHEN dispoCondensed = 'ACD/M' AND acdOutcome IS NOT NULL 
						THEN dispoCondensed + ' - ' + acdOutcome 
					ELSE dispoCondensed END
FROM dbo.danyDashCohort c
	JOIN dms.dbo.planning_dispositions2 dsp ON dsp.planningDispositionsID = c.DispoId
/* deferred prosecutions marked as disposition (but should not be) so we're excluding them out here */
WHERE (CASE WHEN c.CaseStatus = 'Deferred Prosecution' THEN 0 ELSE 1 END) = 1

/* update conviction charge for acd pleas */
UPDATE dbo.DanyDashCohort
SET dispoCmid = conv.ConvTopCmid,
	dispoTopCat = conv.ConvTopCat
FROM dbo.danyDashCohort c
JOIN dms.dbo.planning_convictions2 conv ON conv.DefendantId = c.DefendantId
WHERE DispoDetail IN ('ACD/M - Conviction', 'ACD/M - Plea')
	AND convOrder = 1


/* add subsequent defendantid for cases that were superceded/consolidated/mdi */
UPDATE dbo.danyDashCohort
SET subsequentDefId = f.defendantId 
FROM dbo.danyDashCohort c
JOIN dms.dbo.planning_fe2 f ON f.origDefId = c.defendantId
WHERE 
	(CASE WHEN f.caseType IN ('Extradition',
							  'N/A Presentation') OR f.isConfidential = 1 THEN 0 ELSE 1 END ) = 1

/* compile details from superceded case and insert into superceding case to create a complete trajectory of the case*/
;WITH cond AS (
SELECT
	c.cohort, 
	nxt.defendantID,
	c.screenId,
	c.screenDate,
	c.screenOutcome,
	c.screenChargeChange,
	c.ccArraignID,
	c.ccArraignDate,
	c.bailRequested,
	c.bailSet,
	c.ccArraignOutcome,
	c.ccArraignRelease
FROM dbo.danyDashCohort c
JOIN dbo.danyDashCohort nxt ON nxt.defendantId = c.subsequentDefId
)
UPDATE dbo.danyDashCohort
SET cohort = cond.cohort,
	screenId = cond.screenId,
	screenDate = cond.screenDate,
	screenOutcome = cond.screenOutcome,
	screenChargeChange = cond.screenChargeChange,
	ccArraignId = cond.ccArraignId,
	ccArraignDate = cond.ccArraignDate,
	bailRequested = cond.bailRequested,
	bailSet = cond.bailset,
	ccArraignOutcome = cond.ccArraignOutcome,
	ccArraignRelease = cond.ccArraignRelease
FROM dbo.danyDashCohort c
JOIN cond ON cond.defendantId = c.defendantId

/* remove the original superceded case */
DELETE FROM dbo.danyDashCohort WHERE subsequentDefId IS NOT NULL

;WITH cond AS (
SELECT 
	x.cohort, 
	c2.defendantID,
	x.screenId,
	x.screenDate,
	x.screenOutcome,
	x.screenChargeChange,
	x.ccArraignID,
	x.ccArraignDate,
	x.bailRequested,
	x.bailSet,
	x.ccArraignOutcome,
	x.ccArraignRelease
FROM dbo.danyDashCohort c2
JOIN dms.dbo.planning_fe2 f2 On f2.defendantId = c2.defendantId
JOIN (SELECT c.*, f.nysid, f.caseType, f.currentADA, f.latestIndictment, f.docket, f.arrestId
	  FROM dbo.danyDashCohort c
	  JOIN dms.dbo.planning_Fe2 f On f.defendantId = c.defendantId
	  WHERE c.disposition in ('Multiple Docket Indictment', 'Superceded')
	  ) x ON x.nysid = f2.nysid
WHERE 
	(f2.firstEvtType LIKE '%office orig%'
	OR ( f2.isEcab = 0 AND f2.ecabEventId IS NULL)
	) 
AND c2.screenDate > x.indDate
AND (x.currentADA = f2.currentADA
	OR 
	x.latestIndictment = f2.latestIndictment
	OR 
	x.docket = f2.docket
	OR 
	x.arrestid = f2.arrestid
	)
AND ISNULL(c2.disposition,'k') NOT IN ('Multiple Docket Indictment', 'Superceded')
)
UPDATE dbo.danyDashCohort
SET cohort = cond.cohort,
	screenId = cond.screenId,
	screenDate = cond.screenDate,
	screenOutcome = cond.screenOutcome,
	screenChargeChange = cond.screenChargeChange,
	ccArraignId = cond.ccArraignId,
	ccArraignDate = cond.ccArraignDate,
	bailRequested = cond.bailRequested,
	bailSet = cond.bailset,
	ccArraignOutcome = cond.ccArraignOutcome,
	ccArraignRelease = cond.ccArraignRelease
FROM dbo.danyDashCohort c
JOIN cond ON cond.defendantId = c.defendantId

DELETE FROM dbo.danyDashCohort 
WHERE disposition IN ('Multiple Docket Indictment', 'Superceded')

UPDATE dbo.danyDashCohort
SET instTopMg = pc.MajorGroup,
	instTopVfo = pc.isVfo
FROM dbo.danyDashCohort c
JOIN dms.dbo.planning_charges2 pc on pc.chargemodificationid = c.instantcmid

UPDATE dbo.danyDashCohort
SET instTopMg = CASE WHEN instTopMg = 'Other Unknown' OR instTopMg IS NULL THEN 'Unknown' ELSE instTopMg END
FROM dbo.danyDashCohort

-- create second charge category column for filtering, which combines vfo flag and instant charge category
UPDATE dbo.danyDashCohort
SET instTopCat2 = CASE 
		WHEN instTopCat = 'Felony'
			AND instTopVfo = 1
			THEN 'Violent Felony'
		WHEN instTopCat = 'Felony'
			AND instTopVfo = 0
			THEN 'Non-Violent Felony'
		ELSE instTopCat
		END
FROM dbo.danyDashCohort

SELECT * 
FROM dbo.danyDashCohort
