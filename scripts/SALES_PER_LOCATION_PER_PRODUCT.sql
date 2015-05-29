-- run this as LIVE4 user to create the T001W_WS table
-- this view is used gather product sales from a store by date also showing the weather readings for that date
-- this data will in turn be used with Predictive Analysis

CREATE VIEW LIVE4.SALES_PER_LOCATION_PER_PRODUCT AS 
SELECT
 ROW_NUMBER() OVER (ORDER BY MANDT, ERDAT, VBAP.WERKS, MATNR) as ROW_NUM,
 TW.MANDT,
 VBAP.ERDAT,
 VBAP.WERKS,
 VBAP.MATNR,
 VBAP.QUANTITY,
 VBAP.SALES_TOTAL, 
 DLA.AQI,
 CEILING(DLA.AQI/50) AS AQI_RANGE,
 MAP(CEILING(DLA.AQI/50),  1, 'Good', 2, 'Moderate', 3, 'Unhealthy for Sensitive Groups', 4, 'Unhealthy', 5, 'Very Unhealthy', 'Hazardous') LEVEL_OHC,
 MAP(CEILING(DLA.AQI/50),  1, 'Green', 2, 'Yellow', 3, 'Orange', 4, 'Red', 5, 'Purple', 'Maroon') COLOUR,
 DLT.TMP,
 DLH.HUM
FROM 
 LIVE4.T001W_WS TW,
 (
 	SELECT
	 TO_DATE(ERDAT,'yyyymmdd') as ERDAT,
	 VBAP.WERKS,
	 MATNR,
	 SUM(KWMENG) as QUANTITY,
	 TO_DECIMAL(SUM(KWMENG * NETWR), 10, 0) as SALES_TOTAL 
	FROM 
	 LIVE4.VBAP
	GROUP BY 
	 ERDAT,
	 VBAP.WERKS,
	 MATNR 
 ) VBAP,
 (
	SELECT 
	 "aqi" AS AQI,
	 "date_local" AS DATELOCAL,
	 10000000 * "state_code" + 10000 * "county_code" + "site_num" AS SITENUM
	FROM LIVE4."DataLake_AQI"
 ) DLA,
 (
	SELECT 
	 "1st_max_value" AS TMP,
	 "date_local" AS DATELOCAL,
	 10000000 * "state_code" + 10000 * "county_code" + "site_num" AS SITENUM
	FROM LIVE4."DataLake_Temperature"
 ) DLT,
 (
	SELECT 
	 "1st_max_value" AS HUM,
	 "date_local" AS DATELOCAL,
	 10000000 * "state_code" + 10000 * "county_code" + "site_num" AS SITENUM
	FROM LIVE4."DataLake_Humidity"
 ) DLH

WHERE  	
 TW.WERKS = VBAP.WERKS AND 
 DLA.DATELOCAL = VBAP.ERDAT AND
 DLA.SITENUM = TW.WS_AQI_SITENUM AND
 DLT.DATELOCAL = VBAP.ERDAT AND
 DLT.SITENUM = TW.WS_TMP_SITENUM AND
 DLH.DATELOCAL = VBAP.ERDAT AND
 DLH.SITENUM = TW.WS_HUM_SITENUM 
 
ORDER BY
 TW.MANDT, VBAP.ERDAT, VBAP.WERKS, VBAP.MATNR WITH READ ONLY;

SELECT TOP 1000 * FROM LIVE4.SALES_PER_LOCATION_PER_PRODUCT;
