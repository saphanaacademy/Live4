jQuery.sap.declare("live4IoT.util.Formatter");

live4IoT.util.Formatter = {

    spareState :  function (iValue) {
        try {
            if (iValue < 0) {
                return "Error";
            } else if (iValue === 0) {
                return "Warning";
            } else {
                return "Success";
            }
        } catch (err) {
            return "None";
        }
    },
    
    AQIText :  function (iValue) {
        try {
            if (iValue <= 50) {
                return "Good";
            } else if (iValue <= 100) {
                return "Moderate";
            } else if (iValue <= 150) {
                return "Unhealthy for Sensitive Groups";
            } else if (iValue <= 200) {
                return "Unhealthy";
            } else if (iValue <= 300) {
                return "Very Unhealthy";
            } else {
                return "Hazardous";
            }
        } catch (err) {
            return "None";
        }
    },
    
    AQIState :  function (iValue) {
        try {
            if (iValue <= 50) {
                return "Success";
            } else if (iValue <= 100) {
                return "Warning";
            } else if (iValue <= 150) {
                return "Error";
            } else if (iValue <= 200) {
                return "None";
            } else if (iValue <= 300) {
                return "None";
            } else {
                return "None";
            }
        } catch (err) {
            return "None";
        }
    },
    
    TMPText :  function (iValue) {
        try {
            return "Temperature: " + iValue;
        } catch (err) {
            return "None";
        }
    },
    
    HUMText :  function (iValue) {
        try {
            return "Humidity: " + iValue;
        } catch (err) {
            return "None";
        }
    },

    TMPHUMText :  function (iValue1, iValue2)  {
        try {
            return "Temp:" + iValue1 + "  Humid:" + iValue2;
        } catch (err) {
            return "None";
        }
    }

};