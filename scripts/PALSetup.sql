-- RUN AS SYSTEM/ADMINISTRATOR USER

-- CHECK AFL PAL FUNCTIONS ARE INSTALLED
SELECT * FROM SYS.AFL_FUNCTIONS WHERE PACKAGE_NAME='PAL';

-- START SCRIPT SERVER
ALTER SYSTEM ALTER CONFIGURATION ('daemon.ini', 'SYSTEM') SET ('scriptserver', 'instances') = '1' WITH RECONFIGURE;

-- CREATION & REMOVAL OF PAL PROCEDURES
GRANT AFLPM_CREATOR_ERASER_EXECUTE TO LIVE4;

-- EXECUTION OF PAL PROCEDURES
GRANT AFL__SYS_AFL_AFLPAL_EXECUTE TO LIVE4;
