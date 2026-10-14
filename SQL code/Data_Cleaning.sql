                                                     -- DATABASE CLEANING --

-- Create extension for converting Longitude and Latitude to metric units --

CREATE EXTENSION IF NOT EXISTS cube;
CREATE EXTENSION IF NOT EXISTS earthdistance;

-- Cleaning the data and adding 'School Age' and 'Distance from Sydney' columns--
-- Also omit columns containing contact info, containing only nulls or same values and redundant location information --

DROP TABLE IF EXISTS enrol_db_cleaned;
CREATE TABLE enrol_db_cleaned AS
SELECT school_code,
       school_name,
       Postcode::int,
       town_suburb AS suburb,
       COALESCE(latest_year_enrolment_FTE, '0')::numeric AS latest_year_enrolment_fte,
       COALESCE(REPLACE(indigenous_pct, 'np', '0'), '0')::numeric AS indigenous_pct,
       COALESCE(REPLACE(LBOTE_pct, 'np', '0'), '0')::numeric AS LBOTE_pct,
       COALESCE(ICSEA_value, '0')::numeric AS icsea_value,
       COALESCE(FOEI_value, '0')::int AS foei_value,
       ((EXTRACT('year' FROM TIMESTAMP '2026-01-01'))-(EXTRACT('year' FROM CAST(date_1st_teacher AS date))))::numeric AS School_age,
       (earth_distance(ll_to_earth(latitude, longitude), ll_to_earth(-33.885, 151.205)) / 1000)::numeric AS distance_from_syd_kms,
       level_of_schooling,
       selective_school,
       school_specialty_type,
       school_subtype,
       opportunity_class,
       preschool_ind,
       distance_education,
       intensive_english_centre,
       school_gender,
       principal_network,
       LGA,
       ASGS_remoteness
FROM enrol_db;

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
--        COUNT(*) - COUNT(postcode) AS postcode_nulls,
--        COUNT(*) - COUNT(latest_year_enrolment_fte) AS latest_year_enrolment_fte_nulls,
--        COUNT(*) - COUNT(indigenous_pct) AS indigenous_pct_nulls,
--        COUNT(*) - COUNT(lbote_pct) AS lbote_pct_nulls,
--        COUNT(*) - COUNT(icsea_value) AS icsea_value_nulls,
--        COUNT(*) - COUNT(foei_value) AS foei_value_nulls,
--        COUNT(*) - COUNT(suburb) AS suburb,
--        COUNT(*) - COUNT(level_of_schooling) AS level_of_schooling_nulls,
--        COUNT(*) - COUNT(selective_school) AS selective_school_nulls,
--        COUNT(*) - COUNT(opportunity_class) AS opportunity_class_nulls,
--        COUNT(*) - COUNT(school_specialty_type) AS school_specialty_type_nulls,
--        COUNT(*) - COUNT(school_subtype) AS school_subtype_nulls,
--        COUNT(*) - COUNT(preschool_ind) AS preschool_ind_nulls,
--        COUNT(*) - COUNT(distance_education) AS distance_education_nulls,
--        COUNT(*) - COUNT(intensive_english_centre) AS intensive_english_centre_nulls,
--        COUNT(*) - COUNT(school_gender) AS school_gender_nulls,
--        COUNT(*) - COUNT(principal_network) AS principal_network_nulls,
--        COUNT(*) - COUNT(lga) AS lga_nulls,
--        COUNT(*) - COUNT(asgs_remoteness) AS asgs_remoteness_nulls
-- FROM enrol_db_cleaned;

------------------------------------------------------

-- Data Trimming

-- What are the predominant characteristics of schools that fall out of the NSSC scope? ie Have 0 fte enrolments?

SELECT *
FROM enrol_db_cleaned
WHERE latest_year_enrolment_fte = 0;

-- Schools with the subtype relating to Environmental Education, Hospital and Debilitated seem to make up the majority
-- Lets explore further to see what subtypes have all reported 0 enrolment figures.

WITH subtype_0_count AS (SELECT school_subtype,
                                COUNT(*) AS O_count
                         FROM enrol_db_cleaned
                         WHERE latest_year_enrolment_fte = 0
                         GROUP BY 1),
                         
     subtype_tot_count AS (SELECT school_subtype,
                                  COUNT(*) AS total_count
                           FROM enrol_db_cleaned
                           GROUP BY 1)
                           
SELECT a.school_subtype,
       b.total_count,
       a.O_count AS O_count,
       (b.total_count)-(a.O_count) AS difference
FROM subtype_0_count AS a
JOIN subtype_tot_count AS b
  ON a.school_subtype = b.school_subtype;
  
-- All school subtypes with difference counts of 0 fall out of the scope of the NSSC and therefore have 0 enrolment figures
-- Lets update this table to exclude these schools to avoid skewage in further analysis.

DELETE FROM enrol_db_cleaned
WHERE school_subtype IN ('Debilitated by physical difficulties',
                         'Hospital School',
                         'Nursery school (similar to a Pre school)',
                         'Diagnostic remedial reading assesment',
                         'Environmental Education Centre (formerly Field Studies Centres)');
                         