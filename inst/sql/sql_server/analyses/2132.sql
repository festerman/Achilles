-- 2132	Proportion of device_exposure records outside a valid observation period
--
-- stratum_1:   Proportion to 6 decimals places
-- stratum_2:   Number of device_exposure records outside a valid observation period (numerator)
-- stratum_3:   Number of device_exposure records (denominator)
-- count_value: Flag (0 or 1) indicating whether any such records exist
--

WITH op_outside AS (
SELECT 
	COUNT_BIG(*) AS record_count
FROM 
	@cdmDatabaseSchema.device_exposure de
LEFT JOIN 
	@cdmDatabaseSchema.observation_period op 
ON 
	de.person_id = op.person_id
AND 
	de.device_exposure_start_date >= op.observation_period_start_date
AND 
	de.device_exposure_start_date <= op.observation_period_end_date
WHERE
	op.person_id IS NULL
), de_total AS (
SELECT
	COUNT_BIG(*) record_count
FROM
	@cdmDatabaseSchema.device_exposure
)
SELECT 
	2132 AS analysis_id,
	CASE WHEN det.record_count != 0 THEN
		CAST(CAST(1.0*op.record_count/det.record_count AS NUMERIC(7,6)) AS VARCHAR(255)) 
	ELSE 
		CAST(NULL AS VARCHAR(255))
	END AS stratum_1, 
	CAST(op.record_count AS VARCHAR(255)) AS stratum_2,
	CAST(det.record_count AS VARCHAR(255)) AS stratum_3,
	CAST(NULL AS VARCHAR(255)) AS stratum_4,
	CAST(NULL AS VARCHAR(255)) AS stratum_5,
	SIGN(op.record_count) AS count_value
INTO 
	@scratchDatabaseSchema@schemaDelim@tempAchillesPrefix_2132
FROM 
	op_outside op
CROSS JOIN 
	de_total det
;