                                             
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

-- We see that there have been a total of 772481.7 full-time-equivalent students enrolled last year in a total of 2167 Schools.

------------------------------------------------------

-- How do Indigenous and LBOTE student proportions vary across geographic contexts?

SELECT asgs_remoteness,
       COUNT(*) AS school_count,
       ROUND(AVG(indigenous_pct), 2) AS indigenous_pct_ave,
       ROUND(AVG(lbote_pct), 2) AS lbote_pct_ave,
       ROUND(100 * SUM(latest_year_enrolment_fte * indigenous_pct / 100) / NULLIF(SUM(latest_year_enrolment_fte), 0), 2) AS weighted_indigenous_pct,
       ROUND(100 * SUM(latest_year_enrolment_fte * lbote_pct / 100) / NULLIF(SUM(latest_year_enrolment_fte), 0), 2) AS weighted_lbote_pct
FROM enrol_db_cleaned
GROUP BY 1;

-- Reweighing the percentages over total enrolment fte values allows for a more robust analysis of indigenous and lbote students over the entire student population of each remoteness category.
        -- Schools within major cities have the lowest weighted indigenous enrolment and the highest weighted lbote enrolment percentages at 6.15% and 49.54% respectively.
        -- Weighted lbote percentages are more evenly distributed amongst regional and remote areas of Australia within the range of 7-12%.
        -- Weighted indigenous percentages increase drastically as remotess goes up, with remote and very remote schools reporting percentages of 51.09% and 72.08% respecitvely.
-- Overall, schools in remote areas have very high average of ingigenous student enrolments while major city schools have approximately 50% of their enrolments identifying as lbote.


------------------------------------------------------

-- How does average school enrolment vary across remoteness categories?

SELECT asgs_remoteness,
       COUNT(*) AS school_count,
       ROUND(SUM(latest_year_enrolment_fte), 2) AS total_enrolment,
       ROUND(AVG(latest_year_enrolment_fte), 2) AS ave_enrolment,
       ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY latest_year_enrolment_fte)::NUMERIC, 2) AS enrolment_stddev,
       ROUND(100 * SUM(latest_year_enrolment_fte)/ SUM(SUM(latest_year_enrolment_fte)) OVER (), 2) AS enrolment_share_pct
FROM enrol_db_cleaned
GROUP BY 1
ORDER BY 4 DESC; 

-- The difference in enrolment fte is substantial as schools become more remote.
-- Major city schools average 483.65, with averages halving as we go down the list through regional remoteness.
        -- Very remote schools report approximately 1/10-th of the average enrolment fte than that of major city schools.
-- Therefore school size is strongly associated with remoteness.
-- This presents an opportunity to look into what barriers remote communities face generally and how that may affect enrolment fte such as:
        -- Accessability in terms of geographically
        -- Socio-economic standings of the general population
        -- Population count, and rates of population growth/decline.
        
------------------------------------------------------

-- Do schools in more remote areas serve populations with systematically different socioeconomic profiles?

-- We recall that:
        -- ICSEA values are representative of academic advantage and is strongly correlated to stronger acedemic performances and stronger community-based support.
                -- This value is interpreted by its deviation from the national reported mean of 1000, with low values representing poorer outcomes and higher meaning better outcomes.
        -- FOEI values correlate to the levels of socio, economic and systemic barries that a school faces, and dictates government resource allocation.
                -- Higher values mean higher disadvantage levels while lower values mean less disadvantage.
                
SELECT asgs_remoteness,
       COUNT(*) as school_count,
       ROUND(AVG(icsea_value), 2) AS icsea_ave,
       ROUND(AVG(foei_value), 2) AS foei_ave,
       ROUND(STDDEV(icsea_value), 2) AS icsea_stddev,
       ROUND(STDDEV(foei_value), 2) AS foei_stddev,
       ROUND(AVG(icsea_value) - 1000, 2) AS icsea_diff_from_national_reference,
       COUNT(icsea_value) AS valid_icsea_records,
       COUNT(foei_value) AS valid_foei_records
FROM enrol_db_cleaned
GROUP BY 1
ORDER BY 3 DESC;

-- General observations:
        -- Average ICSEA decreases as remoteness increases.
        -- Average FOEI increases as remoteness increases.
        -- Very remote schools have:
                -- An average ICSEA ~243.54 lower than major city schools.
                -- An average FOEI ~75.14 higher than majore city schools.
-- The 2 seperate socio-economic indicators for schools consistently indicate poorer outcomes for schools as remoteness increases.
-- It is important to note that the very remote category only possesses 15 schools:
        -- The higher standard deviation for both icsea and foei and low sample size decreases validity of generalisations and statistical inference.
        
------------------------------------------------------
        
 -- Does socio-economic disadvantage explain enrolment differences?
        
SELECT ROUND(CORR(latest_year_enrolment_fte, icsea_value)::NUMERIC, 3) AS enrolment_icsea_corr,
       ROUND(CORR(latest_year_enrolment_fte, foei_value)::NUMERIC, 3) AS enrolment_foei_corr,
       ROUND(CORR(latest_year_enrolment_fte, distance_from_syd_kms)::NUMERIC, 3) AS enrolment_distance_corr,
       ROUND(CORR(icsea_value, foei_value)::NUMERIC, 3) AS icsea_foei_corr
FROM enrol_db_cleaned;

