# Project 4: Incremental Processing & Slowly Changing Dimensions (SCD)

**Goal:** Implement Type 2 SCD pattern, use Merge operations, explore Delta time-travel  
**Time:** 1-1.5 hours  
**Prerequisites:** Project 2 completed

## What You'll Learn
✓ Slowly Changing Dimensions (SCD Type 2)  
✓ Merge operations (INSERT/UPDATE/DELETE in one statement)  
✓ Delta Lake time-travel (version history)  
✓ Data lineage tracking (when/who/how data changed)  
✓ Incremental data loads

## Outcome
A dimension table that tracks historical Pokémon stat changes across game generations with audit timestamps.

---

## Step-by-Step Instructions

### Step 1: Load Historical Data (5 mins)
1. **Data** → **Upload**
2. Upload from `project-4-scd/data/`:
   - `pokemon.csv`
   - `pokemon_stats.csv`
   - `pokemon_stats_past.csv` (contains historical data)
3. All to schema: `bronze`
4. Verify: `pokemon_stats_past` has multiple rows per Pokémon (different generations)

### Step 2: Understand SCD Type 2 Concept (5 mins)
**Type 2 SCD:** Track changes by adding new rows with validity dates
```
pokemon_id | stat_id | base_stat | generation | effective_date | end_date   | is_current
1          | 1       | 45        | 1          | 2000-01-01     | 2006-12-31 | 0
1          | 1       | 45        | 2          | 2006-01-01     | 2023-12-31 | 0
1          | 1       | 45        | 3          | 2023-01-01     | 9999-12-31 | 1  ← Current
```

### Step 3: Create Dimension Table with SCD (15 mins)
1. **Workspace** → **Create** → **Notebook** (SQL)
2. Name: `04-scd-dimension`
3. Copy:

```sql
-- Step 1: Create initial dimension table (Type 2 SCD)
CREATE TABLE IF NOT EXISTS pokemon_catalog.silver.pokemon_stats_dimension (
  pokemon_id INT,
  pokemon_name STRING,
  stat_id INT,
  stat_name STRING,
  base_stat INT,
  generation_id INT,
  effective_date DATE,
  end_date DATE,
  is_current BOOLEAN,
  load_date TIMESTAMP,
  row_hash STRING
)
USING DELTA
PARTITIONED BY (generation_id)
TBLPROPERTIES ('delta.enableChangeDataFeed' = 'true');

-- Step 2: Populate with historical data from pokemon_stats_past
INSERT INTO pokemon_catalog.silver.pokemon_stats_dimension
SELECT 
  psp.pokemon_id,
  p.identifier as pokemon_name,
  psp.stat_id,
  sn.name as stat_name,
  psp.base_stat,
  g.id as generation_id,
  DATE_TRUNC('year', g.id * INTERVAL 2 YEAR) as effective_date,
  LAG(DATE_TRUNC('year', g.id * INTERVAL 2 YEAR), 1, DATE '9999-12-31')
    OVER (PARTITION BY psp.pokemon_id, psp.stat_id ORDER BY g.id DESC)
    - INTERVAL 1 DAY as end_date,
  ROW_NUMBER() OVER (PARTITION BY psp.pokemon_id, psp.stat_id ORDER BY g.id DESC) = 1 as is_current,
  CURRENT_TIMESTAMP() as load_date,
  MD5(CONCAT(psp.pokemon_id, psp.stat_id, psp.base_stat, g.id)) as row_hash
FROM pokemon_catalog.bronze.pokemon_stats_past psp
INNER JOIN pokemon_catalog.bronze.pokemon p ON psp.pokemon_id = p.id
INNER JOIN pokemon_catalog.bronze.stat_names sn ON psp.stat_id = sn.stat_id
INNER JOIN pokemon_catalog.bronze.generations g ON psp.generation_id = g.id
WHERE sn.language_id = 9;  -- English only

-- Verify
SELECT * FROM pokemon_catalog.silver.pokemon_stats_dimension 
WHERE pokemon_id = 1 ORDER BY stat_id, generation_id;
```

4. Run → Check that you see multiple rows per Pokémon (historical changes)

### Step 4: Implement Merge Logic (Incremental Load) (15 mins)
1. Add to notebook:

