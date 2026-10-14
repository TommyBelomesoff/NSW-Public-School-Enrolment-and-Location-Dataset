                                             
                                              -- Descriptive Analysis --

SELECT * FROM enrol_db_cleaned;

------------------------------------------------------

-- Total Amount of fte Enrolments and School Count --

DROP TABLE IF EXISTS enrolment_totals;
CREATE TABLE enrolment_totals AS
SELECT SUM(latest_year_enrolment_fte) AS enrolment_fte_total,
       COUNT(*) AS school_count
FROM enrol_db_cleaned;

SELECT * FROM enrolment_totals;

-- We see that there have been a total of 772481.7 full-time-equivalent students enrolled last year in a total of 2174 Schools post 

------------------------------------------------------

-- How many schools have indigenous or LBOTE students?

SELECT 'indigenous students' AS student_group,
        COUNT(*) AS schools_with_student_group,
       (SELECT school_count FROM enrolment_totals) - COUNT(*) AS schools_without_student_group
FROM enrol_db_cleaned
WHERE indigenous_pct != 0
        UNION
SELECT 'LBOTE students' AS student_group,
       COUNT(*) AS schools_with_student_group,
       (SELECT school_count FROM enrolment_totals) - COUNT(*) AS schools_without_student_group
FROM enrol_db_cleaned
WHERE lbote_pct != 0;

--Roughly 2 thirds of all schools in NSW has either indigenous or lbote students attending.

------------------------------------------------------

-- Grouping Schools within 20km Radii buckets from Central Station, Sydney --

SELECT CEILING(distance_from_syd_kms / 20) AS km_radii_within_syd_x20,
       COUNT(distance_from_syd_kms) AS school_count,
       ROUND(AVG(latest_year_enrolment_fte), 2) AS enrolment_fte_ave,
       ROUND(AVG(lbote_pct), 2) AS lbote_pct_ave,
       ROUND(AVG(indigenous_pct), 2) AS indigenous_pct_ave,
       ROUND(AVG(icsea_value), 2) AS icsea_ave,
       ROUND(AVG(foei_value), 2) AS foei_ave,
       ROUND(AVG(school_age), 2) AS school_age_ave
FROM enrol_db_cleaned
GROUP BY 1
ORDER BY 1 ASC;

------------------------------------------------------

-- Enrolment numbers, Percentages and Statistical figures by ASGS remoteness --

SELECT asgs_remoteness,
       COUNT(*) AS school_count,
       SUM(latest_year_enrolment_fte) AS total_enrolment_fte,
       MAX(latest_year_enrolment_fte) AS max_enrolment_cohort_fte,
       MIN(latest_year_enrolment_fte) AS min_enrolment_cohort_fte,
       ROUND(100*(SUM(latest_year_enrolment_fte)/(SELECT enrolment_fte_total FROM enrolment_totals)), 2) AS enrolment_fte_pct,
       ROUND(AVG(latest_year_enrolment_fte), 2) AS enrolment_ave,
       ROUND(STDDEV(latest_year_enrolment_fte), 2) AS enrolment_fte_stddev
FROM enrol_db_cleaned
GROUP BY 1
ORDER BY 2 DESC;

-- We can see that each statistical aggregate results decreases exponentially across the board as we increase remoteness level.


------------------------------------------------------

-- Exploration of Schools within the 'Major Cities of Australia' asgs remoteness index --

DROP TABLE IF EXISTS major_city_schools;
CREATE TABLE major_city_schools AS
       SELECT *
       FROM enrol_db_cleaned
       WHERE asgs_remoteness = 'Major Cities of Australia';

SELECT lga,
       COUNT(*) AS school_count,
       ROUND(AVG(latest_year_enrolment_fte), 2) AS enrolment_fte_ave,
       CASE WHEN COUNT(*) = 1
                THEN 0
            ELSE ROUND(STDDEV(latest_year_enrolment_fte), 2)
       END AS enrolment_fte_stddev,
       MIN(latest_year_enrolment_fte) AS min_enrolment_fte,
       MAX(latest_year_enrolment_fte) AS max_enrolment_fte,
       ROUND(AVG(icsea_value) ,2) AS icsea_ave,
       ROUND(AVG(foei_value), 2) AS foei_ave
FROM major_city_schools
GROUP BY 1
ORDER BY 3 DESC;

-- The top 7 LGA's in terms of fte enrolment figures are Willoughby, North Sydney, The Hills, Camden, Ryde, Fairfield and Hornsby.
-- North Rydney has the fewest schools yet has the lowest standard deviation of fte enrolment figures out of all lga's.
        -- This is a stark contrast to the other LGAS within the top 7, where they all maintain higher standard deviations than all other LGA's below them.
        -- This implies that all schools within the North Sydney LGA are consistently highly-sought-after in terms of enrolment.
-- Willoughby not only has the highest fte enrolment average, by also the highest standard deviation amongst all major city LGA's.
        -- This is also achieved whilst maintaining a very low school count similar to North Sydney.
        -- The distribution of enrolment across all 10 schools in Willoughy must then be extremely skewed. 

------------------------------------------------------

-- Schools by ICSEA difference to the national reported average of 1000--

DROP TABLE IF EXISTS schools_by_icsea;
CREATE TABLE schools_by_icsea AS
SELECT school_code,
       school_name,
       lga,
       asgs_remoteness,
       icsea_value,
       ROUND(icsea_value - 1000, 2) AS icsea_difference_to_mean,
       CASE WHEN (NTILE(5) OVER (ORDER BY ROUND(icsea_value - 1000, 2) DESC)) = 1
                THEN 'Highly Advantaged'
            WHEN (NTILE(5) OVER (ORDER BY ROUND(icsea_value - 1000, 2) DESC)) = 2
                THEN 'Advantaged'
            WHEN (NTILE(5) OVER (ORDER BY ROUND(icsea_value - 1000, 2) DESC)) = 3
                THEN 'Neutral'
            WHEN (NTILE(5) OVER (ORDER BY ROUND(icsea_value - 1000, 2) DESC)) = 4
                THEN 'Disadvantaged'
            ELSE 'Highly Disadvantaged'
            END AS academic_advantage_level
FROM enrol_db_cleaned
WHERE icsea_value != 0
ORDER BY 5 DESC;

SELECT * FROM schools_by_icsea;

SELECT academic_advantage_level,
       STDDEV(icsea_difference_to_mean) AS stddev
FROM schools_by_icsea
GROUP BY 1
ORDER BY ARRAY_POSITION(array['Highly Advantaged', 'Advantaged', 'Neutral', 'Disadvantaged','Highly Disadvantaged'], academic_advantage_level);

-- Higher standard deviation values occur within the more extreme levels of academic advanatage.
        -- This indicates that socio-educational levels of students and poorly distributed amongst the general enrolment populace and may open up further study into why this is so poorly distributed.