-- This suggests that schools with higher enrolment figures possess higher ICSEA values, lower FOEI values and are closer to Sydney CBD.
-- There is a strong negative ICSEA-FOEI correlation value of -0.942.
        -- This may be due to how both of these factors are socio-economic indicators.
        -- Therefore we must treat them as dependent variables.
                -- Treating them as independents increase multicollinearity.
                
-- We need to consider if these correlations are partially affected by geographical factors?
        -- Ie: Do schools have smaller enrolment numbers partly due to their remoteness in addition to general disadvanatge levels?
SELECT asgs_remoteness,
       COUNT(*) AS school_count,
       ROUND(CORR(latest_year_enrolment_fte, icsea_value)::NUMERIC, 3) AS enrolment_icsea_corr,
       ROUND(CORR(latest_year_enrolment_fte, foei_value)::NUMERIC, 3) AS enrolment_foei_corr
FROM enrol_db_cleaned
GROUP BY 1
ORDER BY 1;

-- ICSEA and FOEI correlations differ geatly between each remoteness catagory.
        -- Major city schools possess positive icsea correlations while the rest are ngeative.
        -- Remote and very remote schools possess postive foei correlations while the rest are negative.
-- Since correlations differ across the table, this provides evidence that geographical features also affect ICSEA and FOEI values of schools.

------------------------------------------------------

-- Are socio-economic differences between schools concentrated in particular LGA's?

WITH lga_stats AS (SELECT lga,
                          asgs_remoteness,
                          COUNT(*) AS school_count,
                          ROUND(AVG(icsea_value), 2) AS average_icsea,
                          ROUND(STDDEV(icsea_value), 2) AS icsea_stddev,
                          ROUND(AVG(foei_value), 2) AS average_foei,
                          MAX(icsea_value) - MIN(icsea_value) AS icsea_range
                   FROM enrol_db_cleaned
                   WHERE icsea_value IS NOT NULL
                   GROUP BY 1, 2
                   HAVING COUNT(*) >= 5)
SELECT *,
       DENSE_RANK() OVER (ORDER BY icsea_stddev DESC) AS inequality_rank
FROM lga_stats
ORDER BY 8;

-- The top 5 LGA's with high icsea stanadard deviations are:
        -- Walgett in Remote
        -- Bourke in Very Remote
        -- Wentworth in Outer Regional
        -- Snowy Valleys in Inner Regional
        -- Orange in Inner Regional
-- This means that the students within these LGA's possess substantially differing socio-economic profiles.
-- In addition, the Remote and Very Remote schools are within the top third percentile of inequality.
        -- 2 out of the 3 lgas within these catagories combined rank 1 and 2.
-- The LGA's with the least socio-economic variations are:
        -- Greater Hume in Inner Regional
        -- Burwood in Major Cities
        -- Woollahra in Major Cities
        -- Federation in Inner Regional
        -- Cessnock in Inner Regional

------------------------------------------------------

-- Does the distribution of school types differ systematically between urban and remote NSW?

With school_counts AS (SELECT asgs_remoteness,
                              level_of_schooling,
                              COUNT(*) AS school_count
                       FROM enrol_db_cleaned
                       GROUP BY 1, 2)

SELECT asgs_remoteness,
       level_of_schooling,
       school_count,
       ROUND(100 * school_count / SUM(school_count) OVER (Partition BY asgs_remoteness), 2) AS school_type_pct
FROM school_counts
ORDER BY 1, 2 DESC;

-- Throughout all remoteness categories, Primary Schools possess the highest school counts.
        -- However, they make up for roughly ~70% to ~78% of all schools within urban and regional Australia
        -- Primary school distribution lowers to ~53% and ~65% in remote Australia.
-- Central/Community Schools jump from <2% in Urban and regional Australia to ~23% and 40% in Remote and Very Remote areas respectively.
        -- This may indicate how the greater range of educational provision offered by Central/community schools may generate greater demand for these schools in more remote areas of AUstralia.
        -- For further study into this, we would need to consider:
                -- School travel times
                -- Subject availabilities offered by these schools
                -- Staffing
                -- School capacity.

------------------------------------------------------

-- Do differences in school enrolment and socioeconomic advantage persist when comparing schools of the same type?

WITH school_groups AS (SELECT asgs_remoteness,
                              level_of_schooling,
                              COUNT(*) AS school_count,
                              ROUND(AVG(latest_year_enrolment_fte), 2) AS average_enrolment,
                              ROUND(AVG(icsea_value), 2) AS icsea_ave,
                              ROUND(AVG(foei_value), 2) AS foei_ave,
                              ROUND(CORR(latest_year_enrolment_fte, icsea_value)::NUMERIC, 3) AS enrolment_icsea_corr,
                              ROUND(CORR(latest_year_enrolment_fte, foei_value)::NUMERIC, 3) AS enrolment_foei_corr
                       FROM enrol_db_cleaned
                       GROUP BY 1, 2)
SELECT *
FROM school_groups
WHERE school_count >= 5
ORDER BY 2, 4 DESC;

-- Generally, all major city schools of each type consistently have greater icsea averages and lower foei averages than those in more remote areas.
        -- Correlation values between icsea and foei values to enrolment figures are not consistent when comparing schools of the same level.
        -- There does not seem to be an overall geographical socioeconomic trend when comparing schools of similar types
                -- Therefore differences in the composition of school types cannot solely explain differences in icsea and foei values of schools within different remoteness categories.