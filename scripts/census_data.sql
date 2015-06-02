-- the census data is in a HANA binary format and is available from here
https://www.dropbox.com/s/cozy94rmvkil2x7/live4CensusData.zip?dl=0

-- grant access to the YOURWORLD (census data) schema to the Live4 user
GRANT CREATE ANY, ALTER, DROP, EXECUTE, SELECT, INSERT, UPDATE, DELETE, INDEX, DEBUG, TRIGGER, REFERENCES ON SCHEMA YOURWORLD TO LIVE4;
