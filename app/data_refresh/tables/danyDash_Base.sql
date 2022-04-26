USE PLANINTDB;

/* drop table */
IF OBJECT_ID('dbo.danyDashBase', 'U') IS NOT NULL
DROP TABLE dbo.danyDashBase

CREATE TABLE dbo.danyDashBase (
defendantId INT PRIMARY KEY,
nysid VARCHAR(20) NULL,
arrestDate DATE NULL,
screenDate DATE NULL,
arrestLocation VARCHAR(150) NULL,
gender VARCHAR(100) NULL,
race VARCHAR(100) NULL,
raceCat VARCHAR(100) NULL,
ageAtOff INT NULL,
ageAtOffGrp VARCHAR(100) NULL,
caseStatus VARCHAR(100) NULL,
caseType VARCHAR(200) NULL,
priorFelConv INT NULL DEFAULT 0,
priorFelConvGrp VARCHAR(50) NULL,
priorMisdConv INT NULL DEFAULT 0,
priorMisdConvGrp VARCHAR(50) NULL,
yrSinceLastConv INT NULL,
yrSinceLastConvGrp VARCHAR(50) NULL
)

INSERT INTO dbo.danyDashBase
(defendantId,
 nysid,
 screenDate,
 gender,
 race,
 ageAtOff,
 ageAtOffGrp,
 caseStatus,
 caseType,
 arrestDate
)
SELECT
	f.defendantId,
	f.nysid,
	f.firstEvtDate,
	gender = CASE 
		WHEN f.gender IN (
				'Male',
				'Female'
				)
			THEN f.gender
		ELSE 'Other/Unknown'
		END,
	race = CASE 
		WHEN f.race IN ('American Indian/Alaskan Native',
                        'Asian/Pacific Islander',
                        'Black',
                        'Black-Hispanic',
                        'White',
                        'White-Hispanic')
			THEN f.race
		ELSE 'Other/Unknown'
		END,
	f.ageAtOff,
	ageAtOffGrp = CASE WHEN 
							 ageAtOff < 18 THEN 'Under 18'
						WHEN ageAtOff BETWEEN 18 AND 26 THEN '18-26'
						WHEN ageAtOff BETWEEN 27 AND 35 THEN '27-35'
						WHEN ageAtOff BETWEEN 36 AND 45 THEN '36-45'
						WHEN ageAtOff BETWEEN 46 AND 55 THEN '46-55'
						WHEN ageAtOff BETWEEN 56 AND 65 THEN '56-65'
						WHEN ageAtOff >= 65 THEN '65+'
					ELSE 'Unknown' END,
	f.caseStatus,
	f.caseType,
	f.arrestDate
FROM dms.dbo.planning_defSummary2 def
	JOIN dms.dbo.planning_fe2 f ON f.defendantid = def.defendantid
WHERE
	EXISTS (SELECT 1
			FROM dms.dbo.evt e
			/* event is a court event */
			JOIN dms.dbo.EventTypeLu typ On typ.EventTypeId = e.EventTypeId 
			WHERE 
				e.defendantId = def.DefendantId
			AND YEAR(e.eventDateTime) >=2013
			AND typ.IsCourtEvent = 1
			)

/* Update Arrest Location */
UPDATE dbo.danyDashBase
SET arrestLocation = CASE WHEN a.ArrestPct IS NULL THEN 'Unknown/Unrecorded'
						  WHEN a.ArrestPct = 001 THEN 'Tribeca, Soho, and Financial District'
						  WHEN a.ArrestPct IN (005,007) THEN  'Lower East Side, Nolita, and Chinatown'
						  WHEN a.ArrestPct = 009 THEN 'East Village'
						  WHEN a.ArrestPct = 013 THEN 'Gramercy Park and Flatiron'
						  WHEN a.ArrestPct = 006 THEN 'West Village and Greenwich Village'
						  WHEN a.ArrestPct = 010 THEN 'Midtown West and Chelsea'
						  WHEN a.ArrestPct = 017 THEN 'Midtown East'
						  WHEN a.ArrestPct = 014 THEN 'Midtown South'
						  WHEN a.ArrestPct = 018 THEN 'Midtown North'
						  WHEN a.ArrestPct = 022 THEN 'Central Park'
						  WHEN a.ArrestPct = 019 THEN 'Upper East Side'
						  WHEN a.ArrestPct IN (020, 024) THEN 'Upper West Side'
						  WHEN a.ArrestPct IN (026, 028, 032) THEN 'Central and West Harlem'
						  WHEN a.ArrestPct IN (023, 025) THEN 'East Harlem'
						  WHEN a.ArrestPct IN (030, 033, 034) THEN 'Sugar Hill, Washington Heights, and Inwood'
						  ELSE 'Outside Manhattan' END
FROM dbo.danyDashBase b
	JOIN dms.dbo.planning_fe2 f on f.defendantID = b.defendantID
	JOIN dms.dbo.Arrest a on a.ArrestID = f.arrestID

UPDATE dbo.danyDashBase
SET arrestLocation = 'Unknown/Unrecorded'
FROM dbo.danyDashBase
WHERE arrestLocation IS NULL

/* Add race cat */
UPDATE dbo.danyDashBase
SET raceCat = CASE 
		WHEN race LIKE '%Hispanic%'
			THEN 'Hispanic'
		ELSE race
		END
