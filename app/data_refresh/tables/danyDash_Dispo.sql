USE PLANINTDB;

IF OBJECT_ID('dbo.danyDashDispo', 'U') IS NOT NULL
DROP TABLE dbo.danyDashDispo

CREATE TABLE dbo.danyDashDispo (
	planningDispositionsId INT NOT NULL,
	defendantId INT NOT NULL,
	nextScheduledCourtAppearance DATE NULL,
	dispoEventId INT NULL,
	dispoDate DATE NULL,
	eventType VARCHAR(100) NULL,
	disposition VARCHAR(500) NULL,
	dispoReason VARCHAR(200) NULL,
	acdOutcome VARCHAR(200) NULL,
	dispoCondensed VARCHAR(200) NULL,
	firstFinalDispo INT NULL,
	mostRecentDispo INT NULL,
	dispoTopCmid INT NULL,
	dispoTopCat VARCHAR(100) NULL,
	dispoTopClass VARCHAR(100) NULL,
	dispoTopChg VARCHAR(100) NULL,
	dispoTopTxt VARCHAR(250) NULL,
	dispoTopMg VARCHAR(50) NULL,
	eventOrder INT NULL,
	instTopCmid INT NULL,
	instTopCat VARCHAR(200) NULL,
	instTopCat2 VARCHAR(200) NULL,
	instTopClass VARCHAR(20) NULL,
	instTopChg VARCHAR(200) NULL,
	instTopMg VARCHAR(200) NULL,
	instTopTxt VARCHAR(500) NULL,
	instTopVfo INT NULL DEFAULT 0,
	chargeChange VARCHAR(200) NULL,
	chargeChangeDetail VARCHAR(200) NULL,
	courtType VARCHAR(50) NULL,
	dispoYear INT NULL,
	dispoType VARCHAR(50) NULL,
	dispoTypeDetail VARCHAR(100) NULL,
	rePlea INT NULL DEFAULT 0,
	isPleaConvict INT NULL DEFAULT 0,
	isAcdm INT NULL DEFAULT 0,
	isAcq INT NULL DEFAULT 0,
	isDsm INT NULL DEFAULT 0,
	isOther INT NULL DEFAULT 0,
	isArcDispo INT NULL DEFAULT 0,
	isIndicted INT NULL DEFAULT 0,
	isNa INT NULL DEFAULT 0,
	repleaEvtId INT NULL,
	repleaDate DATE NULL
)

/*final case disposition (excluding cases after return from appeals/overturned or vacated dispo...need to decide whether this is the right decision...
							hopefully we'll have a conviction integrity section) */
;WITH tmp AS (
SELECT
	defendantId,
	MAX(dispoOrder) AS lstFrstDispo
FROM dms.dbo.planning_dispositions2
	WHERE 
		YEAR(dispoDate) >= 2013
		AND dispoOrder >= 1 
		AND postRestoreOrder = 0
GROUP BY defendantId
)
INSERT INTO dbo.danyDashDispo (
	planningDispositionsId,
	defendantId,
	dispoEventId,
	dispoDate,
	dispoYear,
	eventType,
	disposition,
	dispoReason,
	acdOutcome,
	dispoCondensed,
	firstFinalDispo,
	mostRecentDispo,
	dispoTopCmid,
	dispoTopCat,
	dispoTopClass,
	dispoTopChg,
	eventOrder,
	rePlea,
	isArcDispo,
	isIndicted,
	isNa
)
SELECT
	pd.planningDispositionsId,
	f.defendantid,
	pd.dispoEventId,
	pd.dispoDate,
	YEAR(pd.dispoDate),
	pd.eventType,
	pd.disposition,
	pd.dispoReason,
	pd.acdOutcome,
	pd.dispoCondensed,
	pd.firstFinalDispo,
	pd.mostRecentDispo,
	pd.dispoTopCmid,
	pd.dispoTopCat,
	pd.dispoTopClass,
	pd.dispoTopCharge,
	pd.eventOrder,
	rePlea		= CASE WHEN EXISTS (
								   SELECT 1 
								   FROM dms.dbo.planning_dispositions2 d 
								   WHERE 
										d.defendantID = pd.defendantId 
									AND d.eventOrder = pd.eventOrder - 1
									AND d.interimDispoType = 'Re-Plea' 
									) 
						THEN 1 ELSE 0 END,
	isArcDispo	= CASE WHEN EXISTS (
									SELECT 1 
									FROM dms.dbo.planning_arraignments2 a 
									WHERE 
										a.defendantId = pd.defendantID 
									AND ISNULL(arcSurvive, 0) = 0) 
						THEN 1 ELSE 0 END,
	isIndicted	= CASE WHEN EXISTS (SELECT 1 
									FROM dms.dbo.planning_indictments2 i 
									WHERE 
										i.defendantID = pd.defendantID 
									AND i.eventDate <= pd.dispoDate
									AND i.indicted = 1 
									) 
						THEN 1 ELSE 0 END,
	f.isNA
