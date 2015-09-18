-- run this as LIVE4 user to create the T001W_WS table
-- this table is used to find the closest weather stations for each store location as well as the highest weather reading

-- this table is similar to the LIVE4.T001W_WS table but does not use Hadoop tables
-- it is used with local HDB tables instead

DROP TABLE LIVE4.T001W_WS;

CREATE COLUMN TABLE LIVE4.T001W_WS (
	 ROWNUM INTEGER,
	 MANDT VARCHAR(3),
	 WERKS VARCHAR(4),
	 NAME1 VARCHAR(30), NAME2 VARCHAR(30),
	 STRAS VARCHAR(35), ORT01 VARCHAR(25), REGIO VARCHAR(3),
	 LAND1 VARCHAR(3), PSTLZ VARCHAR(10),
	 STR_LONGITUDE DOUBLE, STR_LATITUDE DOUBLE,
	 AQI INTEGER,
	 TMP INTEGER,
	 HUM INTEGER,
	 WS_AQI_SITENUM INTEGER, WS_AQI_LONGITUDE DOUBLE, WS_AQI_LATITUDE DOUBLE, WS_AQI_DISTANCE DOUBLE,
	 WS_TMP_SITENUM INTEGER, WS_TMP_LONGITUDE DOUBLE, WS_TMP_LATITUDE DOUBLE, WS_TMP_DISTANCE DOUBLE,
	 WS_HUM_SITENUM INTEGER, WS_HUM_LONGITUDE DOUBLE, WS_HUM_LATITUDE DOUBLE, WS_HUM_DISTANCE DOUBLE,
	 AQI_O INTEGER,
	 TMP_O INTEGER,
	 HUM_O INTEGER,
	 PRIMARY KEY ("ROWNUM")
) UNLOAD PRIORITY 5 AUTO MERGE;

INSERT INTO LIVE4.T001W_WS 
	SELECT 
		ROW_NUMBER() over (ORDER BY QAQI.MANDT, QAQI.WERKS ASC) AS ROWNUM,
 		QAQI.MANDT, 
 		QAQI.WERKS, 
 		QAQI.NAME1, QAQI.NAME2, 
 		QAQI.STRAS, QAQI.ORT01, QAQI.REGIO, 
 		QAQI.LAND1, QAQI.PSTLZ,
 		QAQI.LON_STR, QAQI.LAT_STR, 
 		QAQI.AQI, 
 		QTMP.TMP, 
 		QHUM.HUM, 
		QAQI.SITENUM_AQI, QAQI.LON_AQI, QAQI.LAT_AQI, QAQI.DIST_AQI,
		QTMP.SITENUM_TMP, QTMP.LON_TMP, QTMP.LAT_TMP, QTMP.DIST_TMP,
		QHUM.SITENUM_HUM, QHUM.LON_HUM, QHUM.LAT_HUM, QHUM.DIST_HUM,
		QAQI.AQI, 
		QTMP.TMP, 
		QHUM.HUM
	FROM (
		SELECT DISTINCT
			TW.MANDT, 
			TW.WERKS, 
			TW.NAME1, TW.NAME2,
			TW.STRAS, TW.ORT01, TW.REGIO,
			TW.LAND1, TW.PSTLZ, 
			SP.POSTCODE, 
			SP.SHAPE.ST_X() AS LON_STR,
			SP.SHAPE.ST_Y() AS LAT_STR,
			DL.AQI,
			DL."Longitude" AS LON_AQI, DL."Latitude" AS LAT_AQI,
			NEW ST_Point(DL."Longitude", DL."Latitude").ST_Distance(SP.SHAPE) AS DIST_AQI,	
			ROW_NUMBER() OVER (
		 		PARTITION BY TW.WERKS 
		 		ORDER BY 
		 			NEW ST_Point(DL."Longitude", DL."Latitude").ST_Distance(SP.SHAPE) ASC, 
		 			TO_NUMBER(DL.AQI) DESC
		 	) AS ROWNUM,
			10000000 * DL."State Code" + 10000 * DL."County Code" + DL."Site Num" AS SITENUM_AQI
		FROM 
			LIVE4.T001W TW,
			SAP_SPATIAL_POSTAL.USA_2014Q2_PCB_PTS_UNGEN_C SP,
			LIVE4."DataLake_AQI_Local" DL
		WHERE 
			SP.POSTCODE = TW.PSTLZ AND
			SP.ADMIN2 = UPPER(DL."State Name")
		ORDER BY 
			ROWNUM
	) AS QAQI,
	(
		SELECT DISTINCT
			TW.WERKS, 
			DL."1st Max Value" AS TMP,
			DL."Longitude" AS LON_TMP, DL."Latitude" AS LAT_TMP,
	 		NEW ST_Point(DL."Longitude", DL."Latitude").ST_Distance(SP.SHAPE) AS DIST_TMP,	
	 		ROW_NUMBER() OVER (
	 	 		PARTITION BY TW.WERKS 
	 	 		ORDER BY 
	 	 			NEW ST_Point(DL."Longitude", DL."Latitude").ST_Distance(SP.SHAPE) ASC, 
	 	 			TO_NUMBER(DL."1st Max Value") DESC
	 		) AS ROWNUM,
	 		10000000 * DL."State Code" + 10000 * DL."County Code" + DL."Site Num" AS SITENUM_TMP
		FROM 
			LIVE4.T001W TW,
			SAP_SPATIAL_POSTAL.USA_2014Q2_PCB_PTS_UNGEN_C SP,
			LIVE4."DataLake_Temperature_Local" DL
		WHERE 
			SP.POSTCODE = TW.PSTLZ AND
			SP.ADMIN2 = UPPER(DL."State Name")
	) AS QTMP,
	(
		SELECT DISTINCT
			TW.WERKS, 
			DL."1st Max Value" AS HUM,
			DL."Longitude" AS LON_HUM, DL."Latitude" AS LAT_HUM,
	 		NEW ST_Point(DL."Longitude", DL."Latitude").ST_Distance(SP.SHAPE) AS DIST_HUM,	
	 		ROW_NUMBER() OVER (
	 	 		PARTITION BY TW.WERKS 
	 	 		ORDER BY 
	 	 			NEW ST_Point(DL."Longitude", DL."Latitude").ST_Distance(SP.SHAPE) ASC, 
	 	 			TO_NUMBER(DL."1st Max Value") DESC
	 	 	) AS ROWNUM,
	 		10000000 * DL."State Code" + 10000 * DL."County Code" + DL."Site Num" AS SITENUM_HUM
		FROM 
			LIVE4.T001W TW,
			SAP_SPATIAL_POSTAL.USA_2014Q2_PCB_PTS_UNGEN_C SP,
			LIVE4."DataLake_Humidity_Local" DL
		WHERE 
			SP.POSTCODE = TW.PSTLZ AND
			SP.ADMIN2 = UPPER(DL."State Name")
	) AS QHUM
	WHERE 
		QAQI.ROWNUM = 1 AND 
		QTMP.ROWNUM = 1 AND
		QHUM.ROWNUM = 1 AND
		QAQI.WERKS = QTMP.WERKS AND
		QAQI.WERKS = QHUM.WERKS
	ORDER BY
		QAQI.WERKS;

SELECT * FROM LIVE4.T001W_WS;
