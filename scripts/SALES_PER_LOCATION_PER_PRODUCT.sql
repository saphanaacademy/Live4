-- run this as LIVE4 user to create the SALES_PER_LOCATION_PER_PRODUCT view
-- this view is used gather product sales from a store by date also showing the weather readings for that date
-- this data will in turn be used with Predictive Analysis

CREATE VIEW LIVE4.SALES_PER_LOCATION_PER_PRODUCT AS 
SELECT
 ROW_NUMBER() OVER (ORDER BY MANDT, ERDAT, VBAP.WERKS, MATNR) AS ROW_NUM,
 TW.MANDT,
 VBAP.ERDAT,
 VBAP.WERKS,
 VBAP.MATNR,
 VBAP.QUANTITY,
 VBAP.SALES_TOTAL, 
 DLA.AQI,
 DLT.TMP,
 DLH.HUM
FROM 
 LIVE4.T001W_WS TW,
 (
 	SELECT
	 TO_DATE(ERDAT,'yyyymmdd') AS ERDAT,
	 WERKS,
	 MATNR,
	 SUM(KWMENG) AS QUANTITY,
	 TO_DECIMAL(SUM(KWMENG * NETWR), 10, 0) AS SALES_TOTAL 
	FROM 
	 LIVE4.VBAP
	GROUP BY 
	 ERDAT, WERKS, MATNR 
 ) VBAP,
 (
	SELECT 
	 "aqi" AS AQI,
	 "date_local" AS DATELOCAL,
	 "state_code" * 10000000 + "county_code" * 10000 + "site_num" AS SITENUM
	FROM 
	 LIVE4."DataLake_AQI"
 ) DLA,
 (
	SELECT 
	 "1st_max_value" AS TMP,
	 "date_local" AS DATELOCAL,
	 "state_code" * 10000000 + "county_code" * 10000 + "site_num" AS SITENUM
	FROM 
	 LIVE4."DataLake_Temperature"
 ) DLT,
 (
	SELECT 
	 "1st_max_value" AS HUM,
	 "date_local" AS DATELOCAL,
	 "state_code" * 10000000 + "county_code" * 10000 + "site_num" AS SITENUM
	FROM 
	 LIVE4."DataLake_Humidity"
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