FROM dms.dbo.planning_dispositions2 pd
JOIN dms.dbo.planning_fe2 f ON f.defendantId = pd.defendantId
JOIN tmp ON tmp.defendantId = pd.defendantId
			AND tmp.lstFrstDispo = pd.dispoOrder
WHERE 
	f.caseType <> 'Extradition' 
AND ISNULL(disposition, 'ok') NOT IN ('Multiple Docket Indictment', 
									 'Superceded', 
									  'Case Consolidated')


DROP INDEX IF EXISTS dd_dsp_def
ON dbo.danyDashDispo


CREATE CLUSTERED INDEX dd_dsp_def
ON dbo.danyDashDispo (defendantId)


UPDATE dbo.danyDashDispo
SET repleaEvtId = rep.dispoEventId,
	repleaDate = rep.dispoDate
FROM dbo.danyDashDispo d
JOIN dms.dbo.planning_dispositions2 rep ON rep.defendantId = d.defendantID
											AND rep.interimDispoType = 'Re-Plea'
											AND rep.eventOrder = d.eventOrder - 1

UPDATE dbo.danyDashDispo
SET instTopCmid = def.instantCmid,
	instTopCat = c.category,
	instTopClass = c.class,
	instTopChg = COALESCE(c.chargeClean, c.chargeCode),
	instTopMG = c.majorGroup,
	instTopTxt = c.chargeDescription,
	instTopVfo = c.isVFO
FROM dbo.danyDashDispo d
JOIN dms.dbo.planning_defSummary2 def on def.dispoId = d.planningDispositionsId
JOIN dms.dbo.planning_charges2 c On c.chargeModificationId = def.instantCmid

UPDATE dbo.danyDashDispo
SET isPleaConvict = 1
FROM dbo.danyDashDispo
WHERE dispoCondensed IN ('Plea', 'Convicted and Plea', 'Conviction')

UPDATE dbo.danyDashDispo
SET isACDM = 1
FROM dbo.danyDashDispo
WHERE dispoCondensed = 'ACD/M'

UPDATE dbo.danyDashDispo
SET isAcq = 1
FROM dbo.danyDashDispo
WHERE dispoCondensed = 'Acquittal'

UPDATE dbo.danyDashDispo
SET isDsm = 1
FROM dbo.danyDashDispo
WHERE dispoCondensed like '%dism%'

/* other includes: abated by death, transferred to other jurisdiction, and 730 --- we can choose to include, exclude or isolate these cases as we see fit */
UPdate dbo.danyDashDispo
Set isOther = 1
FROM dbo.danyDashDispo
WHERE 
	isPleaConvict + isAcq + isAcdm + isDsm = 0

UPDATE dbo.danyDashDispo
SET chargeChange = CASE WHEN cd.catClassOrder > ci.catClassOrder THEN 'Downgraded'
						WHEN ci.catClassOrder = 9 AND d.dispoTopCat = 'Violation/Infraction' THEN 'Downgraded'
						WHEN cd.catClassOrder = ci.catClassOrder THEN 'Equivalent'
						WHEN cd.catClassOrder < ci.catClassorder THEN 'Upgraded'
					ELSE 'chk' END
FROM dbo.danyDashDispo d
JOIN dms.dbo.planning_charges2 ci ON ci.chargeModificationId = d.instTopCmid
JOIN dms.dbo.planning_charges2 cd ON cd.chargeModificationId = d.dispoTopCmid


UPDATE dbo.danyDashDispo
SET chargeChangeDetail = CASE WHEN cd.category = 'Felony'
							THEN 
								CASE WHEN ci.score > cd.score THEN 'Downgraded Felony'
									 WHEN ci.score > cd.score THEN 'Upgraded Felony'
								ELSE 'Equivalent Felony' END
							  WHEN cd.catClassOrder > ci.catClassOrder THEN 'Downgraded to a ' + cd.category
					ELSE NULL END
FROM dbo.danyDashDispo d
JOIN dms.dbo.planning_charges2 ci ON ci.chargeModificationId = d.instTopCmid
JOIN dms.dbo.planning_charges2 cd ON cd.chargeModificationId = d.dispoTopCmid
WHERE ci.category = 'Felony'

UPDATE dbo.danyDashDispo
SET chargeChangeDetail = CASE WHEN dc.category = 'Misdemeanor'
							THEN 
								CASE WHEN ic.score > dc.score THEN 'Downgraded Misdemeanor'
									 WHEN ic.score < dc.score THEN 'Upgraded Misdemeanor'
								ELSE 'Equivalent Misdemeanor' END
							 WHEN dc.catClassOrder > ic.catClassOrder THEN 'Downgraded to a ' + dc.category
							 WHEN dc.catClassOrder < ic.catClassOrder THEN 'Upgraded to a Felony' 
						ELSE NULL END
							
