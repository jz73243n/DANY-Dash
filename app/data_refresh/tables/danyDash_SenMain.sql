USE PLANINTDB;

IF OBJECT_Id('dbo.danyDashSenMain', 'U') IS NOT NULL
DROP TABLE dbo.danyDashSenMain

CREATE TABLE dbo.danyDashSenMain (
planningSentencesId INT NOT NULL,
defendantId INT null,
sentEventId INT null,
sentenceDate DATE null,
sentenceYear INT NULL,
senTopCmId INT null,
senTopCat VARCHAR(100) NULL,
senTopCat2 VARCHAR(100) NULL,
senTopClass VARCHAR(50) NULL,
senTopChg VARCHAR(200) NULL,
senTopTxt VARCHAR(500) NULL,
senTopMg VARCHAR(200) NULL,
senTopVfo INT NULL DEFAULT 0,
sentenceType VARCHAR(500) null,
sentenceClean VARCHAR(500) null,
sentenceCondensed VARCHAR(500) null,
confineType VARCHAR(200) null,
confineLenType VARCHAR(200) null,
confineLength VARCHAR(200) null,
fineRest MONEY null,
sentenceCondition VARCHAR(500) null,
sentCondLength VARCHAR(500) null,
isPrison INT DEFAULT 0,
isJail INT DEFAULT 0,
isPrs INT DEFAULT 0,
isProbation INT DEFAULT 0,
isMoney INT NULL DEFAULT 0,
isCs INT NULL DEFAULT 0,
isCd INT NULL DEFAULT 0,
isTreatment INT NULL DEFAULT 0,
confineJailTime VARCHAR(150) NULL,
confinePrisTime VARCHAR(150) NULL,
fineCatAmt VARCHAR(150) NULL
)

INSERT INTO dbo.danyDashSenMain (
	planningSentencesId,
	defendantId,
	sentEventId,
	sentenceDate,
	sentenceYear,
	senTopCmId,
	senTopCat,
	senTopCat2,
	senTopClass,
	senTopChg,
	senTopTxt,
	senTopMg,
	senTopVfo,
	sentenceType,
	sentenceClean,
	sentenceCondensed,
	confineType,
	confineLenType,
	confineLength,
	fineRest,
	sentenceCondition,
	sentCondLength,
	isPrison,
	isJail,
	isPrs,
	isProbation,
	isMoney,
	isCs,
	isCd,
	isTreatment
)
SELECT
	sen.planningSentencesId,
	sen.defendantId,
	sen.sentEventId,
	sen.sentenceDate,
	sentenceYear = YEAR(sen.sentenceDate),
	senTopCmId = sen.chargeModificationId,
	senTopCat = ISNULL(c.category, 'Unknown'),
	senTopCat2 = CASE WHEN c.category = 'Felony' AND c.isVFO = 1
						THEN 'Violent Felony'
					  WHEN c.category = 'Felony' AND c.isVFO = 0
						THEN 'Non-Violent Felony'
					  ELSE ISNULL(c.category, 'Unknown')
				 END,
	senTopClass = c.class,
	senTopChg = c.chargeClean, 
	senTopTxt = c.chargeDescription,
	senTopMg = ISNULL(c.majorGroup, 'Unknown'),
	senTopVfo = c.isVFO,
	sen.sentenceType,
	sentenceClean = CASE WHEN sen.sentenceClean = 'Treatment Program' THEN 'Conditional Discharge' 
						 ELSE sentenceClean END,
	sen.sentenceCondensed,
	sen.confineType,
	sen.confineLenType,
	sen.confineLength,
	sen.fineRest,
	sen.sentenceCondition,
	sen.sentCondLength,
	sen.isPrison,
	sen.isJail,
	sen.isPRS,
	sen.isProbation,
	sen.isMoney,
	sen.isCS,
	sen.isCD,
	sen.isTreatment
FROM dms.dbo.planning_fe2 f
JOIN dms.dbo.planning_sentences2 sen On sen.defendantId = f.defendantId
LEFT JOIN dms.dbo.planning_charges2 c On c.chargeModificationId = sen.chargeModificationId
WHERE 
	sen.defSenOrder = 1
AND sen.senChgOrder = 1
AND sen.isTopSentence = 1
AND YEAR(sen.sentenceDate) >= 2013

