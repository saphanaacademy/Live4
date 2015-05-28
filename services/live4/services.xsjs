function model() {
    var sqlstmt;
	var conn;
	var pstmt;
	var pcall;
	var rs;
	conn = $.db.getConnection();
	sqlstmt = 'SET SCHEMA "LIVE4"';
	conn.prepareStatement(sqlstmt).execute();
	sqlstmt = 'TRUNCATE TABLE "PAL_COEFF"';
	conn.prepareStatement(sqlstmt).execute();
	sqlstmt = 'TRUNCATE TABLE "PAL_FITTED"';
	conn.prepareStatement(sqlstmt).execute();
	sqlstmt = 'TRUNCATE TABLE "PAL_SIGNIFICANCE"';
	conn.prepareStatement(sqlstmt).execute();
	sqlstmt = 'TRUNCATE TABLE "PAL_PMML"';
	conn.prepareStatement(sqlstmt).execute();
	sqlstmt = 'CALL "PAL_MODEL" ("PAL_DATA", "PAL_PARAMS", ?, ?, ?, ?) WITH OVERVIEW';
	pcall = conn.prepareCall(sqlstmt);
	rs = pcall.execute();
	rs = pcall.getResultSet();
	var tables = [];
	while (rs.next()) { 
		tables.push(rs.getString(2));
	}
	pstmt = conn.prepareStatement('INSERT INTO "PAL_COEFF" SELECT * FROM ' + tables[0]);
	pstmt.executeUpdate();  
	pstmt.close(); 
	pstmt = conn.prepareStatement('INSERT INTO "PAL_FITTED" SELECT * FROM ' + tables[1]);
	pstmt.executeUpdate();  
	pstmt.close(); 
	pstmt = conn.prepareStatement('INSERT INTO "PAL_SIGNIFICANCE" SELECT * FROM ' + tables[2]);
	pstmt.executeUpdate();  
	pstmt.close(); 
	pstmt = conn.prepareStatement('INSERT INTO "PAL_PMML" SELECT * FROM ' + tables[3]);
	pstmt.executeUpdate();  
	pstmt.close(); 
	conn.commit();
	conn.close();
	$.response.setBody('Model Finished');  
}

function predict() {
    var sqlstmt;
	var conn;
	var pstmt;
	var pcall;
	var rs;
	conn = $.db.getConnection();
	sqlstmt = 'SET SCHEMA "LIVE4"';
	conn.prepareStatement(sqlstmt).execute();
	sqlstmt = 'TRUNCATE TABLE "PAL_FITTED"';
	conn.prepareStatement(sqlstmt).execute();
	sqlstmt = 'CALL "PAL_PREDICT" ("PAL_P_DATA", "PAL_COEFF", "PAL_PARAMS", ?) WITH OVERVIEW';
	pcall = conn.prepareCall(sqlstmt);
	rs = pcall.execute();
	rs = pcall.getResultSet();
	var tables = [];
	while (rs.next()) { 
		tables.push(rs.getString(2));
	}
	pstmt = conn.prepareStatement('INSERT INTO "PAL_FITTED" SELECT * FROM ' + tables[0]);
	pstmt.executeUpdate();  
	pstmt.close(); 
	conn.commit();
	conn.close();
	$.response.setBody('Predict Finished');  
}

function reset() {
    var sqlstmt;
	var conn;
	conn = $.db.getConnection();
	sqlstmt = 'UPDATE "LIVE4"."T001W_WS" SET "AQI"="AQI_O", "TMP"="TMP_O", "HUM"="HUM_O"';
	conn.prepareStatement(sqlstmt).execute();
	conn.commit();
	conn.close();
	$.response.setBody('Reset Finished');
	predict();
}

function tile() {
    var sqlstmt;
	var conn;
	var jsonStr;
	conn = $.hdb.getConnection();
	sqlstmt = 'SELECT TOP 1 "NAME1", "AQI" FROM "LIVE4"."T001W_WS" ORDER BY "AQI" DESC';
	var rs = conn.executeQuery(sqlstmt);
	var r = {};
	var d = {};
	var aqi = rs[0].AQI;
	d.number = aqi;
	d.numberDigits=0;
	d.numberFactor="AQI";
	var state;
    if (aqi <= 50) {
        state = "Positive";
    } else if (aqi <= 100) {
        state = "Critical";
    } else if (aqi <= 150) {
        state = "Negative";
    } else if (aqi <= 200) {
        state = "Neutral";
    } else if (aqi <= 300) {
        state = "Neutral";
    } else {
        state = "Neutral";
    }
	d.numberState = state;
	d.info = rs[0].NAME1;
	d.infoState = state;
	r.d = d;
	conn.close();
	$.response.contentType="application/json";
	$.response.setBody(JSON.stringify(r));
}

if ($.session.hasAppPrivilege("live4::Execute")) {
	var cmd = $.request.parameters.get('cmd');  
	switch (cmd) {  
		case "model":
			model();
			break;
		case "predict":
			predict();
			break;
		case "tile":
			tile();
			break;
		case "reset":
			reset();
			break;
		default:  
			$.response.setBody('Invalid Command: ' + cmd);  
			$.response.status = $.net.http.INTERNAL_SERVER_ERROR;  
	}
} else {
	$.response.setBody("Not authorized."); 
	$.response.status = $.net.http.INTERNAL_SERVER_ERROR;
}
