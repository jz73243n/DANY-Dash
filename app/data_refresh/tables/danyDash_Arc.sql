USE PLANINTDB;

IF OBJECT_Id('dbo.danyDashArc','U') IS NOT NULL
DROP TABLE dbo.danyDashArc;

CREATE TABLE dbo.danyDashArc (
defendantId INT NOT NULL,
arcDate DATE NULL,
arcYear INT NULL,
arcOutcome VARCHAR(250) NULL,
scrTopCmid INT NULL,
scrTopCat VARCHAR(100) NULL,
scrTopCat2 VARCHAR(100) NULL,
scrTopClass VARCHAR(20) NULL,
scrTopChg VARCHAR(100) NULL,
scrTopTxt VARCHAR(250) NULL,
scrTopMg VARCHAR(200) NULL,
scrTopVfo INT NULL DEFAULT 0,
arcTopCmid INT NULL,
arcTopCat VARCHAR(100) NULL,
arcTopClass VARCHAR(20) NULL,
arcTopChg VARCHAR(100) NULL,
arcTopTxt VARCHAR(250) NULL,
arcTopMg VARCHAR(200) NULL,
releaseStatus VARCHAR(150) NULL,
releaseStatusCond VARCHAR(250) NULL,
dollarBail INT DEFAULT 0,
arcSurvive INT NULL,
arcSurviveTxt VARCHAR(60),
bailReq INT DEFAULT 0,
bailSet INT DEFAULT 0,
bailReqAmt MONEY NULL,
bailSetAmt MONEY NULL,
pleaOfferType VARCHAR(150) NULL,
pleaOfferDays VARCHAR(200) NULL,
pleaOfferOutcome VARCHAR(150) NULL
)

INSERT INTO dbo.danyDashArc (
	defendantId,
	arcDate,
	arcYear,
	arcOutcome,
	scrTopCmid,
	scrTopCat,
	scrTopClass,
	scrTopChg,
	arcTopCat,
	arcTopClass,
	arcTopCmid,
	arcTopChg,
	arcTopTxt,
	releaseStatus,
	releaseStatusCond,
	dollarBail,
	arcSurvive,
	bailReq,
	bailSet,
	bailReqAmt,
	bailSetAmt,
	pleaOfferType, 
	pleaOfferDays,
	pleaOfferOutcome
)
SELECT
	fe.defendantId,
	arcDate,
	arcYear = year(ArcDate),
	arcOutcome,
	scrTopCmid,
	scrTopCat,
	scrTopClass,
	scrTopChg,
	arcTopCat,
	arcTopClass,
	arcTopCmid,
	arcTopChg,
	arcTopTxt,
	releaseStatus = CASE WHEN arc.arcSurvive = 0 THEN 'Case Disposed'
						 ELSE arc.releaseStatus END,
	releaseStatusCond = CASE WHEN arc.releaseStatus LIKE '%jail%' AND bailSetAmt = 1 THEN 'Dollar Bail'
							 WHEN arc.releaseStatus LIKE '%bail%' THEN 'Posted Bail'
							 WHEN arc.releaseStatus LIKE '%jail%' THEN 'Held on Bail'
							 WHEN arc.releaseStatus LIKE '%ROR%' THEN 'ROR'
							 WHEN arc.releaseStatus IN ('Supervised Release', 
														'Intensive Community Monitoring') THEN 'Supervised Release/Intensive Community Monitoring'
							 WHEN (arc.ReleaseStatus IS NULL OR 
								  arc.ReleaseStatus = 'Fugitive') 
								  AND arc.arcSurvive = 1 THEN 'Unknown/Other'
							 WHEN arcSurvive = 0 THEN 'Case Disposed'
							 ELSE arc.releaseStatus END,
	dollarBail,
	arcSurvive,
	bailReq,
	bailSet,
	bailReqAmt,
	bailSetAmt,
	pleaOfferType, 
	pleaOfferDays = LTRIM(RTRIM(pleaOfferDays)),
	pleaOfferOutcome
