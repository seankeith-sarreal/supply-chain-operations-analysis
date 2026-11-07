SELECT version();
SELECT current_database();

--verify tables were created
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
ORDER BY table_schema, table_name;

ALTER TABLE public.shipments
SET SCHEMA staging;

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_name = 'shipments';