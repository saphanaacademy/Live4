DROP VIEW LIVE4.SALES_PER_LOCATION_PER_PRODUCT;

-- run this as LIVE4 user to create the SALES_PER_LOCATION_PER_PRODUCT_LOCALTABLES view
-- this view is similar to the SALES_PER_LOCATION_PER_PRODUCT view but does not use Hadoop tables
-- it is used with local HDB tables instead

-- the view can be used to gather product sales from a store by date also showing the weather readings for that date
-- this data can be in turn be used with Predictive Analysis

CREATE VIEW LIVE4.SALES_PER_LOCATION_PER_PRODUCT AS 
SELECT * FROM (
	SELECT
	 ROW_NUMBER() OVER (ORDER BY TW.MANDT, VBAP.ERDAT, VBAP.WERKS, VBAP.MATNR) AS ROW_NUM,
	 TW.MANDT,
	 VBAP.ERDAT,
	 VBAP.WERKS,
	 VBAP.MATNR,
	 VBAP.QUANTITY,
	 VBAP.SALES_TOTAL,
	 (
		SELECT MAX(AQI)
		FROM LIVE4."DataLake_AQI_Local" DLA
		WHERE  DLA."Date Local" = VBAP.ERDAT 
	 	 AND DLA."State Code" * 10000000 + DLA."County Code" * 10000 + DLA."Site Num" = TW.WS_AQI_SITENUM
	 ) AS AQI,
	 (
		SELECT MAX("1st Max Value")
		FROM LIVE4."DataLake_Temperature_Local" DLT
		WHERE  DLT."Date Local" = VBAP.ERDAT 
	 	 AND DLT."State Code" * 10000000 + DLT."County Code" * 10000 + DLT."Site Num" = TW.WS_TMP_SITENUM
	 ) AS TMP,
	 (
		SELECT MAX("1st Max Value")
		FROM LIVE4."DataLake_Humidity_Local" DLH
		WHERE  DLH."Date Local" = VBAP.ERDAT 
	 	 AND DLH."State Code" * 10000000 + DLH."County Code" * 10000 + DLH."Site Num" = TW.WS_HUM_SITENUM
	 ) AS HUM 
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
	 ) VBAP
	WHERE  	
	 TW.WERKS = VBAP.WERKS
) FQ
WHERE NOT (
	 FQ.AQI IS NULL OR
	 FQ.TMP IS NULL OR 
	 FQ.HUM IS NULL
 )	 
ORDER BY
 FQ.MANDT, 
 FQ.ERDAT, 
 FQ.WERKS, 
 FQ.MATNR 
WITH READ ONLY;

SELECT * FROM LIVE4.SALES_PER_LOCATION_PER_PRODUCT;
SELECT DISTINCT COUNT(*) FROM LIVE4.SALES_PER_LOCATION_PER_PRODUCT;
SELECT MAX(AQI)  FROM LIVE4.SALES_PER_LOCATION_PER_PRODUCT;
