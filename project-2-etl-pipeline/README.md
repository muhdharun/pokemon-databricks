# Project 2: Multi-Table ETL Pipeline with Jobs

**Goal:** Build complete medallion flow, add data quality checks, create a scheduled Databricks Job  
**Time:** 1-1.5 hours  
**Prerequisites:** Project 1 completed

## What You'll Learn
✓ Multi-table ETL with joins and transformations  
✓ Data quality validation (nulls, duplicates)  
✓ Full medallion architecture (Bronze→Silver→Gold)  
✓ Databricks Jobs orchestration  
✓ Parameterized notebooks

## Outcome
An automated data pipeline that ingets raw Pokémon data, cleans it, and surfaces business-ready analytics via a scheduled Job.

---

## Step-by-Step Instructions

### Step 1: Upload Data (5 mins)
1. **Data** → **Upload**
2. Drag these 7 files from `project-2-etl-pipeline/data/`:
   - `pokemon.csv`, `pokemon_types.csv`, `types.csv`
   - `pokemon_stats.csv`, `stat_names.csv`
   - `type_efficacy.csv`, `moves.csv`
3. All to schema: `bronze`

### Step 2: Bronze Validation (10 mins)
1. **Workspace** → **Create** → **Notebook** (SQL)
2. Name: `02-bronze-validation`
3. Copy this SQL:

```sql
-- Check data quality
SELECT 'pokemon' as table_name, COUNT(*) as row_count, COUNT(DISTINCT id) as unique_ids 
FROM pokemon_catalog.bronze.pokemon
UNION ALL
SELECT 'pokemon_types', COUNT(*), COUNT(DISTINCT pokemon_id)
FROM pokemon_catalog.bronze.pokemon_types
UNION ALL
SELECT 'pokemon_stats', COUNT(*), COUNT(DISTINCT pokemon_id)
FROM pokemon_catalog.bronze.pokemon_stats
UNION ALL
SELECT 'types', COUNT(*), COUNT(DISTINCT id)
FROM pokemon_catalog.bronze.types;

-- Detect nulls
SELECT 
  'pokemon' as table_name,
  SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) as null_id,
  SUM(CASE WHEN identifier IS NULL THEN 1 ELSE 0 END) as null_identifier
FROM pokemon_catalog.bronze.pokemon;
```

4. Run → Observe data quality metrics

### Step 3: Silver Transformations (20 mins)
1. **Create** → **Notebook** (SQL)
2. Name: `02-silver-clean`
3. Copy these transformations:

```sql
-- Silver 1: Deduplicated Pokémon
CREATE TABLE IF NOT EXISTS pokemon_catalog.silver.pokemon_clean AS
SELECT DISTINCT
  id,
  identifier,
  species_id,
  height,
  weight,
  base_experience
FROM pokemon_catalog.bronze.pokemon
WHERE is_default = 1  -- Default forms only
  AND id > 0;  -- Valid IDs

-- Silver 2: Type assignments with names
CREATE TABLE IF NOT EXISTS pokemon_catalog.silver.pokemon_types_enriched AS
SELECT 
  pt.pokemon_id,
  p.identifier as pokemon_name,
  t.id as type_id,
  t.identifier as type_name,
  pt.slot as type_order
FROM pokemon_catalog.bronze.pokemon_types pt
INNER JOIN pokemon_catalog.silver.pokemon_clean p ON pt.pokemon_id = p.id
INNER JOIN pokemon_catalog.bronze.types t ON pt.type_id = t.id
ORDER BY pt.pokemon_id, pt.slot;

-- Silver 3: Stats with stat names
CREATE TABLE IF NOT EXISTS pokemon_catalog.silver.pokemon_stats_enriched AS
SELECT 
  ps.pokemon_id,
  p.identifier as pokemon_name,
  sn.name as stat_name,
  ps.base_stat,
  ps.effort
FROM pokemon_catalog.bronze.pokemon_stats ps
INNER JOIN pokemon_catalog.silver.pokemon_clean p ON ps.pokemon_id = p.id
INNER JOIN pokemon_catalog.bronze.stat_names sn ON ps.stat_id = sn.stat_id
WHERE sn.language_id = 9  -- English
ORDER BY ps.pokemon_id, ps.stat_id;

-- Validation: Check row counts
SELECT 'pokemon_clean' as table_name, COUNT(*) as rows FROM pokemon_catalog.silver.pokemon_clean
UNION ALL
SELECT 'pokemon_types_enriched', COUNT(*) FROM pokemon_catalog.silver.pokemon_types_enriched
UNION ALL
SELECT 'pokemon_stats_enriched', COUNT(*) FROM pokemon_catalog.silver.pokemon_stats_enriched;
```

