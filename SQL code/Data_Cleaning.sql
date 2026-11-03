                                                     -- DATABASE CLEANING --

-- Create extension for converting Longitude and Latitude to metric units --

CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;

-- Cleaning the data and adding 'School Age' and 'Distance from Sydney' columns--
-- Also omit columns containing contact info, containing only nulls or same values and redundant location information --
-- We will also omit rows that possess missing lga and asgs_remoteness values as well as keeping foei and icsea 0's as nulls/missing

DROP TABLE IF EXISTS enrol_db_cleaned;
CREATE TABLE enrol_db_cleaned AS
SELECT school_code,
       school_name,
       latest_year_enrolment_FTE::numeric AS latest_year_enrolment_fte,
       COALESCE(REPLACE(indigenous_pct, 'np', '0'), '0')::numeric AS indigenous_pct,
       COALESCE(REPLACE(LBOTE_pct, 'np', '0'), '0')::numeric AS LBOTE_pct,
       NULLIF(ICSEA_value::numeric, 0) AS icsea_value,
       NULLIF(FOEI_value::int, 0) AS foei_value,
       ((EXTRACT('year' FROM TIMESTAMP '2026-01-01'))-(EXTRACT('year' FROM CAST(date_1st_teacher AS date))))::numeric AS School_age,
       (earth_distance(ll_to_earth(latitude, longitude), ll_to_earth(-33.885, 151.205)) / 1000)::numeric AS distance_from_syd_kms,
       LGA,
       level_of_schooling,
       ASGS_remoteness
FROM enrol_db
WHERE latest_year_enrolment_fte IS NOT NULL;

SELECT * FROM enrol_db_cleaned LIMIT 300;

-- NULL column identification statement generator and check---

DROP TABLE IF EXISTS null_count_statement;
CREATE TEMPORARY TABLE null_count_statement AS (
SELECT string_agg(
   format('COUNT(*) - COUNT(%I) AS %I_nulls',
          column_name,
          column_name), ', ')
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'enrol_db');

-- SELECT COUNT(*) - COUNT(school_code) AS school_code_nulls,
--        COUNT(*) - COUNT(latest_year_enrolment_fte) AS latest_year_enrolment_fte_nulls,
--        COUNT(*) - COUNT(indigenous_pct) AS indigenous_pct_nulls,
--        COUNT(*) - COUNT(lbote_pct) AS lbote_pct_nulls,
--        COUNT(*) - COUNT(icsea_value) AS icsea_value_nulls,
--        COUNT(*) - COUNT(foei_value) AS foei_value_nulls,
--        COUNT(*) - COUNT(level_of_schooling) AS level_of_schooling_nulls,
--        COUNT(*) - COUNT(lga) AS lga_nulls,
--        COUNT(*) - COUNT(asgs_remoteness) AS asgs_remoteness_nulls
-- FROM enrol_db_cleaned;
                   