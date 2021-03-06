CREATE VIEW "LIVE4"."PRODUCT_INVENTORY" ( "ROW_NUM", "MANDT", "WERKS", "MATNR", "INVENTORY", "INVENTORY_DATE" ) AS SELECT
	 ROW_NUMBER() OVER (ORDER BY MANDT, WERKS, MATNR) as ROW_NUM,
	 CAST("MANDT" as VARCHAR) AS MANDT,
	 CAST("WERKS" as VARCHAR) AS WERKS,
	 CAST("MATNR" as VARCHAR) AS MATNR,
	 CAST(SUM("LABST" + "UMLME" + "INSME" + "EINME" + "SPEME" + "RETME") as INTEGER) as INVENTORY,
	 MAX(TO_DATE("ERSDA",
	'YYYYMMDD')) as INVENTORY_DATE 
FROM "LIVE4"."MARD" 
GROUP BY "MANDT",
	 "MATNR",
	 "WERKS" ORDER BY 1,
	2,
	3 WITH READ ONLY
