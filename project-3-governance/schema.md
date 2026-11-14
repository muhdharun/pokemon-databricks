# Project 3: Schema Reference

## Catalogs & Permissions Structure

### bronze_raw Catalog
- **Purpose:** Raw imported data (restricted access)
- **Schema:** `data`
- **Typical Permissions:** 
  - Owner: Data engineers
  - Readers: None (enforce data pipeline)

### silver_staging Catalog
- **Purpose:** Cleaned, validated intermediate data (engineers only)
- **Schema:** `data`
- **Typical Permissions:**
  - Owner: Data engineers
  - Readers: Data engineers + pipeline service account

### gold_analytics Catalog
- **Purpose:** Business-ready insights (analyst access via views)
- **Schema:** `insights`
- **Typical Permissions:**
  - Owner: Analytics team lead
  - Readers: All analysts (via views with row-level security)

## Views (Security Layer)

### pokemon_masked
```sql
SELECT id, pokemon_name, base_experience
FROM bronze_raw.data.pokemon
-- Note: height, weight hidden
```
**Permission:** Analysts (SELECT)

### gen1_pokemon
```sql
SELECT id, pokemon_name, types
FROM gold_analytics.insights.gen1_pokemon
WHERE id BETWEEN 1 AND 151
-- Note: Only Generation 1
```
**Permission:** Analysts (SELECT)

## Permission Matrix

| Role | Bronze | Silver | Gold |
|------|--------|--------|------|
| Data Engineer | READ, WRITE | READ, WRITE | READ |
| Data Analyst | — | — | READ (via views) |
| Pipeline Service Account | — | WRITE | — |
| Data Lead | MANAGE | MANAGE | MANAGE |

## Audit Queries

```sql
-- Who owns each table?
SELECT table_name, owner 
FROM information_schema.tables
WHERE catalog_name IN ('bronze_raw', 'silver_staging', 'gold_analytics');

-- What permissions exist?
SELECT securable_name, principal_name, permission
FROM system.information_schema.principal_grants
WHERE securable_type = 'TABLE';
```
