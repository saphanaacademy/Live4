------------
-- GRANTS --
------------

SELECT DISTINCT ROLE_NAME FROM GRANTED_ROLES WHERE ROLE_NAME LIKE 'NEO_%';
GRANT INSERT, UPDATE, DELETE ON SCHEMA LIVE4 TO "???";