FROM dms.dbo.planning_arraignments2 arc
JOIN dms.dbo.planning_fe2 fe ON fe.defendantId = arc.defendantId
WHERE 
	fe.caseType <> 'Extradition'
AND YEAR(arc.arcDate) >= 2013

DROP INDEX IF EXISTS dd_arc_nys 
ON dbo.danyDashArc

UPDATE dbo.danyDashArc
SET arcSurvive = 1
FROM dbo.danyDashArc arc
WHERE arc.arcSurvive IS NULL
AND EXISTS (SELECT 1
			FROM dms.dbo.planning_dispositions2 d
			WHERE d.defendantId = arc.defendantId
			AND d.eventOrder = 1
			AND d.dispoDate > arc.arcDate
			)

UPDATE dbo.danyDashArc
SET arcSurvive = 1
FROM dbo.danyDashArc arc
WHERE arc.arcSurvive IS NULL
AND NOT EXISTS (SELECT 1
				FROM dms.dbo.planning_dispositions2 d
				WHERE d.defendantId = arc.defendantId
				AND d.eventOrder = 1
				AND d.dispoDate = arc.arcDate
				)

UPDATE dbo.danyDashArc
SET releaseStatusCond = 'Unknown/Other',
	arcSurvive = 1
FROM dbo.danyDashArc arc
WHERE releaseStatusCond IS NULL

UPDATE dbo.danyDashArc
SET scrTopTxt = c.chargeDescription,
	scrTopMg = c.majorGroup,
	scrTopVfo = c.isVFO
FROM dbo.danyDashArc arc
JOIN dms.dbo.planning_charges2 c On c.chargeModificationId = arc.scrTopCmid


UPDATE dbo.danyDashArc
SET arcTopMg = c.MajorGroup
FROM dbo.danyDashArc arc
LEFT JOIN dms.dbo.planning_charges2 c On c.chargeModificationId = arc.arcTopCmid
WHERE arc.arcSurvive = 1

UPDATE dbo.danyDashArc
SET releaseStatus = 'ROR'
FROM dbo.danyDashArc arc
WHERE arcSurvive = 1 AND releaseStatus IS NULL
AND bailSet = 0 


/* Remove NULLS */
UPDATE dbo.danyDashArc
SET scrTopCat = CASE 
		WHEN scrTopCat IN (
				'Felony',
				'Misdemeanor',
				'Violation/Infraction'
				)
			THEN scrTopCat
		ELSE 'Unknown'
		END,
	scrTopMg = CASE WHEN scrTopMg = 'Other Unknown' OR scrTopMg IS NULL THEN 'Unknown' ELSE scrTopMg END,
	scrTopTxt = ISNULL(scrTopTxt, 'Unknown'),
	arcTopCat = CASE 
		WHEN arcTopCat IN (
				'Felony',
				'Misdemeanor',
				'Violation/Infraction'
				)
			THEN arcTopCat
		ELSE 'Unknown'
		END,
	arcTopTxt = ISNULL(arcTopTxt, 'Unknown'),
	arcSurviveTxt = CASE 
		WHEN arcSurvive = 1
			THEN 'Continued Past Arraignment'
		WHEN arcSurvive = 0
			THEN 'Disposed at Arraignment'
		ELSE 'Unknown'
		END,
	arcTopMg = CASE WHEN arcTopMg = 'Other Unknown' OR arcTopMg IS NULL THEN 'Unknown' ELSE arcTopMg END
FROM dbo.danyDashArc

-- create second charge category column for filtering, which combines vfo flag and screen category
UPDATE dbo.danyDashArc
SET scrTopCat2 = CASE 
		WHEN arc.scrTopCat = 'Felony'
			AND arc.scrTopVfo = 1
			THEN 'Violent Felony'
		WHEN arc.scrTopCat = 'Felony'
			AND arc.scrTopVfo = 0
			THEN 'Non-Violent Felony'
		ELSE arc.scrTopCat
		END
FROM dbo.danyDashArc arc


SELECT
*
FROM dbo.danyDashArc
