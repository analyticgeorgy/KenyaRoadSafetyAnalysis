/*

*/

--Exploratory Data Analysis(EDA)
--Our objective in this EDA is to answer 
--WHAT PATTERNS CONTRIBUTE MOST TO ROAD ACCIDENTS AND ACCIDENTS SEVERITY

--EDA 1 : The number of Total Accidents
SELECT
COUNT(*) AS TotalCount
FROM cleaned_data.Road_Accident_Data

--EDA 2 : Accident Severity Distribution
--Which severity category dominates the dataset?
SELECT
Accident_Severity,
COUNT(*) AS TotalAccidents,
ROUND(COUNT(*) * 100/ SUM(COUNT(*)) OVER(),2) AS Percentage
FROM cleaned_data.Road_Accident_Data
GROUP BY Accident_Severity
ORDER BY TotalAccidents DESC;

--EDA 3 : Accidents By Year
SELECT
Year,
COUNT(*) AS TotalAccidents
FROM cleaned_data.Road_Accident_Data
GROUP BY Year
ORDER BY TotalAccidents DESC;

--EDA 4 : Accidents By Month
SELECT
Month_Name,
COUNT(*) AS TotalAccidents
FROM cleaned_data.Road_Accident_Data
GROUP BY Month_Name
ORDER BY TotalAccidents DESC;

--EDA 5 : Accidents By Day of Week
SELECT
Day_Of_Week,
COUNT(*) AS TotalAccidents
FROM cleaned_data.Road_Accident_Data
GROUP BY Day_Of_Week
ORDER BY TotalAccidents DESC;

--EDA 6 : Weekday vs Weekend
SELECT
Day_Type,
COUNT(*) TotalAccidents
FROM cleaned_data.Road_Accident_Data
GROUP BY Day_Type
ORDER BY TotalAccidents DESC;

--EDA 7 : Time Category Analysis
SELECT
Time_Category,
COUNT(*) TotalAccidents
FROM cleaned_data.Road_Accident_Data
GROUP BY Time_Category
ORDER BY TotalAccidents DESC;

--EDA 8 : Peak Hour VS Non-Peak Analysis i.e do rush hours contribute disproportionately to accidents?
SELECT 
Peak_Hour_Flag,
COUNT(*) TotalAccidents
FROM cleaned_data.Road_Accident_Data
GROUP BY Peak_Hour_Flag
ORDER BY TotalAccidents DESC;

--EDA 9 : Weather Condition Analysis
SELECT
Weather_Conditions,
COUNT(*) TotalAccidents
FROM cleaned_data.Road_Accident_Data
GROUP BY Weather_Conditions
ORDER BY TotalAccidents DESC;

--EDA 10 : Road Surface Analysis
SELECT
Road_Surface_Conditions,
COUNT(*) TotalAccidents
FROM cleaned_data.Road_Accident_Data
GROUP BY Road_Surface_Conditions
ORDER BY TotalAccidents DESC;

--EDA 11 : Light Condition Analysis
SELECT
Light_Conditions,
COUNT(*) TotalAccidents
FROM cleaned_data.Road_Accident_Data
GROUP BY Light_Conditions
ORDER BY TotalAccidents DESC;

--EDA 12 : Vehicle Type Involvement
SELECT
Vehicle_Type,
COUNT(*) TotalAccidents
FROM cleaned_data.Road_Accident_Data
GROUP BY Vehicle_Type
ORDER BY TotalAccidents DESC;

--Now lets combine more than one dimensions making our analysis more advanced
--EDA 13 : Severity VS Weather
SELECT
Accident_Severity,
Weather_Conditions,
COUNT(*) TotalAccidents
FROM cleaned_data.Road_Accident_Data
GROUP BY Accident_Severity,Weather_Conditions
ORDER BY TotalAccidents DESC;

--EDA 14 : Severity VS Road Surface Conditions
SELECT
Accident_Severity,
Road_Surface_Conditions,
COUNT(*) TotalAccidents
FROM cleaned_data.Road_Accident_Data
GROUP BY Accident_Severity, Road_Surface_Conditions
ORDER BY TotalAccidents DESC;

--EDA 15 : Severity VS Vehicle Type
SELECT
Accident_Severity,
Vehicle_Type,
COUNT(*) TotalAccidents
FROM cleaned_data.Road_Accident_Data
GROUP BY Accident_Severity, Vehicle_Type
ORDER BY TotalAccidents DESC;
