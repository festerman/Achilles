-- 732	Proportion of drug_exposure records outside a valid observation period
--
-- stratum_1:   Proportion to 6 decimal places
-- stratum_2:   Number of drug_exposure records outside a valid observation period (numerator)
-- stratum_3:   Number of drug_exposure records (denominator)
-- count_value: Flag (0 or 1) indicating whether any such records exist
--

WITH op_outside AS (
SELECT 
	COUNT_BIG(*) AS record_count
FROM 
	@cdmDatabaseSchema.drug_exposure de
LEFT JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	de.person_id = op.person_id
AND 
	de.drug_exposure_start_date >= op.observation_period_start_date
AND 
	de.drug_exposure_start_date <= op.observation_period_end_date
WHERE
	op.person_id IS NULL
), de_total AS (
SELECT
	COUNT_BIG(*) record_count
FROM
	@cdmDatabaseSchema.drug_exposure
)
SELECT 
	732 AS analysis_id,
	CASE WHEN de.record_count != 0 THEN 
		CAST(CAST(1.0*op.record_count/de.record_count AS NUMERIC(7,6)) AS VARCHAR(255)) 
	ELSE 
		CAST(NULL AS VARCHAR(255)) 
	END AS stratum_1, 
	CAST(op.record_count AS VARCHAR(255)) AS stratum_2,
	CAST(de.record_count AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	SIGN(op.record_count) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_732
FROM 
	op_outside op
CROSS JOIN 
	de_total de
;