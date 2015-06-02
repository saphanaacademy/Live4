--_Hive_DDL_--
-- HIVE DDLs to create Datalake tables in HDP 1.3.
-- Data for 2014 ONLY !!!!!!!
-- Use data in hadoop_data_csv.rar

drop database epa cascade;

create database epa;

create table epa.AQI_DataLake_Text
(
State_Code int,
County_Code int,
Site_Num int,
Parameter_Code int,
POC int,
Latitude decimal,
Longitude decimal,
Datum string,
Parameter_Name string,
Sample_Duration string,
Pollutant_Standard string,
Date_Local string,
Units_of_Measure string,
Event_Type string,
Observation_Count int,
Observation_Percent int,
Arithmetic_Mean int,
1st_Max_Value int,
1st_Max_Hour int,
AQI string,
Method_Name string,
Local_Site_Name string,
Address string,
State_Name string,
County_Name string,
City_Name string,
CBSA_Name string,
Date_of_Last_Change string
) 
row format delimited fields terminated by ',' stored as textfile;

load data local inpath 'C:/Live4_File_DataLakes/AQI2014.csv' into table epa.AQI_DataLake_Text; 

create table epa.Humidity_DataLake_Text
(
State_Code int,
County_Code int,
Site_Num int,
Parameter_Code int,
POC int,
Latitude decimal,
Longitude decimal,
Datum string,
Parameter_Name string,
Sample_Duration string,
Pollutant_Standard string,
Date_Local string,
Units_of_Measure string,
Event_Type string,
Observation_Count int,
Observation_Percent int,
Arithmetic_Mean int,
1st_Max_Value int,
1st_Max_Hour int,
AQI string,
Method_Name string,
Local_Site_Name string,
Address string,
State_Name string,
County_Name string,
City_Name string,
CBSA_Name string,
Date_of_Last_Change string
) 
row format delimited fields terminated by ',' stored as textfile;

load data local inpath 'C:/Live4_File_DataLakes/Humidity2014.csv' into table epa.Humidity_DataLake_Text; 

create table epa.Pressure_DataLake_Text
(
State_Code int,
County_Code int,
Site_Num int,
Parameter_Code int,
POC int,
Latitude decimal,
Longitude decimal,
Datum string,
Parameter_Name string,
Sample_Duration string,
Pollutant_Standard string,
Date_Local string,
Units_of_Measure string,
Event_Type string,
Observation_Count int,
Observation_Percent int,
Arithmetic_Mean int,
1st_Max_Value int,
1st_Max_Hour int,
AQI string,
Method_Name string,
Local_Site_Name string,
Address string,
State_Name string,
County_Name string,
City_Name string,
CBSA_Name string,
Date_of_Last_Change string
) 
row format delimited fields terminated by ',' stored as textfile;

load data local inpath 'C:/Live4_File_DataLakes/Pressure2014.csv' into table epa.Pressure_DataLake_Text; 

create table epa.Temp_DataLake_Text
(
State_Code int,
County_Code int,
Site_Num int,
Parameter_Code int,
POC int,
Latitude decimal,
Longitude decimal,
Datum string,
Parameter_Name string,
Sample_Duration string,
Pollutant_Standard string,
Date_Local string,
Units_of_Measure string,
Event_Type string,
Observation_Count int,
Observation_Percent int,
Arithmetic_Mean int,
1st_Max_Value int,
1st_Max_Hour int,
AQI string,
Method_Name string,
Local_Site_Name string,
Address string,
State_Name string,
County_Name string,
City_Name string,
CBSA_Name string,
Date_of_Last_Change string
) 
row format delimited fields terminated by ',' stored as textfile;

load data local inpath 'C:/Live4_File_DataLakes/Temp2014.csv' into table epa.Temp_DataLake_Text; 

create table epa.Wind_DataLake_Text
(
State_Code int,
County_Code int,
Site_Num int,
Parameter_Code int,
POC int,
Latitude decimal,
Longitude decimal,
Datum string,
Parameter_Name string,
Sample_Duration string,
Pollutant_Standard string,
Date_Local string,
Units_of_Measure string,
Event_Type string,
Observation_Count int,
Observation_Percent int,
Arithmetic_Mean int,
1st_Max_Value int,
1st_Max_Hour int,
AQI string,
Method_Name string,
Local_Site_Name string,
Address string,
State_Name string,
County_Name string,
City_Name string,
CBSA_Name string,
Date_of_Last_Change string
) 
row format delimited fields terminated by ',' stored as textfile;

load data local inpath 'C:/Live4_File_DataLakes/Wind2014.csv' into table epa.Wind_DataLake_Text; 

set hive.exec.dynamic.partition.mode=nonstrict;
set mapred.max.split.size=100000000;
set mapred.min.split.size=1000000;
set hive.execution.engine=tez;
set hive.cbo.enable=true;
set hive.compute.query.using.stats=true;
set hive.stats.fetch.column.stats=true;
set hive.stats.fetch.partition.stats=true;

