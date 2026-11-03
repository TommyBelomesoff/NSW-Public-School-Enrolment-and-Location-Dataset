# Geographical and Socioeconomic Inequality in NSW Public Schools🏫

The database used was the **_Master dataset: NSW government school locations and student enrolment numbers_** extracted on 04/09/2026 and can be accessed [here](https://data.nsw.gov.au/data/dataset/nsw-education-nsw-public-schools-master-dataset). This dataset records information regarding all primary and secondary levels of educational facilities within New South Wales of Australia.
Along with the master database, the master database dictionary is also accessible with the same link and contains extra information regarding each column and their meanings.


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
  - **_[Descriptive_Analysis.sql](https://github.com/TommyBelomesoff/NSW-Public-School-Enrolment-and-Location-Dataset/blob/main/SQL%20code/Descriptive_Analysis.sql)_** contains the quantitative exploration of the data.

## Limitations 🔒
- The free version of DBVisualizer was used, therefore features exclusive to the Pro version were unavailable. 
  - Importing the original database was done by using [Query Planes' CSV to SQL Converter](https://queryplane.com/tools/csv-to-sql/postgresql/) which produced the table creation code.

# Additional notes regarding this database
- Schools that fall out of the scope of the *NSSC* will not have enrolment figures. Relevant facilities may include alternative or institutional schools such as TAFE and Home School scenarios.
- Schools with indigenous or Language-Backgrounds-other-than-English (*LBOTE*) student enrolment percentages equal to or less than 5 are suppressed and will have the respective data recorded as '*np*'.
- Enrolment figures for schools providing part-time study will have such cases measured in relation to '*full-time equivalent*' units. Students studying less than 10 units will have their respective enrolment number recorded as; 0.1 x (*number of units studying*)
- Due to data extraction and upload frequency, _FOEI_ and _ICSEA_ values are representative of previous years scores.
- _ICSEA_ values are representative of the academic advantage enrolled students possess from community-based influences such as voluntary parent contributions, non-government funding support networks and other community resources. Higher ICSEA levels are indicative of higher student advantage levels, in addition to stronger academic performances from students.
- _FOEI_ values are a measure of socio-educational advantage based on educational and occupational positions of parents, and is used for dictating government resource distribution to schools. Higher _FOEI_ values correlate to larger socio, economic and systemic barriers that a school community faces.
