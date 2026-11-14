-- Project 3: Permissions Audit Queries
-- Copy these into a Databricks SQL notebook to verify governance setup

-- 1. Show table ownership
SELECT 
  table_catalog,
  table_schema,
  table_name,
  table_owner as owner
FROM system.information_schema.tables
WHERE table_catalog IN ('bronze_raw', 'silver_staging', 'gold_analytics')
ORDER BY table_catalog, table_schema, table_name;

-- 2. Show all principals and their permissions
SELECT 
  securable_type,
  securable_name,
  principal_name,
  permission
FROM system.information_schema.principal_grants
WHERE securable_type IN ('TABLE', 'SCHEMA', 'CATALOG')
ORDER BY securable_type, securable_name, principal_name;

-- 3. Check catalog and schema permissions
SELECT 
  catalog_name,
  schema_name,
  principal_name,
  permission
FROM system.information_schema.schema_principal_grants
ORDER BY catalog_name, schema_name;

-- 4. Audit table modifications
SELECT 
  table_catalog,
  table_schema,
  table_name,
  table_modified_time,
  table_created_time
FROM system.information_schema.tables
WHERE table_catalog IN ('bronze_raw', 'silver_staging', 'gold_analytics')
  AND table_type = 'EXTERNAL'
ORDER BY table_modified_time DESC;

-- 5. Show column-level permissions (if set)
-- Note: Column ACLs shown via system tables in Unity Catalog
SELECT 
  securable_name,
  securable_type,
  principal_name,
  permission
FROM system.information_schema.principal_grants
WHERE securable_type = 'COLUMN'
ORDER BY securable_name;

-- 6. Verify views exist for row-level security
SELECT 
  table_catalog,
  table_schema,
  table_name,
  table_type
FROM system.information_schema.tables
WHERE table_schema IN ('data', 'insights')
  AND table_type = 'VIEW'
ORDER BY table_catalog;

-- 7. Check who has MANAGE permission (high risk)
SELECT 
  securable_name,
  principal_name,
  permission
FROM system.information_schema.principal_grants
WHERE permission = 'MANAGE'
ORDER BY securable_name;

-- Expected Results:
-- - 3 catalogs visible (bronze_raw, silver_staging, gold_analytics)
-- - Each has appropriate schema
-- - Tables show clear ownership
-- - Views exist for masked/row-level data
-- - Minimal MANAGE permissions (only data leads)
