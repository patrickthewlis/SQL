/* Select the Variables to Explore */
SELECT FIRE_NAME as name,
FIRE_YEAR as year,
DISCOVERY_TIME as time_discovered,
STAT_CAUSE_DESCR as cause,
FIRE_SIZE as size,
STATE as state,
OWNER_DESCR as building_owner
FROM `Fires`;

/* GROUP Fires by State, and then ORDER them by Year*/
SELECT MIN(FIRE_YEAR) as min_year,
MAX(FIRE_YEAR) as max_year
FROM `Fires`;

SELECT FIRE_NAME as name,
FIRE_YEAR as year,
DISCOVERY_TIME as time_discovered,
STAT_CAUSE_DESCR as cause,
FIRE_SIZE as size,
STATE as state,
OWNER_DESCR as building_owner
FROM `Fires`
WHERE [FIRE_YEAR] BETWEEN 1992 AND 2015 
GROUP BY STATE, FIRE_YEAR;


/* Number of Fires per Year for Each State */
SELECT	FIRE_YEAR as year,
COUNT(FIRE_YEAR) as num_fires,
STATE as state
FROM `Fires`
GROUP BY STATE, FIRE_YEAR;

/* Year with Highest Number of Fires for Each State (Using SUBQUERY) */
SELECT	year,
state,
MAX(num_fires)
FROM (SELECT FIRE_YEAR as year, STATE as state, COUNT(FIRE_YEAR) as num_fires
FROM `Fires`
GROUP BY FIRE_YEAR,STATE)
GROUP BY state
ORDER BY num_fires DESC;

/* Year with Lowest Number of Fires for Each State (USING SUBQUERY) */
SELECT	year,
state,
MIN(num_fires)
FROM (SELECT FIRE_YEAR as year, STATE as state, COUNT(FIRE_YEAR) as num_fires
FROM `Fires`
GROUP BY FIRE_YEAR,STATE)
GROUP BY state
ORDER BY num_fires DESC;


/* Most Common Cause of Fires for Each State across Years */
SELECT	cause,
state,
MAX(num)
FROM (SELECT STAT_CAUSE_DESCR as cause, STATE as state, COUNT(STAT_CAUSE_DESCR) as num
FROM `Fires`
GROUP BY STAT_CAUSE_DESCR,STATE)
GROUP BY state;

/* Most Infrequent Cause of Fires for Each State across Years */
SELECT	cause,
state,
MIN(num)
FROM (SELECT STAT_CAUSE_DESCR as cause, STATE as state, COUNT(STAT_CAUSE_DESCR) as num
FROM `Fires`
GROUP BY STAT_CAUSE_DESCR,STATE)
GROUP BY state;



/* Average Fire Size of Fires for Each State across Each Year */
SELECT FIRE_YEAR as year,
STATE as state,
AVG(FIRE_SIZE) as size_of_fire
FROM `Fires`
GROUP BY STATE, FIRE_YEAR;


/* Year with Highest Average Size of Fires for Each State (Using SUBQUERY) */
SELECT	year,
state,
MAX(size_of_fire)
FROM (SELECT FIRE_YEAR as year, STATE as state, AVG(FIRE_SIZE) as size_of_fire
FROM `Fires`
GROUP BY FIRE_SIZE,STATE)
GROUP BY state;

/* Top 10 States: Year with Highest Average Size of Fires for Each State (Using SUBQUERY) */
SELECT	year,
state,
MAX(size_of_fire)
FROM (SELECT FIRE_YEAR as year, STATE as state, AVG(FIRE_SIZE) as size_of_fire
FROM `Fires`
GROUP BY FIRE_SIZE,STATE)
GROUP BY state
ORDER BY size_of_fire DESC
LIMIT 10;


/* Tabulate Modal Year with Largest Average Fire Size 
    Is there a specific year in which fires were, on average, larger? 
Across the 23-year period, 6 States had the Largest Average Fire Size in 2011*/ 