FROM dbo.danyDashBase

/* This statement calculates prior misdemeanor and felony convictions at the time of screening
using the planning_convictions2 table + yrs since most recent conviction */
/* 1. identify the most recent conviction info for historical convictions with multiple conviction events */
;WITH pick AS (
SELECT
base.DefendantId,
conv.DefendantId AS priorDef,
Conv.ConvEventId,
LEAD(conv.ConvEventId,1) OVER(
							PARTITION BY base.DefendantId, conv.DefendantId
							ORDER BY conv.ConvOrder, Evt.EventDateTime, 
									Evt.EventOrder, COALESCE(Evt.InsertDateTime, Evt.LastUpdateTime)) AS best
FROM dbo.danyDashBase base
JOIN dms.dbo.planning_convictions2 conv ON conv.nysid = base.nysid
JOIN dms.dbo.evt ON evt.EventId = conv.ConvEventId
WHERE 
	conv.ConvDate < base.ScreenDate
AND (CASE WHEN conv.DismissDate <= base.ScreenDate THEN 0 ELSE 1 END) = 1
AND ConvCount > 1
AND ConvTopCat IN ('Felony', 'Misdemeanor')
)
/* 2. union conviction details where there's only one prior conviction event w/ the most recent info from the tmp table */
, draw AS (
SELECT
base.DefendantId,
conv.PlanningConvictionsId,
conv.convDate,
conv.ConvTopCat
FROM dbo.danyDashBase base
JOIN dms.dbo.planning_convictions2 conv ON conv.nysid = base.nysid
WHERE 
	conv.ConvDate < base.ScreenDate
AND (CASE WHEN conv.DismissDate <= base.ScreenDate THEN 0 ELSE 1 END) = 1
AND ConvCount = 1
AND ConvTopCat IN ('Felony', 'Misdemeanor') 
UNION
SELECT
base.DefendantId,
conv.PlanningConvictionsId,
conv.convDate,
conv.ConvTopCat
FROM dbo.danyDashBase base
JOIN pick ON pick.DefendantId = base.DefendantId
JOIN dms.dbo.planning_convictions2 conv ON conv.ConvEventId = pick.ConvEventId
WHERE pick.Best IS NULL
)
/* 3. do all the calculations here */
, calc AS (
SELECT
draw.DefendantId,
COUNT(DISTINCT PlanningConvictionsId) AS PriorConv,
SUM(CASE WHEN ConvTopCat = 'Felony' THEN 1 ELSE 0 END) priorFel,
SUM(CASE WHEN ConvTopCat = 'Misdemeanor' THEN 1 ELSE 0 END) priorMisd,
MAX(ConvDate) AS MostRecentConv
FROM draw
GROUP BY draw.DefendantId
)
UPDATE dbo.danyDashBase 
SET PriorFelConv = PriorFel,
	PriorMisdConv = PriorMisd,
	yrSinceLastConv = DATEDIFF(dd, MostRecentConv, base.ScreenDate)/365
FROM dbo.danyDashBase base
JOIN calc ON calc.DefendantId = base.DefendantId

/* set prior conviction categorys (fel, misd, yrs since most recent (fel or misd) conv) */
UPDATE dbo.danyDashBase
SET PriorFelConvGrp = CASE WHEN nysid IS NULL THEN 'Criminal history unknown'
						ELSE 
							CASE WHEN PriorFelConv = 0 THEN 'No prior convictions'
									WHEN PriorFelConv BETWEEN 1 AND 2 THEN '1-2 prior convictions'
									WHEN PriorFelConv >= 3 THEN '3+ prior convictions'
							ELSE 'Criminal history unknown' END
						END,
	PriorMisdConvGrp = CASE WHEN nysid IS NULL THEN 'Criminal history unknown'
							  ELSE 
								CASE WHEN PriorMisdConv = 0 THEN 'No prior convictions'
									 WHEN PriorMisdConv BETWEEN 1 AND 2 THEN '1-2 prior convictions'
									 WHEN PriorMisdConv BETWEEN 3 AND 4 THEN '3-4 prior convictions'
									 WHEN PriorMisdConv >= 5 THEN '5+ prior convictions'
							ELSE 'Criminal history unknown' END
						END,
	yrSinceLastConvGrp = CASE WHEN nysid IS NULL THEN 'Criminal history unknown'
								ELSE 
									CASE WHEN yrSinceLastConv < 1 THEN 'Under 1 year'
										 WHEN yrSinceLastConv BETWEEN 1 AND 2 THEN '1-2 years'
										 WHEN yrSinceLastConv BETWEEN 2 AND 5 THEN '2-5 years'
										 WHEN yrSinceLastConv BETWEEN 5 AND 10 THEN '5-10 years'
										 WHEN yrSinceLastConv >= 10 THEN '10+ years' 
								ELSE 'No prior convictions' END
							END
FROM dbo.danyDashBase

-- TODO: Create fake NYSID which can be used on dashboard instead of real NYSID
-- In the meantime, remove personal identifier for security reasons. In case of hack, NYSID should not be in the application data.
UPDATE dbo.danyDashBase
SET nysid = NULL
FROM dbo.danyDashBase

SELECT*
FROM dbo.danyDashBase
