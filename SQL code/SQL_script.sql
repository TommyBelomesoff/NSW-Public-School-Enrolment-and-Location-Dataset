                                             
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

-- We see that there have been a total of 772481.7 full-time-equivalent students enrolled last year in a total of 2174 Schools.

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
   -- Therefore, remoteness does have a large effect on enrolment numbers in a very broad sense.
   -- This opens up further potential study into what factors carry influence over areas in differing remoteness categories such as:
        -- Ability to choose education facility.
        -- Acessibility levels to general goods and services.
        -- Socio-economic standing of families.
        -- Population numbers such as rates of growth/decline.
        
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
        -- The distribution of enrolment across all 10 schools in Willoughy is extremely skewed. 
  
-- The accessibility of each school geospatially and socio-economically should be considered when analysing the enrolment fte distributions here.
        -- The higher density of schools within the 'Major Cities of Australia' remoteness level will provide families with more options for enrolment.
                -- This may cause increased variation in enrolment figures between LGA's within this remoteness category.

------------------------------------------------------

-- Schools by ICSEA difference to the national reported average of 1000--

DROP TABLE IF EXISTS schools_by_icsea;
CREATE TABLE schools_by_icsea AS
SELECT school_code,
       school_name,
       selective_school,
       latest_year_enrolment_fte,
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
ORDER BY 7 DESC;

SELECT * FROM schools_by_icsea;

SELECT academic_advantage_level,
       STDDEV(icsea_difference_to_mean) AS stddev
FROM schools_by_icsea
GROUP BY 1
ORDER BY ARRAY_POSITION(array['Highly Advantaged', 'Advantaged', 'Neutral', 'Disadvantaged','Highly Disadvantaged'], academic_advantage_level);

-- ICSEA values generally decrease in areas as remoteness levels increase, supporting an earlier descriptive analysis.
        -- The top 9 highest ICSEA value schools are fully selective schools, which coincides with the strong correlation between ICSEA values and academic performance.
-- Higher standard deviation values occur within the more extreme levels of academic advanatage.
        -- This indicates that socio-educational levels of students and poorly distributed amongst the general enrolment populace.
        -- Opens up further study opportunities into why this is so poorly distributed within quantiles.
                -- Selectivity of schools may contribute to the higher standard deviation within the first quantile.
                
------------------------------------------------------

-- FOEI values based on LGA and Remoteness

SELECT lga,
       asgs_remoteness,
       ROUND(AVG(foei_value), 2) AS foei_ave
FROM enrol_db_cleaned
GROUP BY 1, 2
ORDER BY 3 DESC;

--- LGA rankings based off average FOEI values closely resemble the inverse ranking of LGAS by ICSEA values.
        -- This makes sense as the FOEI scale equates lower values with lower levels of socio, economic and systemic barriers.
-- Lets focus on the 5 LGA's with the highest FOEI values.

SELECT *
FROM enrol_db_cleaned
WHERE lga IN ('Coonamble', 'Brewarrina', 'Moree Plains', 'Kyogle', 'Central Darling')
ORDER BY foei_value DESC;
       
-- Some immediate trends can be identified within the top 10 schools. Most schools within the highest 10 FOEI values:
        -- Are Central/Community Schools
        -- Possess extremely high indigenous fte percentage
        -- Are within the 600-700 ICSEA value range, within the Highly Disadvantaged academic level.

------------------------------------------------------

-- Enrolment figures based on school-subtype and level_of_schooling

SELECT school_subtype,
       level_of_schooling,
       COUNT(school_subtype) AS subtype_count,
       ROUND(AVG(latest_year_enrolment_fte), 2) AS enrolment_ave
FROM enrol_db_cleaned
GROUP BY 1, 2
ORDER BY 3 DESC;

-- The most common School subtypes are K-6, 7-12, Pre-6, Med-High support and K-12.
-- The schools with the highest enrolment averages are 7-12, 7-10, 11-12 and 10-12.
   -- There seems to be a high enrolment average for secondary schools.
-- Whats interesting is the extremely high Primary school count, yet their enrolment_ave is above the median of all enrolment averages.

-- How are the top 5 most common school subtypes distributed within each asgs_remoteness category.

SELECT asgs_remoteness,
       COUNT(*) FILTER (WHERE school_subtype = 'Kindergarten to Year 6') AS k_6_Count,
       COUNT(*) FILTER (WHERE school_subtype = 'Year 7 to Year 12') AS y7_12_Count,
       COUNT(*) FILTER (WHERE school_subtype = 'Preschool to Year 6') AS Pre_6_Count,
       COUNT(*) FILTER (WHERE school_subtype = 'Medium / High Support needs') AS MH_supp_Count,
       COUNT(*) FILTER (WHERE school_subtype = 'Kindergarten to Year 12') AS k_12_Count
FROM enrol_db_cleaned
GROUP BY 1
ORDER BY ARRAY_POSITION(array['Major Cities of Australia', 'Inner Regional Australia', 'Outer Regional Australia', 'Remote Australia', 'Very Remote Australia'], asgs_remoteness);

-- The distribution of each school subtype largely matches their order in terms of total count.
-- However, Kindergarten to Year 12 schools take up a larger proportion of schools in Outer regional and more remote areas.
        -- This may indicate the value of educational facilities in remote areas of Australia, where accessability and educational coverage are seen as more influential on enrolment. 
------------------------------
