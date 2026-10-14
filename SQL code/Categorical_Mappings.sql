                                 -- Converting Categorical Data into Numerical Form -- 


-- Category Mapping For Categorical Data--

DROP TABLE IF EXISTS suburb_mapping;
CREATE TABLE suburb_mapping AS
SELECT ROW_NUMBER() OVER (ORDER BY suburb) AS suburb_rank,
       suburb
FROM (SELECT DISTINCT suburb FROM enrol_db_cleaned);

DROP TABLE IF EXISTS school_lvl_mapping;
CREATE TABLE school_lvl_mapping AS
SELECT ROW_NUMBER() OVER (ORDER BY level_of_schooling) AS school_lvl_rank,
       level_of_schooling
FROM (SELECT DISTINCT level_of_schooling FROM enrol_db_cleaned);

DROP TABLE IF EXISTS selective_mapping;
CREATE TABLE selective_mapping AS
SELECT ROW_NUMBER() OVER (ORDER BY selective_school) AS selective_rank,
       selective_school
FROM (SELECT DISTINCT selective_school FROM enrol_db_cleaned);

DROP TABLE IF EXISTS opp_mapping;
CREATE TABLE opp_mapping AS
SELECT (ROW_NUMBER() OVER (ORDER BY opportunity_class))-1 AS opp_rank,
       opportunity_class
FROM (SELECT DISTINCT opportunity_class FROM enrol_db_cleaned);

DROP TABLE IF EXISTS specialty_mapping;
CREATE TABLE specialty_mapping AS
SELECT ROW_NUMBER() OVER (ORDER BY school_specialty_type) AS specialty_rank,
       school_specialty_type
FROM (SELECT DISTINCT school_specialty_type FROM enrol_db_cleaned);

DROP TABLE IF EXISTS subtype_mapping;
CREATE TABLE subtype_mapping AS
SELECT ROW_NUMBER() OVER (ORDER BY school_subtype) AS subtype_rank,
       school_subtype
FROM (SELECT DISTINCT school_subtype FROM enrol_db_cleaned);

DROP TABLE IF EXISTS pre_mapping;
CREATE TABLE pre_mapping AS
SELECT (ROW_NUMBER() OVER (ORDER BY preschool_ind))-1 AS pre_rank,
       preschool_ind
FROM (SELECT DISTINCT preschool_ind FROM enrol_db_cleaned);

DROP TABLE IF EXISTS dist_mapping;
CREATE TABLE dist_mapping AS
SELECT (ROW_NUMBER() OVER (ORDER BY distance_education = 'C',
                                    distance_education = 'Y',
                                    distance_education = 'N')) -1 AS dist_rank,
       distance_education
FROM (SELECT DISTINCT distance_education FROM enrol_db_cleaned);

DROP TABLE IF EXISTS int_eng_mapping;
CREATE TABLE int_eng_mapping AS
SELECT (ROW_NUMBER() OVER (ORDER BY intensive_english_centre))-1 AS int_eng_rank,
       intensive_english_centre
FROM (SELECT DISTINCT intensive_english_centre FROM enrol_db_cleaned);

DROP TABLE IF EXISTS gender_mapping;
CREATE TABLE gender_mapping AS
SELECT (ROW_NUMBER() OVER (ORDER BY school_gender = 'Girls',
                                    school_gender = 'Boys',
                                    school_gender = 'Coed')) -1 AS gender_rank,
       school_gender
FROM (SELECT DISTINCT school_gender FROM enrol_db_cleaned);

DROP TABLE IF EXISTS principal_network_mapping;
CREATE TABLE principal_network_mapping AS
SELECT ROW_NUMBER() OVER (ORDER BY principal_network) AS principal_network_rank,
       principal_network
FROM (SELECT DISTINCT principal_network FROM enrol_db_cleaned);

DROP TABLE IF EXISTS lga_mapping;
CREATE TABLE lga_mapping AS
SELECT ROW_NUMBER() OVER (ORDER BY LGA) AS lga_rank,
       LGA
FROM (SELECT DISTINCT LGA FROM enrol_db_cleaned);

DROP TABLE IF EXISTS remoteness_mapping;
CREATE TABLE remoteness_mapping AS
SELECT ROW_NUMBER() OVER (ORDER BY ASGS_remoteness) AS remoteness_rank,
       ASGS_remoteness
FROM (SELECT DISTINCT ASGS_remoteness FROM enrol_db_cleaned);

------------------------------------------------------

-- Applying mappings for Categorical conversions --

DROP TABLE IF EXISTS enrol_db_converted;
CREATE TABLE enrol_db_converted AS
SELECT *
FROM enrol_db_cleaned;

UPDATE enrol_db_converted
SET suburb = suburb_rank
FROM suburb_mapping
WHERE enrol_db_converted.suburb = suburb_mapping.suburb;

UPDATE enrol_db_converted
SET level_of_schooling = school_lvl_rank
FROM school_lvl_mapping
WHERE enrol_db_converted.level_of_schooling = school_lvl_mapping.level_of_schooling;

UPDATE enrol_db_converted
SET selective_school = selective_rank
FROM selective_mapping
WHERE enrol_db_converted.selective_school = selective_mapping.selective_school;

UPDATE enrol_db_converted
SET opportunity_class = opp_rank
FROM opp_mapping
WHERE enrol_db_converted.opportunity_class = opp_mapping.opportunity_class;

UPDATE enrol_db_converted
SET school_specialty_type = specialty_rank
FROM specialty_mapping
WHERE enrol_db_converted.school_specialty_type = specialty_mapping.school_specialty_type;

UPDATE enrol_db_converted
SET school_subtype = subtype_rank
FROM subtype_mapping
WHERE enrol_db_converted.school_subtype = subtype_mapping.school_subtype;

UPDATE enrol_db_converted
SET preschool_ind = pre_rank
FROM pre_mapping
WHERE enrol_db_converted.preschool_ind = pre_mapping.preschool_ind;

UPDATE enrol_db_converted
SET distance_education = dist_rank
FROM dist_mapping
WHERE enrol_db_converted.distance_education = dist_mapping.distance_education;

UPDATE enrol_db_converted
SET intensive_english_centre = int_eng_rank
FROM int_eng_mapping
WHERE enrol_db_converted.intensive_english_centre = int_eng_mapping.intensive_english_centre;

UPDATE enrol_db_converted
SET school_gender = gender_rank
FROM gender_mapping
WHERE enrol_db_converted.school_gender = gender_mapping.school_gender;

UPDATE enrol_db_converted
SET principal_network = principal_network_rank
FROM principal_network_mapping
WHERE enrol_db_converted.principal_network = principal_network_mapping.principal_network;

UPDATE enrol_db_converted
SET LGA = lga_rank
FROM lga_mapping
WHERE enrol_db_converted.LGA = lga_mapping.LGA;

UPDATE enrol_db_converted
SET ASGS_remoteness = remoteness_rank
FROM remoteness_mapping
WHERE enrol_db_converted.ASGS_remoteness = remoteness_mapping.ASGS_remoteness;

------------------------------------------------------

SELECT * FROM enrol_db_converted ORDER BY school_code;