# Project 1: Type Coverage Analysis

**Goal:** Learn basic Databricks workflow: ingest CSV → medallion architecture → query insights  
**Time:** 45 mins - 1 hour  
**Prerequisites:** Completed QUICK_START.md setup

## What You'll Learn
✓ Upload CSV files to Databricks  
✓ Create Bronze/Silver/Gold medallion layers  
✓ Write basic SQL transformations  
✓ Query Delta tables  
✓ Analyze Pokémon type coverage

## Outcome
A query that ranks Pokémon by their defensive type coverage (how many types they resist or are immune to).

---

## Step-by-Step Instructions

### Step 1: Upload CSV Files (5 mins)
1. In Databricks, go **Data** (sidebar) → **Upload**
2. Drag these 4 files from `project-1-type-coverage/data/`:
   - `pokemon.csv`
   - `pokemon_types.csv`
   - `types.csv`
   - `type_efficacy.csv`
3. When prompted:
   - Select schema: `bronze`
   - Table name (auto-filled): leave as-is
   - Click **Create table**
4. Repeat for all 4 files → All should appear under `pokemon_catalog.bronze`

### Step 2: Verify Bronze Tables (3 mins)
1. Left sidebar → **Catalog** → `pokemon_catalog` → `bronze`
2. You should see 4 tables:
   - `pokemon` (1,025 rows)
   - `pokemon_types` (1,681 rows)
   - `types` (18 rows)
   - `type_efficacy` (540 rows)
3. Click each table → **Data** tab to preview

### Step 3: Create Silver Layer (15 mins)
1. Workspace → **Create** → **Notebook** (SQL)
2. Name: `01-silver-transform`
3. Copy this into the notebook:

```sql
-- Silver: Clean and join types data
CREATE TABLE IF NOT EXISTS pokemon_catalog.silver.pokemon_types_clean AS
SELECT 
  p.id as pokemon_id,
  p.identifier as pokemon_name,
  pt.type_id,
  t.identifier as type_name,
  pt.slot as type_slot
FROM pokemon_catalog.bronze.pokemon p
INNER JOIN pokemon_catalog.bronze.pokemon_types pt ON p.id = pt.pokemon_id
INNER JOIN pokemon_catalog.bronze.types t ON pt.type_id = t.id
WHERE p.is_default = 1  -- Only default forms
ORDER BY p.id, pt.slot;

-- Check result
SELECT * FROM pokemon_catalog.silver.pokemon_types_clean LIMIT 10;
```

4. Click **Attach cluster/warehouse** → select `pokemon-warehouse` (top-right dropdown)
5. Press **Ctrl+Enter** to run
6. Wait for completion → You should see 10 rows displayed

### Step 4: Create Gold Layer - Type Coverage (15 mins)
1. In same notebook, scroll down and add this SQL:

```sql
-- Gold: Calculate defensive type coverage per Pokémon
CREATE TABLE IF NOT EXISTS pokemon_catalog.gold.pokemon_type_coverage AS
WITH pokemon_resistances AS (
  -- Get all types this Pokémon resists (taking damage)
  SELECT DISTINCT
    stc.pokemon_id,
    stc.pokemon_name,
    te.damage_type_id as resisted_type_id,
    rt.identifier as resisted_type_name,
    te.damage_factor,
    CASE 
      WHEN te.damage_factor = 0 THEN 'immune'
      WHEN te.damage_factor < 100 THEN 'resist'
      ELSE 'normal'
    END as coverage_type
  FROM pokemon_catalog.silver.pokemon_types_clean stc
  INNER JOIN pokemon_catalog.bronze.type_efficacy te 
    ON te.target_type_id = stc.type_id  -- This Pokémon's type resists...
  INNER JOIN pokemon_catalog.bronze.types rt 
    ON rt.id = te.damage_type_id
  WHERE te.damage_factor <= 100  -- Only resistances/immunities
)
SELECT 
  pokemon_id,
  pokemon_name,
  COUNT(DISTINCT resisted_type_id) as total_resistances,
  SUM(CASE WHEN coverage_type = 'immune' THEN 1 ELSE 0 END) as immunity_count,
  SUM(CASE WHEN coverage_type = 'resist' THEN 1 ELSE 0 END) as resist_count,
  COLLECT_LIST(resisted_type_name) as resisted_types
FROM pokemon_resistances
GROUP BY pokemon_id, pokemon_name
ORDER BY total_resistances DESC;

-- Query result
SELECT * FROM pokemon_catalog.gold.pokemon_type_coverage LIMIT 20;
```

6. Press **Ctrl+Enter** → See top 20 Pokémon by defensive coverage

### Step 5: Query Insights (10 mins)
1. Add this final query to same notebook:

```sql
-- Insight: Which Pokémon has the best defensive type coverage?
SELECT 
  pokemon_name,
  total_resistances,
  immunity_count,
  resist_count
FROM pokemon_catalog.gold.pokemon_type_coverage
WHERE total_resistances > 5  -- Multi-resistant Pokémon
ORDER BY total_resistances DESC, immunity_count DESC
LIMIT 15;
```

2. Run it → Analyze the results

---

## Key Concepts Covered

**Delta Lake:**
- `CREATE TABLE IF NOT EXISTS` (idempotent)
- Delta manages ACID properties automatically

**Medallion Architecture:**
- **Bronze:** Raw imported data
- **Silver:** Cleaned, deduplicated, validated
- **Gold:** Business-ready, aggregated insights

**SQL Skills:**
- Joins (INNER JOIN)
- Filtering (WHERE, CASE)
- Aggregation (COUNT, COLLECT_LIST)

---

## Expected Results

Top Pokémon by defensive coverage:
- Steel/Flying types typically have highest resistance count (10+)
- Water types have good coverage (5-7 resistances)
- Normal types have poor coverage (0-2 resistances)

---

## What's Next?

✓ Understand medallion layers? Move to **Project 2**  
✗ Stuck? Check `schema.md` or re-read Step 3-4

## Troubleshooting

**Q: "Table not found" error**  
A: Run previous steps first; check table name spelling (case-sensitive in some contexts)

**Q: No data displayed**  
A: Click **Attach cluster** dropdown, select `pokemon-warehouse`, try again

**Q: Query running slowly**  
A: Normal for free tier; wait 30-60 seconds

---

**✓ Completed Project 1? You've learned:** Ingest, medallion, joins, aggregations. Ready for Project 2!
