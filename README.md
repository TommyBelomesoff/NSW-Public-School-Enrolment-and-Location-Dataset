# (WIP) Qualitative Exploration of the '_NSW Government School Locations and Enrolment Numbers_' Database 🏫

This database houses information regarding all primary and secondary levels of educational facilities within New South Wales of Australia.
Along with the master database, the master database dictionary is also accessible and contains extra information regarding each column and their meanings.

The data contained in this database was extracted on 04/09/2026 and can be accessed [here](https://data.nsw.gov.au/data/dataset/nsw-education-nsw-public-schools-master-dataset).

Additional data notes regarding this database include:
- Schools that fall out of the scope of the *NSSC* will not have enrolment figures. Relevant facilities may include alternative or institutional schools such as TAFE and Home School scenarios.
- Schools with indigenous or Language-Backgrounds-other-than-English (*LBOTE*) student enrolment percentages equal to or less than 5 are suppressed and will have the respective data recorded as '*np*'.
- Enrolment figures for schools providing part-time study will have such cases measured in relation to '*full-time equivalent*' units. Students studying less than 10 units will have their respective enrolment number recorded as; 0.1 x (*number of units studying*)
- Due to data extraction and upload frequency, _FOEI_ and _ICSEA_ values are representative of previous years scores.

## Aim of this project 🎯
- Explore the key characteristics affecting school enrolment figures.
- Identify key trends amongst schools with high FOEI, ICSEA and enrolment fte numbers.
- Practice and showcase PostgreSQL skills such as:
  - Data cleaning, table creation and manipulation.
  - Aggregation and Logical operation usage.
  - Subqueries, Recursive and Window functions.
  - Advanced Join techniques such as UNION and SELF JOIN's.
  - Data preparation for further analysis in RStudio.
  
## Limitations 🔒
- The free version of DBVisualizer was used, therefore features exclusive to the Pro version were unavailable. 
  - Importing the original database was done by using [Query Planes' CSV to SQL Converter](https://queryplane.com/tools/csv-to-sql/postgresql/) which produced the table creation code.