create table epa.AQI_DataLake
(
State_Code int,
County_Code int,
Site_Num int,
Parameter_Code int,
POC int,
Latitude decimal,
Longitude decimal,
Datum string,
Parameter_Name string,
Sample_Duration string,
Pollutant_Standard string,
Date_Local string,
Units_of_Measure string,
Event_Type string,
Observation_Count int,
Observation_Percent int,
Arithmetic_Mean int,
1st_Max_Value int,
1st_Max_Hour int,
AQI string,
Method_Name string,
Local_Site_Name string,
Address string,
State_Name string,
County_Name string,
City_Name string,
CBSA_Name string,
Date_of_Last_Change string
) 
clustered by (Date_Local)
sorted by (Date_Local)
into 400 buckets
stored as orc tblproperties ("orc.compress"="NONE");

insert overwrite table epa.AQI_DataLake
select * from epa.aqi_datalake_text;

create table epa.Humidity_DataLake
(
State_Code int,
County_Code int,
Site_Num int,
Parameter_Code int,
POC int,
Latitude decimal,
Longitude decimal,
Datum string,
Parameter_Name string,
Sample_Duration string,
Pollutant_Standard string,
Date_Local string,
Units_of_Measure string,
Event_Type string,
Observation_Count int,
Observation_Percent int,
Arithmetic_Mean int,
1st_Max_Value int,
1st_Max_Hour int,
AQI string,
Method_Name string,
Local_Site_Name string,
Address string,
State_Name string,
County_Name string,
City_Name string,
CBSA_Name string,
Date_of_Last_Change string
) 
clustered by (Date_Local)
sorted by (Date_Local)
into 400 buckets
stored as orc tblproperties ("orc.compress"="NONE");

insert overwrite table epa.Humidity_DataLake
select * from epa.humidity_datalake_text;

create table epa.Pressure_DataLake
(
State_Code int,
County_Code int,
Site_Num int,
Parameter_Code int,
POC int,
Latitude decimal,
Longitude decimal,
Datum string,
Parameter_Name string,
Sample_Duration string,
Pollutant_Standard string,
Date_Local string,
Units_of_Measure string,
Event_Type string,
Observation_Count int,
Observation_Percent int,
Arithmetic_Mean int,
1st_Max_Value int,
1st_Max_Hour int,
AQI string,
Method_Name string,
Local_Site_Name string,
Address string,
State_Name string,
County_Name string,
City_Name string,
CBSA_Name string,
Date_of_Last_Change string
) 
clustered by (Date_Local)
sorted by (Date_Local)
into 400 buckets
stored as orc tblproperties ("orc.compress"="NONE");

insert overwrite table epa.Pressure_DataLake
select * from epa.pressure_datalake_text;

create table epa.Temp_DataLake
(
State_Code int,
County_Code int,
Site_Num int,
Parameter_Code int,
POC int,
Latitude decimal,
Longitude decimal,
Datum string,
Parameter_Name string,
Sample_Duration string,
Pollutant_Standard string,
Date_Local string,
Units_of_Measure string,
Event_Type string,
Observation_Count int,
Observation_Percent int,
Arithmetic_Mean int,
1st_Max_Value int,
1st_Max_Hour int,
AQI string,
Method_Name string,
Local_Site_Name string,
Address string,
State_Name string,
County_Name string,
City_Name string,
CBSA_Name string,
Date_of_Last_Change string
) 
clustered by (Date_Local)
sorted by (Date_Local)
into 400 buckets
stored as orc tblproperties ("orc.compress"="NONE");

insert overwrite table epa.Temp_DataLake
select * from epa.temp_datalake_text;

create table epa.Wind_DataLake
(
State_Code int,
County_Code int,
Site_Num int,
Parameter_Code int,
POC int,
Latitude decimal,
Longitude decimal,
Datum string,
Parameter_Name string,
Sample_Duration string,
Pollutant_Standard string,
Date_Local string,
Units_of_Measure string,
Event_Type string,
Observation_Count int,
Observation_Percent int,
Arithmetic_Mean int,
1st_Max_Value int,
1st_Max_Hour int,
AQI string,
Method_Name string,
Local_Site_Name string,
Address string,
State_Name string,
County_Name string,
City_Name string,
CBSA_Name string,
Date_of_Last_Change string
)
clustered by (Date_Local)
sorted by (Date_Local)
into 400 buckets
stored as orc tblproperties ("orc.compress"="NONE");

insert overwrite table epa.Wind_DataLake
select * from epa.wind_datalake_text;

drop table epa.AQI_DataLake_Text;
drop table epa.Humidity_DataLake_Text;
drop table epa.Pressure_DataLake_Text;
drop table epa.Temp_DataLake_Text;
drop table epa.Wind_DataLake_Text;

show tables in epa;
