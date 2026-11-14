# Project 3: Governance & Permissions

**Goal:** Implement Unity Catalog security: ownership, RBAC, column/row-level access control  
**Time:** 1 hour  
**Prerequisites:** Project 2 completed

## What You'll Learn
✓ Unity Catalog hierarchy (metastore → catalog → schema → table)  
✓ Table ownership & transfer  
✓ Role-based access control (RBAC)  
✓ Column-level permissions  
✓ Row-level security via views  
✓ Service principal authentication

## Outcome
A secure data pipeline with enforced permissions: Gold layer readable by analysts, Silver layer restricted to data engineers, Bronze layer read-only.

---

## Step-by-Step Instructions

### Step 1: Create Catalogs for Governance (5 mins)
1. **Catalog** → **Create Catalog**
2. Create three catalogs:
   - Name: `bronze_raw` (for raw data, restricted)
   - Name: `silver_staging` (for cleaned data, engineers only)
   - Name: `gold_analytics` (for dashboards, all analysts can read)
3. Click **Create** for each

### Step 2: Create Schemas in Each Catalog (5 mins)
1. Click each catalog, then **Create Schema**
2. For `bronze_raw`: Create schema `data`
3. For `silver_staging`: Create schema `data`
4. For `gold_analytics`: Create schema `insights`

### Step 3: Set Ownership (10 mins)
1. Upload data to `bronze_raw.data` (use Project 2 CSVs)
2. Click on table → **Details** → **Owner**
3. Set owner: (your email)
4. Do the same for other tables

### Step 4: Column-Level Security (10 mins)
1. **Workspace** → **Create** → **Notebook** (SQL)
2. Name: `03-column-security`
3. Copy:

```sql
-- Create a view that masks sensitive columns
CREATE VIEW pokemon_catalog.silver_staging.data.pokemon_masked AS
SELECT 
  id,
  identifier as pokemon_name,
  -- Mask weight/height (considered sensitive for this example)
  NULL as height,
  NULL as weight,
  base_experience
FROM pokemon_catalog.bronze_raw.data.pokemon
WHERE TRUE;  -- Row filter can be added here

-- Grant permission to masked view
GRANT SELECT ON VIEW pokemon_catalog.silver_staging.data.pokemon_masked 
TO `analysts@company.com`;
```

4. Run to create masked view

### Step 5: Row-Level Security (10 mins)
1. Add to same notebook:

```sql
-- Create a view restricted to Generation 1 Pokémon only
CREATE VIEW pokemon_catalog.gold_analytics.insights.gen1_pokemon AS
SELECT 
  p.id,
  p.identifier,
  COLLECT_LIST(t.type_name) as types
FROM pokemon_catalog.silver_staging.data.pokemon p
LEFT JOIN pokemon_catalog.silver_staging.data.pokemon_types pt ON p.id = pt.pokemon_id
LEFT JOIN pokemon_catalog.silver_staging.data.types t ON pt.type_id = t.id
WHERE p.id <= 151  -- Generation 1: Pokémon 1-151
GROUP BY p.id, p.identifier
ORDER BY p.id;

-- Grant to analysts only
GRANT SELECT ON VIEW pokemon_catalog.gold_analytics.insights.gen1_pokemon 
TO `analysts@company.com`;
```

2. Run

### Step 6: Audit Permissions (10 mins)
1. **Create** → **Notebook** (SQL)
2. Name: `03-permissions-audit`
3. Copy audit queries:

```sql
-- Who has access to what?
SELECT 
  securable_name,
  principal_name,
  permission
FROM system.information_schema.principal_grants
WHERE securable_type = 'TABLE'
ORDER BY securable_name;

-- Check ownership
SELECT 
  catalog_name,
  schema_name,
  table_name,
  owner
FROM system.information_schema.tables
WHERE catalog_name LIKE 'bronze_raw'
   OR catalog_name LIKE 'silver_staging'
   OR catalog_name LIKE 'gold_analytics';

-- View column-level permissions
SHOW GRANT ON COLUMN pokemon_catalog.silver_staging.data.pokemon.identifier;
```

4. Run to verify permissions set correctly

### Step 7: Test Service Principal (Optional, 10 mins)
Note: Full setup requires workspace admin. Below is the concept:

```sql
-- Create a group for data engineers
-- (Done via Databricks admin console)

-- Grant group permissions to silver layer only
GRANT SELECT ON SCHEMA pokemon_catalog.silver_staging.data 
TO `data-engineers`;

-- Deny access to bronze
DENY SELECT ON SCHEMA pokemon_catalog.bronze_raw.data 
TO `data-engineers`;

-- Grant gold read-only to analysts
GRANT SELECT ON SCHEMA pokemon_catalog.gold_analytics.insights 
TO `analysts`;
```

---

## Key Concepts

**Unity Catalog Hierarchy:**
```
Metastore (account level)
  └─ Catalog (e.g., bronze_raw)
      └─ Schema (e.g., data)
          └─ Table (e.g., pokemon)
```

**Permission Levels:**
- **USAGE** - Can see the object
- **SELECT** - Can read data
- **MODIFY** - Can update/insert data
- **MANAGE** - Can modify permissions, ownership

**Ownership:**
- Owners can grant/revoke permissions
- Transfer ownership: `ALTER TABLE ... OWNER TO principal`

**RBAC Patterns:**
```
Bronze (restricted)   → Only data engineers
Silver (internal)     → Data engineers + pipeline service account
Gold (public)         → All analysts (via views only)
```

---

## Verification Checklist

✓ Three catalogs created  
✓ Three schemas created  
✓ Tables have clear ownership  
✓ Masked view hides sensitive columns  
✓ Row-level view restricts to Gen1 Pokémon  
✓ Audit queries show permission hierarchy  

---

## Troubleshooting

**Q: "GRANT failed: principal not found"**  
A: Use actual email; check spelling

**Q: Can't create catalog**  
A: Need workspace admin; ask admins for catalog creation or use existing

**Q: View doesn't filter rows**  
A: Add WHERE clause to view definition before CREATE

---

**✓ Completed Project 3? You've learned:** Governance, RBAC, security. Ready for Project 4!
