USE PLANINTDB;

IF OBJECT_Id('dbo.danyDashSenFine', 'U') IS NOT NULL
DROP TABLE dbo.danyDashSenFine

CREATE TABLE dbo.danyDashSenFine (
planningSentencesId INT NOT NULL,
defendantId INT NOT NULL,
sentEventId INT NULL,
sentenceDate DATE NULL,
sentenceYear INT NULL,
sentenceType VARCHAR(200) NULL,
sentenceClean VARCHAR(200) NULL,
senFineCmid INT NULL,
senFineCat VARCHAR(50) NULL,
senFineCat2 VARCHAR(50) NULL,
senFineClass VARCHAR(10) NULL,
senFineChg VARCHAR(50) NULL,
senFineTxt VARCHAR(200) NULL,
senFineMg VARCHAR(200) NULL,
senFineVfo INT NULL DEFAULT 0,
fineRest MONEY NULL,
fineCatAmt VARCHAR(200) NULL,
senChgOrder INT NULL,
isTopChg INT NULL DEFAULT 0
)

INSERT INTO dbo.danyDashSenFine 
SELECT DISTINCT
	ps.planningSentencesId,
	ps.defendantId,
	ps.sentEventId,
	ps.sentenceDate,
	YEAR(ps.sentenceDate) AS sentenceYear,
	ps.sentenceType,
	ps.sentenceClean,
	senFineCmid = c.chargeModificationId,
	senFineCat = c.category,
	senFineCat2 = CASE WHEN c.category = 'Felony' AND c.isVFO = 1
						THEN 'Violent Felony'
					  WHEN c.category = 'Felony' AND c.isVFO = 0
						THEN 'Non-Violent Felony'
					  ELSE c.category
				 END,
	senFineClass = c.class,
	senFineChg = c.chargeClean,
	senFineTxt = c.chargeDescription,
	senFineMg = c.majorGroup,
	senFineVfo = c.isVFO,
	ps.fineRest,
	fineCatAmt = CASE WHEN ps.fineRest > 0 AND ps.fineRest < 50 THEN 'Under $50'
					  WHEN ps.fineRest >= 50 AND ps.fineRest <= 100 THEN '$50-$100'
					  WHEN ps.fineRest > 100 AND ps.fineRest <= 500 THEN '$100-$500'
					  WHEN ps.fineRest > 500 AND ps.fineRest <= 1000 THEN '$500-$1,000'
					  WHEN ps.fineRest > 1000 AND ps.fineRest <= 5000 THEN '$1,000-$5,000'
					  WHEN ps.fineRest > 5000 AND ps.fineRest <= 10000 THEN '$5,000-$10,000'
					  WHEN ps.fineRest > 10000 THEN 'Over $10,000'
				 ELSE 'Unknown' END,
	ps.senChgOrder,
	isTopChg = CASE WHEN ps.senChgOrder = 1 THEN 1 ELSE 0 END
FROM dms.dbo.planning_sentences2 ps
JOIN dms.dbo.planning_charges2 c ON c.chargeModificationId = ps.chargeModificationId
WHERE 
	ps.defSenOrder = 1
AND ps.senChgOrder = 1
AND ps.isTopSentence = 1
AND YEAR(ps.sentenceDate) >= 2013 
AND ps.sentenceClean IN ('Fine', 
						   'Restitution', 
						   'Asset Forfeiture')


UPDATE dbo.danyDashSenFine
SET senFineMg = CASE WHEN senFineMg = 'Other Unknown' OR senFineMg IS NULL THEN 'Unknown' ELSE senFineMg END
FROM dbo.danyDashSenFine

SELECT
*
FROM dbo.danyDashSenFine
