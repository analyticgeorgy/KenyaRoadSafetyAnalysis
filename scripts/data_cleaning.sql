/*
Data Cleaning Script
Script Purpose :
This script inspects, cleans, normalizes and standardizes our data.
Here are some of the tasks done in it:
- Creating a cleaned working table
- Detecting and removing duplicate records
- Validating nulls and blank strings
- Standardizing categorical text fields
- Creating a surrogate key (Accident_ID)
- Engineering analytical features such as Month_Name, Day_Type, Time_Category, and Peak_Hour_Flag
- Converting and validating date/time data types for downstream analytics and Power BI reporting
*/

--Inspect the raw data
SELECT TOP 20 *
FROM raw_data.Road_Accident_Data

--Check the column data types
EXEC sp_help 'raw_data.Road_Accident_Data'

--Lets create the cleaned table and here is where we will do the data cleaning
SELECT
*
INTO cleaned_data.Road_Accident_Data
FROM raw_data.Road_Accident_Data

--Check for duplicate records i.e check if the Accident Index column is a unique identifier
SELECT
Accident_Index,
COUNT(*) AS Duplicate_count
FROM cleaned_data.Road_Accident_Data
GROUP BY Accident_Index
HAVING COUNT(*) > 1

--We see that the Accident_Index column has duplicates so it can no longer be trusted as a primary key
--This means we should resort to full-record deduplication instead of relying only on the Accident_Index
--which is also is duplicated i.e we will need to rely on all the columns to identify unique records

--Below is how we check for duplicates in the full record/all columns
WITH duplicate_check AS(
	SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY
	Accident_Index,
	[Accident Date],
	[Month],
	Day_of_Week,
	[Year],
	Junction_Control,
	Junction_Detail,
	Accident_Severity,
	Latitude,
	Light_Conditions,
	[Local_Authority_(District)],
	Carriageway_Hazards,
	Longitude,
	Number_of_Casualties,
	Number_of_Vehicles,
	Police_Force,
	Road_Surface_Conditions,
	Road_Type,
	Speed_limit,
	[Time],
	Urban_or_Rural_Area,
	Weather_Conditions,
	Vehicle_Type
	ORDER BY (SELECT NULL)
	) AS rn
	FROM cleaned_data.Road_Accident_Data
)
SELECT 
COUNT(*) AS duplicate_rows
FROM duplicate_check
WHERE rn > 1

--Inspect the corrupted Accident_Index column
SELECT DISTINCT Accident_Index
FROM cleaned_data.Road_Accident_Data
WHERE Accident_Index LIKE '%E+%'

--Remove the true duplicate row
WITH duplicate_check AS 
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY
Accident_Index,
[Accident Date],
[Month],
Day_of_Week,
[Year],
Junction_Control,
Junction_Detail,
Accident_Severity,
Latitude,
Light_Conditions,
[Local_Authority_(District)],
Carriageway_Hazards,
Longitude,
Number_of_Casualties,
Number_of_Vehicles,
Police_Force,
Road_Surface_Conditions,
Road_Type,
Speed_limit,
[Time],
Urban_or_Rural_Area,
Weather_Conditions,
Vehicle_Type
ORDER BY (SELECT NULL)
) AS rn
FROM cleaned_data.Road_Accident_Data
)
DELETE
FROM duplicate_check
WHERE rn > 1

--Null Value Analysis
SELECT
SUM(CASE WHEN Accident_Index IS NULL THEN 1 ELSE 0 END) AS Accident_Nulls,
SUM(CASE WHEN [Accident Date] IS NULL THEN 1 ELSE 0 END) AS Accident_Date_Nulls,
SUM(CASE WHEN [Month] IS NULL THEN 1 ELSE 0 END) AS Month_Nulls,
SUM(CASE WHEN Day_of_Week IS NULL THEN 1 ELSE 0 END) AS Day_of_Week_Nulls,
SUM(CASE WHEN Accident_Severity IS NULL THEN 1 ELSE 0 END) AS Accident_Severity_Nulls,
SUM(CASE WHEN Latitude IS NULL THEN 1 ELSE 0 END) AS Latitude_Nulls,
SUM(CASE WHEN Longitude IS NULL THEN 1 ELSE 0 END) AS Longitude_Nulls,
SUM(CASE WHEN Number_of_Casualties IS NULL THEN 1 ELSE 0 END) AS Casualties_Nulls,
SUM(CASE WHEN Number_of_Vehicles IS NULL THEN 1 ELSE 0 END) AS Vehicles_Nulls,
SUM(CASE WHEN Weather_Conditions IS NULL THEN 1 ELSE 0 END) AS Weather_Nulls,
SUM(CASE WHEN Vehicle_Type IS NULL THEN 1 ELSE 0 END) AS Vehicle_Type_Nulls
FROM cleaned_data.Road_Accident_Data

--Since the Accident_Index column is not unique we will have to create our own surrogate key which will be
--used in situations like SQL joins, power bi data modelling
ALTER TABLE cleaned_data.Road_Accident_Data
ADD Accident_ID INT IDENTITY(1,1)

