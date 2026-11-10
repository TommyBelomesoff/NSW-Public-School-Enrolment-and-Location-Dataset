# Geographical and Socioeconomic Inequality in NSW Public Schools🏫

The database used was the **_Master dataset: NSW government school locations and student enrolment numbers_** extracted on 04/09/2026 and can be accessed [here](https://data.nsw.gov.au/data/dataset/nsw-education-nsw-public-schools-master-dataset). This dataset records information regarding all primary and secondary levels of educational facilities within New South Wales of Australia.
Along with the master database, the master database dictionary is also accessible with the same link and contains extra information regarding each column and their meanings. In addition, a list data-related notes are highlighted on associated webpage, and were considered during analysis.


## Aim of this project 🎯
- Explore how Socioeconomic and Geographical factors affect school enrolment.
- Practice and showcase PostgreSQL skills such as:
  - Data cleaning, table creation and manipulation.
  - Aggregation and Logical operation usage.
  - Subqueries, Recursive and Window functions.
  - Advanced Join techniques such as UNION and SELF JOIN's.

## Files 📁
- SQL CODE file
  - **_Database_Upload.sql_** contains the read-in code for the raw database.
  - **_Data_Cleaning.sql_** is the cleaning, trimming and data type converting into an easy to maipulate form.
  - **_[Descriptive_Analysis.sql](https://github.com/TommyBelomesoff/NSW-Public-School-Enrolment-and-Location-Dataset/blob/main/SQL%20code/Descriptive_Analysis.sql)_** contains the qualitative exploration and summarisation of the data.

## Limitations 🔒
- The free version of DBVisualizer was used, therefore features exclusive to the Pro version were unavailable. 
  - Importing the original database was done by using [Query Planes' CSV to SQL Converter](https://queryplane.com/tools/csv-to-sql/postgresql/) which produced the table creation code.

## Analysis Overview 🔍
- Data set review post cleaning using basic SUM and COUNT aggregation.
- Indigenous and LBOTE proportional distribution using reweighting strategies for robustness.
- Average school enrolment variance over ASGS remoteness.
  - Identified further research opportunity into barriers introduced by increased remoteness and how that may further affect enrolment.
- Explored how remoteness affects socioeconomic factors (_ICSEA and FOEI values_) using standard deviation aggregation.
- Identified if socioeconomic differences affect enrolment figures via correlation coefficients.
  - Outlined how ICSEA and FOEI factors need to be treated independently to each other to prevent multicolinearity.
  - Identified if these correlation coefficients are also affected by geographical factors.
- Explored socioeconomic differences and standard deviations within LGAS.
- Identified the differences in school type distribution between ASGS remoteness categories.
  - Presented further research opportunities regarding enrolment numbers not included within the dataset.
- Performed sample matching with schools of the same type, allowing for a more robust enrolment and socioeconomic comparisons to be made.

## Improvements and Further Research Opportunities 🌱
- Joining this dataset with additional supporting datasets would allow for a more in depth exploration.
  - Such datasets may include:
     - School specifications such as enrolment capacity, subject availability, staffing and average transport times for enrolled students.
     - FOEI and ICSEA datasets containing factors that affect these respective values.
- My creating a map to convert categorical factors into a finite numerical values, we may export the cleaned database and perform simple linear regression.