```sql
-- Step 3: Simulate new stat changes (incremental load)
-- Pretend Generation 9 stats just arrived
CREATE TEMPORARY VIEW new_stats AS
SELECT 
  ps.pokemon_id,
  p.identifier as pokemon_name,
  ps.stat_id,
  sn.name as stat_name,
  ps.base_stat + 5 as base_stat,  -- Simulate stat increase
  9 as generation_id
FROM pokemon_catalog.bronze.pokemon_stats ps
INNER JOIN pokemon_catalog.bronze.pokemon p ON ps.pokemon_id = p.id
INNER JOIN pokemon_catalog.bronze.stat_names sn ON ps.stat_id = sn.stat_id
WHERE sn.language_id = 9
LIMIT 100;  -- Limit for demo

-- Step 4: Merge to implement Type 2 SCD
MERGE INTO pokemon_catalog.silver.pokemon_stats_dimension existing
USING new_stats incoming
ON existing.pokemon_id = incoming.pokemon_id
  AND existing.stat_id = incoming.stat_id
  AND existing.generation_id = incoming.generation_id
  AND existing.is_current = TRUE
WHEN MATCHED AND existing.base_stat != incoming.base_stat THEN
  -- Stat changed: close old record, add new one
  UPDATE SET
    is_current = FALSE,
    end_date = CURRENT_DATE() - INTERVAL 1 DAY
WHEN NOT MATCHED THEN
  -- New generation: insert new record
  INSERT (pokemon_id, pokemon_name, stat_id, stat_name, base_stat, generation_id,
          effective_date, end_date, is_current, load_date, row_hash)
  VALUES (incoming.pokemon_id, incoming.pokemon_name, incoming.stat_id, incoming.stat_name,
          incoming.base_stat, incoming.generation_id, CURRENT_DATE(), 
          DATE '9999-12-31', TRUE, CURRENT_TIMESTAMP(),
          MD5(CONCAT(incoming.pokemon_id, incoming.stat_id, incoming.base_stat, incoming.generation_id)));

-- Verify: Check updated records
SELECT pokemon_name, stat_name, base_stat, generation_id, is_current, end_date
FROM pokemon_catalog.silver.pokemon_stats_dimension
WHERE pokemon_id = 1 
ORDER BY stat_id, generation_id DESC;
```

2. Run → Observe MERGE execution

### Step 5: Query SCD History (10 mins)
1. Add:

```sql
-- Query 1: Show how a Pokémon's stats evolved
SELECT 
  pokemon_name,
  stat_name,
  base_stat,
  generation_id,
  effective_date,
  end_date,
  is_current
FROM pokemon_catalog.silver.pokemon_stats_dimension
WHERE pokemon_name = 'bulbasaur'
ORDER BY stat_id, generation_id;

-- Query 2: Find stat changes (where base_stat differs between generations)
WITH stat_changes AS (
  SELECT 
    pokemon_name,
    stat_name,
    generation_id,
    base_stat,
    LAG(base_stat) OVER (PARTITION BY pokemon_id, stat_id ORDER BY generation_id) as prev_stat,
    base_stat - LAG(base_stat) OVER (PARTITION BY pokemon_id, stat_id ORDER BY generation_id) as stat_delta
  FROM pokemon_catalog.silver.pokemon_stats_dimension
  WHERE is_current = FALSE
)
SELECT pokemon_name, stat_name, stat_delta
FROM stat_changes
WHERE stat_delta IS NOT NULL AND ABS(stat_delta) > 0
ORDER BY ABS(stat_delta) DESC
LIMIT 20;
```

2. Run → See stat changes across generations

### Step 6: Time-Travel (Delta Versioning) (10 mins)
1. Add:

```sql
-- Query at a specific version (time-travel)
SELECT * FROM pokemon_catalog.silver.pokemon_stats_dimension
VERSION AS OF 0  -- Version 0 (initial load)
WHERE pokemon_id = 1 LIMIT 5;

-- Query at a specific timestamp
SELECT * FROM pokemon_catalog.silver.pokemon_stats_dimension
TIMESTAMP AS OF '2024-01-15 12:00:00'
WHERE pokemon_id = 1 LIMIT 5;

-- Show version history
DESCRIBE HISTORY pokemon_catalog.silver.pokemon_stats_dimension LIMIT 5;
```

2. Run → See how table evolved over time

### Step 7: Data Lineage (5 mins)
1. Add:

```sql
-- Who changed what and when?
SELECT 
  version,
  timestamp,
  userId,
  userName,
  operation
FROM (
  DESCRIBE HISTORY pokemon_catalog.silver.pokemon_stats_dimension
)
LIMIT 10;
```

2. Run

---

## Key Concepts

**SCD Type 2:**
- Tracks ALL changes
- Adds new row instead of updating
- Maintains historical accuracy
- Enables "as-of" queries

**Merge Operation:**
```sql
MERGE INTO target
USING source
ON join_condition
WHEN MATCHED THEN UPDATE ...
WHEN NOT MATCHED THEN INSERT ...
WHEN NOT MATCHED BY SOURCE THEN DELETE ...
```

**Time-Travel:**
- `VERSION AS OF n` - Query table at version n
- `TIMESTAMP AS OF date` - Query at specific time
- Enables data recovery, auditing

**Audit Trail:**
- `DESCRIBE HISTORY` shows all changes
- Tracks user, timestamp, operation
- Required for compliance

---

## Expected Results

| Stage | Rows | Purpose |
|-------|------|---------|
| Initial load | ~5,100 | All historical generations |
| After merge | ~5,150 | New generation added |
| Time-travel to v0 | ~5,100 | Original state |

---

## Troubleshooting

**Q: Merge says "ambiguous join"**  
A: Ensure ON condition uniquely identifies records

**Q: Time-travel returns empty**  
A: Version may not exist; check `DESCRIBE HISTORY` for available versions

**Q: Stat delta is NULL**  
A: Ensure you're looking at records where `is_current = FALSE`

---

**✓ Completed Project 4? You've learned:** SCD Type 2, Merge, time-travel. Ready for Project 5!