;WITH jt AS (
SELECT
	s.planningSentencesId,
	jailTime = CASE WHEN s.confineLenType = 'Determinate' THEN maxYear_c + maxMonth_c/12.0 + maxDay_c/365.0
					WHEN s.confineLenType = 'Indeterminate' THEN minYear_c + minYear_c/12.0 + minDay_c/365.0
			   ELSE NULL END
FROM dbo.danyDashSenMain s
JOIN dms.dbo.planning_sentences2 sen On sen.PlanningSentencesId = s.planningSentencesId
WHERE 
	s.sentenceClean = 'Jail'
)
, jtcat AS (
SELECT
	planningSentencesId,
	jailTime,
	jailCat = CASE WHEN jailTime < 1/12.0 THEN 'Less than One Month'
				   WHEN jailTime >= 1/12.0 AND jailTime < 3/12.0 THEN '1-3 Months'
				   WHEN jailTime >= 3/12.0 AND jailTime < 6/12.0 THEN '3-6 Months'
				   WHEN jailTime >= 6/12.0 AND jailTime < 9/12.0 THEN '6-9 Months'
				   WHEN jailTime >= 9/12.0 AND jailTime <= 1.0 THEN '9-12 Months'
				ELSE 'Unknown' END
FROM jt
)
UPDATE dbo.danyDashSenMain
SET confineJailTime = jailCat
FROM dbo.danyDashSenMain s
JOIN jtcat j ON j.PlanningSentencesId = s.PlanningSentencesId


;WITH pt AS (
SELECT
	s.PlanningSentencesId,
	s.sentenceType,
	s.confineLength,
	prisTime = CASE WHEN s.confineLenType = 'Determinate'
						THEN maxYear_c + maxMonth_c/12.0 + maxDay_c/365.0
					WHEN s.confineLenType = 'Indeterminate'
						THEN minYear_c + minYear_c/12.0 + minDay_c/365.0
					ELSE NULL END
	FROM dbo.danyDashSenMain s
JOIN dms.dbo.planning_sentences2 sen On sen.planningSentencesId = s.planningSentencesId
WHERE 
	s.sentenceClean = 'Prison'
)
, pcat AS (
SELECT
	planningSentencesId,
	sentenceType,
	prisTime,
	prisCat = CASE WHEN prisTime BETWEEN 1.0 AND 3.0 THEN '1-3 Years'
				   WHEN prisTime > 3.0 AND prisTime <= 5.0 THEN '3-5 Years'
				   WHEN prisTime > 5.0 AND prisTime <= 7.0 THEN '5-7 Years'
				   WHEN prisTime > 7.0 AND prisTime <= 10.0 THEN '7-10 Years'
				   WHEN prisTime > 10.0 AND prisTime <= 15.0 THEN '10-15 Years'
				   WHEN prisTime > 15.0 AND prisTime <= 20.0 THEN '15-20 Years'
				   WHEN prisTime > 20.0 AND prisTime <= 25.0 THEN '20-25 Years'
				   WHEN prisTime > 25.0 THEN 'Over 25 Years'
				   WHEN sentenceType LIKE '%life%' OR confineLength = 'Life' THEN 'Life in Prison'
				ELSE 'Unknown' END
FROM pt
)
UPDATE dbo.danyDashSenMain
SET confinePrisTime = prisCat
FROM dbo.danyDashSenMain s
JOIN pcat p ON p.planningSentencesId = s.planningSentencesId

;WITH fine AS (
SELECT
	planningSentencesId,
	fineCat = CASE WHEN fineRest > 0 AND fineRest < 50 THEN 'Under $50'
				   WHEN fineRest >= 50 AND fineRest <= 100 THEN '$50-$100'
				   WHEN fineRest > 100 AND fineRest <= 500 THEN '$100-$500'
				   WHEN fineRest > 500 AND fineRest <= 1000 THEN '$500-$1,000'
				   WHEN fineRest > 1000 AND fineRest <= 5000 THEN '$1,000-$5,000'
				   WHEN fineRest > 5000 AND fineRest <= 10000 THEN '$5,000-$10,000'
				   WHEN fineRest > 10000 THEN 'Over $10,000'
			  ELSE 'Unknown' END
FROM dbo.danyDashSenMain
WHERE 
	fineRest > 0
)
UPDATE dbo.danyDashSenMain
SET fineCatAmt = fineCat
FROM dbo.danyDashSenMain s
JOIN fine ON fine.planningSentencesId = s.planningSentencesId

UPDATE dbo.danyDashSenMain
SET fineCatAmt = 'Unknown'
FROM dbo.danyDashSenMain
WHERE 
	sentenceClean IN ('Restitution', 
					  'Fine', 
					  'Asset Forfeiture')
AND fineCatAmt IS NULL


DELETE
FROM dbo.danyDashSenMain
WHERE planningSentencesId IN (SELECT planningSentencesId 
							  FROM dms.dbo.planning_sentences2 
							  WHERE sentenceClean = 'Parole')


UPDATE dbo.danyDashSenMain
SET sentenceClean = 'Conditional Discharge'
FROM dbo.danyDashSenMain s
JOIN dms.dbo.planning_sentences2 sen On sen.PlanningSentencesId = s.planningSentencesId
WHERE 
	s.sentenceClean = 'Parole' 
AND isResentencing = 0

UPDATE dbo.danyDashSenMain
SET senTopMg = CASE WHEN senTopMg = 'Other Unknown' OR senTopMg IS NULL THEN 'Unknown' ELSE senTopMg END
FROM dbo.danyDashSenMain

SELECT
*
FROM dbo.danyDashSenMain