SELECT year, COUNT(max_fire) as number
FROM (SELECT year, state, MAX(size_of_fire) as max_fire
FROM (SELECT FIRE_YEAR as year, STATE as state, AVG(FIRE_SIZE) as size_of_fire
FROM `Fires`
GROUP BY FIRE_SIZE,STATE)
GROUP BY state)
GROUP BY year
ORDER BY number DESC;


/* Explore 2011 */

/* 1) Total causes of fire in 2011 (Divide by State) */
SELECT FIRE_YEAR as year, STAT_CAUSE_DESCR as cause, COUNT(STAT_CAUSE_DESCR) as freq_cause, STATE as state
FROM `Fires`
WHERE FIRE_YEAR = 2011
GROUP BY STAT_CAUSE_DESCR,STATE
ORDER BY STATE;

/* 2) Find the most common cause for each state */
SELECT year, cause, MAX(freq_cause), state
FROM (SELECT FIRE_YEAR as year, STAT_CAUSE_DESCR as cause, COUNT(STAT_CAUSE_DESCR) as freq_cause, STATE as state
FROM `Fires`
WHERE FIRE_YEAR = 2011
GROUP BY STAT_CAUSE_DESCR,STATE)
GROUP BY state
ORDER BY state;

/* 3) Tabulate Modal Cause Across States
   In 2011, what was the most frequent cause of fires across all the states */
SELECT cause, COUNT(max_cause) as num_cause
FROM (SELECT year, cause, MAX(freq_cause) as max_cause, state
FROM (SELECT FIRE_YEAR as year, STAT_CAUSE_DESCR as cause, COUNT(STAT_CAUSE_DESCR) as freq_cause, STATE as state
FROM `Fires`
WHERE FIRE_YEAR = 2011
GROUP BY STAT_CAUSE_DESCR,STATE)
GROUP BY state)
GROUP BY cause
ORDER BY num_cause DESC;






/* Do specific agencies report to fires of a specific size? */

/* 1) Create New Variable for Agencies (ALL fires by organization, ordered by year and state) */
SELECT FIRE_YEAR as year, NWCG_REPORTING_AGENCY as reporting_agency, STATE as state,
    FROM (SELECT FIRE_YEAR as year, NWCG_REPORTING_AGENCY as reporting_agency, STATE as state,
                 CASE WHEN NWCG_REPORTING_AGENCY = 'FWS' THEN 'Wildlife Organization'
                      WHEN NWCG_REPORTING_AGENCY = 'DOD' OR 
                           NWCG_REPORTING_AGENCY = 'DOE' OR
                           NWCG_REPORTING_AGENCY = 'BOR' THEN 'Government Department'
                      WHEN NWCG_REPORTING_AGENCY = 'ST/C&L' OR
                           NWCG_REPORTING_AGENCY = 'IA' THEN 'Local Government Department'
                      WHEN NWCG_REPORTING_AGENCY = 'BIA' OR
                           NWCG_REPORTING_AGENCY = 'TRIBE' THEN 'Tribal Organization'
                      ELSE 'Forest/Park Service'
                 END as organization
            FROM `Fires`)
ORDER BY FIRE_YEAR,STATE;


/* 2) Number of Fires Attended By Each Organization per Year Per State */
SELECT organization, COUNT(organization) as freq_orgs, year, state
    FROM (SELECT FIRE_YEAR as year, NWCG_REPORTING_AGENCY as reporting_agency, STATE as state,
                 CASE WHEN NWCG_REPORTING_AGENCY = 'FWS' THEN 'Wildlife Organization'
                      WHEN NWCG_REPORTING_AGENCY = 'DOD' OR 
                           NWCG_REPORTING_AGENCY = 'DOE' OR
                           NWCG_REPORTING_AGENCY = 'BOR' THEN 'Government Department'
                      WHEN NWCG_REPORTING_AGENCY = 'ST/C&L' OR
                           NWCG_REPORTING_AGENCY = 'IA' THEN 'Local Government Department'
                      WHEN NWCG_REPORTING_AGENCY = 'BIA' OR
                           NWCG_REPORTING_AGENCY = 'TRIBE' THEN 'Tribal Organization'
                      ELSE 'Forest/Park Service'
                 END as organization
            FROM `Fires`)
GROUP BY year,state
ORDER BY state,organization;
