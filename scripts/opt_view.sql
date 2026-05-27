/*
Now we need to create a clean reporting layer for Power BI which is going be a SQL View
We have chosen a view as the reporting layer because:
1.Power BI stays connected to a table structure.
2.Cleaning logic remains centralized i.e if you need to modify anything you do it to the view not the actual physical table.
3.It avoids exposing raw tables directly.
*/

CREATE VIEW cleaned_data.vw_road_safety_analysis AS
SELECT
Accident_ID,
Accident_Index,
Accident_Date_Cleaned,
[Year],
Month_Name,
Day_of_Week AS Day_Of_Week,
Day_Type,
Time_Cleaned,
Time_Category,
Peak_Hour_Flag,
Accident_Severity,
Weather_Conditions,
Road_Surface_Conditions,
Light_Conditions,
Vehicle_Type,
Speed_limit AS Speed_Limit,
Urban_or_Rural_Area AS Urban_Or_Rural,
Number_of_Casualties AS Number_Of_Casualties,
Number_of_Vehicles AS Number_Of_Vehicles,
Latitude,
Longitude
FROM cleaned_data.Road_Accident_Data;