FROM dbo.danyDashDispo d
JOIN dms.dbo.planning_charges2 ic ON ic.chargeModificationId = d.instTopCmid
JOIN dms.dbo.planning_charges2 dc ON dc.chargeModificationId = d.dispoTopCmid
WHERE ic.category = 'Misdemeanor'

UPDATE dbo.danyDashDispo
SET chargeChangeDetail = CASE WHEN dc.category = 'Violation/Infraction' THEN 'Equivalent Violation/Infraction'
							  WHEN dc.catClassOrder < ic.catClassOrder  THEN 'Upgraded to a ' + dc.category 
						  ELSE NULL END		
FROM dbo.danyDashDispo d
JOIN dms.dbo.planning_charges2 ic ON ic.chargeModificationId = d.instTopCmid
JOIN dms.dbo.planning_charges2 dc ON dc.chargeModificationId = d.dispoTopCmid
WHERE ic.category = 'Violation/Infraction'

UPDATE dbo.danyDashDispo
SET dispoTopTxt = c.chargeDescription,
	dispoTopMG = c.majorGroup,
	dispoTopCat = c.category,
	dispoTopClass = c.class
FROM dbo.danyDashDispo d
JOIN dms.dbo.planning_charges2 c On c.chargeModificationId = d.dispoTopCmid

UPDATE dbo.danyDashDispo
SET courtType = cp.courtType
FROM dbo.danyDashDispo d
JOIN dms.dbo.evt e ON e.eventId = d.dispoEventId
JOIN dms.dbo.courtPartLu cp ON cp.courtPartId = e.courtPartId

UPDATE dbo.danyDashDispo
SET dispoType = CASE WHEN dispoCondensed = 'Plea' THEN 'Plea'
					 WHEN dispoCondensed IN ('Convicted and Plea', 'Conviction') THEN 'Trial Conviction'
					 WHEN isAcdm = 1 THEN 'ACD'
					 WHEN isAcq = 1 THEN 'Acquittal'
					 WHEN isDsm = 1 THEN 'Dismissal'
					 WHEN isOther = 1 THEN 'Other'
				ELSE NULL END
FROM dbo.danyDashDispo


UPDATE dbo.danyDashDispo
SET dispoTypeDetail = CASE 
		WHEN isPleaConvict = 1
			THEN CASE 
					WHEN dispoType LIKE '%Convict%'
						THEN dispoType + ' on ' + dispoTopCat
					ELSE dispoType + ' to ' + dispoTopCat
					END
		ELSE dispoType
		END
FROM dbo.danyDashDispo

UPDATE dbo.danyDashDispo
SET dispoTypeDetail = dispoTypeDetail + ' Charge'
FROM danyDashDispo 
WHERE dispoTypeDetail LIKE '%Unknown%'

UPDATE dbo.danyDashDispo
SET dispoType = CASE WHEN isPleaConvict = 1 THEN 'Conviction' ELSE dispoType END
FROM dbo.danyDashDispo

UPDATE dbo.danyDashDispo
SET nextScheduledCourtAppearance = CASE WHEN CONVERT(DATE, nxt.scheduledEventDateTime) > CONVERT(DATE, ds.nextOnDate)
										THEN CONVERT(DATE, nxt.scheduledEventDateTime) 
									ELSE CONVERT(DATE, ds.nextOnDate) END
FROM dbo.danyDashDispo d
JOIN dms.dbo.defendantSummary ds On ds.defendantId = d.defendantId
LEFT JOIN dms.dbo.evt nxt on nxt.eventId = ds.nextEvtId
WHERE 
	CONVERT(DATE, ds.nextOnDate) >= CONVERT(DATE, getDate())			
 OR CONVERT(DATE, nxt.scheduledEventDateTime) >= CONVERT(DATE, getDate())


UPDATE dbo.danyDashDispo
SET instTopCat = CASE 
		WHEN instTopCat IN (
				'Felony',
				'Misdemeanor',
				'Violation/Infraction'
				)
			THEN instTopCat
		ELSE 'Unknown'
		END,
	instTopMg = CASE WHEN instTopMg = 'Other Unknown' OR instTopMg IS NULL THEN 'Unknown' ELSE instTopMg END,
	dispoTopMg = CASE WHEN dispoTopMg = 'Other Unknown' OR dispoTopMg IS NULL THEN 'Unknown' ELSE dispoTopMg END
FROM dbo.danyDashDispo

-- create second charge category column for filtering, which combines vfo flag and instant charge category
UPDATE dbo.danyDashDispo
SET instTopCat2 = CASE 
		WHEN instTopCat = 'Felony'
			AND instTopVfo = 1
			THEN 'Violent Felony'
		WHEN instTopCat = 'Felony'
			AND instTopVfo = 0
			THEN 'Non-Violent Felony'
		ELSE instTopCat
		END
FROM dbo.danyDashDispo

 SELECT  *
 FROM dbo.danyDashDispo
