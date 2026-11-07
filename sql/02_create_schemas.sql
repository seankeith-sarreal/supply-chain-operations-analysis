
--Verify connection to database
SELECT current_database();

--Create the schemas
CREATE SCHEMA staging;
CREATE SCHEMA clean;
CREATE SCHEMA analysis;

--Verify the schemas
SELECT schema_name
FROM information_schema.schemata
WHERE schema_name IN ('staging', 'clean', 'analysis')
ORDER BY schema_name;