--Check for blank strings
SELECT
SUM(CASE WHEN TRIM(Weather_Conditions) = '' THEN 1 ELSE 0 END) AS Weather_Blanks,
SUM(CASE WHEN TRIM(Road_Surface_Conditions) = '' THEN 1 ELSE 0 END) AS Road_Conditions_Blanks,
SUM(CASE WHEN TRIM(Vehicle_Type) = '' THEN 1 ELSE 0 END) AS Vehicle_Type_Blanks,
SUM(CASE WHEN TRIM(Light_Conditions) = '' THEN 1 ELSE 0 END) AS Light_Conditions_Blanks
FROM cleaned_data.Road_Accident_Data

--Standardize Text columns i.e cleaning the inconsistent spacing
UPDATE cleaned_data.Road_Accident_Data
SET
Junction_Control = TRIM(Junction_Control),
Junction_Detail = TRIM(Junction_Detail),
Accident_Severity = TRIM(Accident_Severity),
Light_Conditions = TRIM(Light_Conditions),
Carriageway_Hazards = TRIM(Carriageway_Hazards),
Road_Surface_Conditions = TRIM(Road_Surface_Conditions),
Road_Type = TRIM(Road_Type),
Weather_Conditions = TRIM(Weather_Conditions),
Vehicle_Type = TRIM(Vehicle_Type)

--Inspect the categorical columns consistency
SELECT
DISTINCT Accident_Severity
FROM cleaned_data.Road_Accident_Data
ORDER BY 1

SELECT
DISTINCT Weather_Conditions
FROM cleaned_data.Road_Accident_Data
ORDER BY 1

SELECT
DISTINCT Road_Surface_Conditions
FROM cleaned_data.Road_Accident_Data
ORDER BY 1

SELECT
DISTINCT Vehicle_Type
FROM cleaned_data.Road_Accident_Data
ORDER BY 1

--Handling Blank String Categories
UPDATE cleaned_data.Road_Accident_Data
SET Weather_Conditions = 'Unknown'
WHERE Weather_Conditions = ''

UPDATE cleaned_data.Road_Accident_Data
SET Road_Surface_Conditions = 'Unknown'
WHERE Road_Surface_Conditions = ''

--Data Type Validation, verify whether critical analytical columns are proper data types
SELECT
COLUMN_NAME,
DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'cleaned_data'
AND TABLE_NAME = 'Road_Accident_Data'
AND COLUMN_NAME IN ('Accident Date', 'Latitude', 'Longitude', 'Number_of_Casualties', 'Number_of_Vehicles', 'Speed_limit', 'Time')

--Begin Feature Engineering, this is where our dataset becomes more analytical
--Create month name column
ALTER TABLE cleaned_data.Road_Accident_Data
ADD Month_Name NVARCHAR(20);

UPDATE cleaned_data.Road_Accident_Data
SET Month_Name = DATENAME(month, [Accident Date])

--Create Weekday vs Weekend columns
ALTER TABLE cleaned_data.Road_Accident_Data
ADD Day_Type NVARCHAR(10);

UPDATE cleaned_data.Road_Accident_Data
SET Day_Type = 
CASE WHEN Day_of_Week IN ('Saturday', 'Sunday') THEN 'Weekend'
ELSE 'Weekday'
END;

--Create Time Category column, we now categorize accidents by time of day
ALTER TABLE cleaned_data.Road_Accident_Data
ADD Time_Category NVARCHAR(10);

UPDATE cleaned_data.Road_Accident_Data
SET Time_Category = 
CASE 
WHEN CAST([Time] AS TIME) BETWEEN '05:00:00' AND '11:59:00' THEN 'Morning'
WHEN CAST([Time] AS TIME) BETWEEN '12:00:00' AND '16:59:00' THEN 'Afternoon'
WHEN CAST([Time] AS TIME) BETWEEN '17:00:00' AND '20:59:00' THEN 'Evening'
ELSE 'Night'
END;

--Create Peak Hour flag, Peak here means traditional commuter hour rush
ALTER TABLE cleaned_data.Road_Accident_Data
ADD Peak_Hour_Flag NVARCHAR(10)

UPDATE cleaned_data.Road_Accident_Data
SET Peak_Hour_Flag = 
CASE 
WHEN CAST([Time] AS Time) BETWEEN '07:00:00' AND '09:00:00' OR
CAST([Time] AS Time) BETWEEN '17:00:00' AND '20:00:00' THEN 'Peak'
ELSE 'Non-Peak'
END;


--Now create cleaned Accident Date and Time columns
ALTER TABLE cleaned_data.Road_Accident_Data
ADD Accident_Date_Cleaned DATE

UPDATE cleaned_data.Road_Accident_Data
SET Accident_Date_Cleaned = TRY_CONVERT(DATE, [Accident Date], 101)

--Validate failed DATE conversions
SELECT Accident_Date_Cleaned
FROM cleaned_data.Road_Accident_Data
WHERE Accident_Date_Cleaned IS NULL  --no rows returned, no failed conversions

ALTER TABLE cleaned_data.Road_Accident_Data
ADD Time_Cleaned TIME

UPDATE cleaned_data.Road_Accident_Data
SET Time_Cleaned = TRY_CONVERT(TIME, [Time])

--Validate Failed Time conversions
SELECT Time_Cleaned
FROM cleaned_data.Road_Accident_Data
WHERE Time_Cleaned IS NULL --no rows returned, no failed Time Conversions