4. Run → Verify all tables created

### Step 4: Gold Layer Aggregations (15 mins)
1. **Create** → **Notebook** (SQL)
2. Name: `02-gold-aggregations`
3. Copy:

```sql
-- Gold 1: Type performance metrics
CREATE TABLE IF NOT EXISTS pokemon_catalog.gold.type_metrics AS
SELECT 
  t.type_name,
  COUNT(DISTINCT t.pokemon_id) as pokemon_count,
  ROUND(AVG(s.base_stat), 1) as avg_stat,
  MAX(s.base_stat) as max_stat,
  MIN(s.base_stat) as min_stat
FROM pokemon_catalog.silver.pokemon_types_enriched t
INNER JOIN pokemon_catalog.silver.pokemon_stats_enriched s 
  ON t.pokemon_id = s.pokemon_id 
  AND s.stat_name = 'hp'  -- Use HP as example
GROUP BY t.type_name
ORDER BY pokemon_count DESC;

-- Gold 2: Pokémon summary
CREATE TABLE IF NOT EXISTS pokemon_catalog.gold.pokemon_summary AS
SELECT 
  p.id,
  p.identifier as pokemon_name,
  COLLECT_LIST(t.type_name) as types,
  MAX(CASE WHEN s.stat_name = 'hp' THEN s.base_stat END) as hp,
  MAX(CASE WHEN s.stat_name = 'attack' THEN s.base_stat END) as attack,
  MAX(CASE WHEN s.stat_name = 'defense' THEN s.base_stat END) as defense,
  MAX(CASE WHEN s.stat_name = 'sp. atk' THEN s.base_stat END) as sp_atk,
  MAX(CASE WHEN s.stat_name = 'sp. def' THEN s.base_stat END) as sp_def,
  MAX(CASE WHEN s.stat_name = 'speed' THEN s.base_stat END) as speed
FROM pokemon_catalog.silver.pokemon_clean p
LEFT JOIN pokemon_catalog.silver.pokemon_types_enriched t ON p.id = t.pokemon_id
LEFT JOIN pokemon_catalog.silver.pokemon_stats_enriched s ON p.id = s.pokemon_id
GROUP BY p.id, p.identifier
ORDER BY p.id;

-- Query result
SELECT * FROM pokemon_catalog.gold.pokemon_summary LIMIT 10;
```

4. Run → See final aggregations

### Step 5: Create a Job (10 mins)
1. Left sidebar → **Workflows** → **Jobs**
2. Click **Create Job**
3. Fill in:
   - **Job name:** `pokemon-pipeline`
   - **Cluster:** Create new or select existing
   - **Task name:** `run-pipeline`
4. Under **Notebook**, click **Select notebook**
5. Select: `02-silver-clean` notebook
6. Click **Create job**
7. Click **Run now** to test
8. Check Databricks email for job completion notification

### Step 6: Schedule Job (5 mins)
1. In the Job, click **Triggers** (top menu)
2. Click **Add trigger**
3. Select **Scheduled**
4. Set schedule: Every 1 hour (for demo; adjust as needed)
5. Click **Save**
6. Job now runs automatically!

---

## Key Concepts

**ETL Pattern:**
- Extract: Bronze tables (raw CSV uploads)
- Transform: Silver tables (joins, deduplication)
- Load: Gold tables (aggregations, business metrics)

**Data Quality:**
- Count distinct values (detect duplicates)
- Check nulls (data completeness)
- Validate foreign keys (referential integrity)

**Databricks Jobs:**
- Notebook orchestration
- Scheduled runs
- Job parameter passing
- Retry logic

---

## Expected Results

| Table | Rows | Purpose |
|-------|------|---------|
| pokemon_clean | ~1,025 | Deduplicated Pokémon |
| pokemon_types_enriched | ~1,681 | Type assignments with names |
| pokemon_stats_enriched | ~5,125 | Stats with human-readable names |
| type_metrics | 18 | Type performance summary |
| pokemon_summary | ~1,025 | Complete Pokémon attributes |

---

## Troubleshooting

**Q: Job fails with "notebook not found"**  
A: Ensure notebook is saved, in correct workspace location

**Q: Duplicate table error**  
A: Drop old tables: `DROP TABLE IF EXISTS schema.table;`

**Q: Job doesn't run on schedule**  
A: Check cluster is running; free tier may have limits

---

**✓ Completed Project 2? You've learned:** Full medallion, jobs, orchestration. Ready for Project 3!
