-- run this as LIVE4 user to create the SALES_PER_LOCATION_PER_PRODUCT_LOCALTABLES view
-- this view is similar to the SALES_PER_LOCATION_PER_PRODUCT view but does not use Hadoop tables
-- it is used with local HDB tables instead

-- the view can be used to gather product sales from a store by date also showing the weather readings for that date
-- this data can be in turn be used with Predictive Analysis

CREATE VIEW LIVE4.SALES_PER_LOCATION_PER_PRODUCT_LOCALTABLES AS 
SELECT
 ROW_NUMBER() OVER (ORDER BY TW.MANDT, VBAP.ERDAT, VBAP.WERKS, VBAP.MATNR) AS ROW_NUM,
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
	 TO_DATE(ERDAT,'YYYYMMDD') AS ERDAT,
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
	 AQI,
	 "Date Local" AS DATELOCAL,
	 "State Code" * 10000000 + "County Code" * 10000 + "Site Num" AS SITENUM
	FROM 
	 LIVE4."DataLake_AQI_Local"
 ) DLA,
 (
	SELECT 
	 "1st Max Value" AS TMP,
	 "Date Local" AS DATELOCAL,
	 "State Code" * 10000000 + "County Code" * 10000 + "Site Num" AS SITENUM
	FROM 
	 LIVE4."DataLake_Temperature_Local"
 ) DLT,
 (
	SELECT 
	 "1st Max Value" AS HUM,
	 "Date Local" AS DATELOCAL,
	 "State Code" * 10000000 + "County Code" * 10000 + "Site Num" AS SITENUM
	FROM 
	 LIVE4."DataLake_Humidity_Local"
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

SELECT TOP 1000 * FROM LIVE4.SALES_PER_LOCATION_PER_PRODUCT_LOCALTABLES;
