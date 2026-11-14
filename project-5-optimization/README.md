# Project 5: Query Optimization & Performance Tuning

**Goal:** Learn Delta Lake optimization: partitioning, Z-ordering, caching, query tuning  
**Time:** 30-45 mins  
**Prerequisites:** Project 2 completed

## What You'll Learn
✓ Query profiling (identifying slow queries)  
✓ Partitioning strategies  
✓ Z-ordering (multi-dimensional clustering)  
✓ Caching strategies  
✓ VACUUM and ANALYZE  
✓ Cost monitoring

## Outcome
Optimized queries that run 10-50% faster with 20-30% lower compute costs.

---

## Step-by-Step Instructions

### Step 1: Upload Data & Create Baseline (5 mins)
1. **Data** → **Upload** (use Project 2 data)
2. Create raw tables in `bronze` schema
3. **Create** → **Notebook** (SQL)
4. Name: `05-baseline-queries`
5. Copy:

```sql
-- Baseline: Slow query (full table scan, no partitioning)
SELECT 
  p.identifier as pokemon_name,
  COLLECT_LIST(t.identifier) as types,
  ROUND(AVG(ps.base_stat), 2) as avg_stat
FROM pokemon_catalog.bronze.pokemon p
INNER JOIN pokemon_catalog.bronze.pokemon_types pt ON p.id = pt.pokemon_id
INNER JOIN pokemon_catalog.bronze.types t ON pt.type_id = t.id
INNER JOIN pokemon_catalog.bronze.pokemon_stats ps ON p.id = ps.pokemon_id
WHERE t.identifier = 'fire'  -- Filter for fire types only
  AND ps.base_stat > 50
GROUP BY p.identifier
ORDER BY avg_stat DESC;
```

6. Run → Note execution time (shown at bottom: "X seconds")

### Step 2: Create Partitioned Tables (10 mins)
1. Add to notebook:

```sql
-- Optimized: Partitioned by type
CREATE TABLE IF NOT EXISTS pokemon_catalog.silver.pokemon_by_type (
  pokemon_id INT,
  pokemon_name STRING,
  type_id INT,
  type_name STRING,
  base_stat INT,
  stat_id INT
)
USING DELTA
PARTITIONED BY (type_id)
TBLPROPERTIES ('delta.tuneFilesForSourceFileSize' = 'true');

-- Load data
INSERT INTO pokemon_catalog.silver.pokemon_by_type
SELECT 
  p.id,
  p.identifier,
  t.id,
  t.identifier,
  ps.base_stat,
  ps.stat_id
FROM pokemon_catalog.bronze.pokemon p
INNER JOIN pokemon_catalog.bronze.pokemon_types pt ON p.id = pt.pokemon_id
INNER JOIN pokemon_catalog.bronze.types t ON pt.type_id = t.id
INNER JOIN pokemon_catalog.bronze.pokemon_stats ps ON p.id = ps.pokemon_id;

-- Optimized query (partition pruning)
SELECT 
  pokemon_name,
  type_name,
  ROUND(AVG(base_stat), 2) as avg_stat
FROM pokemon_catalog.silver.pokemon_by_type
WHERE type_id = (SELECT id FROM pokemon_catalog.bronze.types WHERE identifier = 'fire')
  AND base_stat > 50
GROUP BY pokemon_name, type_name
ORDER BY avg_stat DESC;
```

2. Run → Compare time with baseline

### Step 3: Apply Z-Ordering (10 mins)
1. Add:

```sql
-- Z-order optimization (multi-dimensional clustering)
OPTIMIZE pokemon_catalog.silver.pokemon_by_type
ZORDER BY (type_id, base_stat);

-- Re-run optimized query
SELECT 
  pokemon_name,
  type_name,
  ROUND(AVG(base_stat), 2) as avg_stat
FROM pokemon_catalog.silver.pokemon_by_type
WHERE type_id IN (SELECT id FROM pokemon_catalog.bronze.types WHERE identifier = 'fire')
  AND base_stat > 50
GROUP BY pokemon_name, type_name
ORDER BY avg_stat DESC;
```

2. Run → Observe faster execution

### Step 4: Analyze Table Statistics (5 mins)
1. Add:

```sql
-- Gather statistics for optimizer
ANALYZE TABLE pokemon_catalog.silver.pokemon_by_type COMPUTE STATISTICS;

-- Check statistics
DESCRIBE DETAIL pokemon_catalog.silver.pokemon_by_type;

-- Show data files info
SELECT 
  COUNT(*) as num_files,
  SUM(size) as total_size_bytes,
  SUM(size) / COUNT(*) as avg_file_size
FROM (
  SELECT file_name, size FROM pokemon_catalog.silver.pokemon_by_type
);
```

2. Run

### Step 5: Caching (5 mins)
1. Add:

```sql
-- Cache frequently accessed data
CACHE SELECT * FROM pokemon_catalog.silver.pokemon_by_type;

-- Run query on cached data (will be faster)
SELECT 
  pokemon_name,
  type_name,
  ROUND(AVG(base_stat), 2) as avg_stat
FROM pokemon_catalog.silver.pokemon_by_type
WHERE type_id IN (SELECT id FROM pokemon_catalog.bronze.types WHERE identifier = 'water')
  AND base_stat > 60
GROUP BY pokemon_name, type_name
ORDER BY avg_stat DESC
LIMIT 20;

-- Remove cache if needed
UNCACHE TABLE pokemon_catalog.silver.pokemon_by_type;
```

2. Run

### Step 6: Cleanup & Cost Analysis (5 mins)
1. Add:

```sql
-- Remove old versions (free up storage)
VACUUM pokemon_catalog.silver.pokemon_by_type RETAIN 7 DAYS;

-- Check table size after vacuum
SELECT 
  ROUND(SUM(size) / 1024.0 / 1024.0, 2) as size_mb
FROM (
  SELECT file_name, size FROM pokemon_catalog.silver.pokemon_by_type
);

-- Show cost metrics
-- (Note: On free tier, limited usage shown)
SHOW TBLPROPERTIES pokemon_catalog.silver.pokemon_by_type;
```

2. Run

### Step 7: Before/After Comparison (5 mins)
1. Create summary:

```sql
-- Final query comparison
-- Before (full scan): ~1-2 seconds
-- After (partitioned + z-order): ~0.2-0.5 seconds
-- Improvement: ~75% faster

-- Run final optimized query
SELECT 
  pokemon_name,
  type_name,
  COUNT(*) as pokemon_count,
  ROUND(AVG(base_stat), 2) as avg_stat,
  MIN(base_stat) as min_stat,
  MAX(base_stat) as max_stat
FROM pokemon_catalog.silver.pokemon_by_type
WHERE type_id IN (1, 2, 3)  -- Fire, Water, Grass
  AND base_stat > 40
GROUP BY pokemon_name, type_name
ORDER BY type_name, avg_stat DESC;
```

2. Note execution time and compare to baseline

---

## Key Optimizations

| Technique | Benefit | When to Use |
|-----------|---------|------------|
| **Partitioning** | Eliminate irrelevant data | Frequent filters on same column |
| **Z-Ordering** | Better clustering | Multi-column filters |
| **ANALYZE** | Better query plans | After loading data |
| **Caching** | In-memory queries | Frequently accessed tables |
| **VACUUM** | Reduce storage | Clean up old versions |

---

## Expected Performance

| Query Type | Baseline | Optimized | Gain |
|------------|----------|-----------|------|
| Single type filter | 1.5s | 0.3s | 80% faster |
| Multi-filter | 2.0s | 0.5s | 75% faster |
| Aggregation | 1.2s | 0.4s | 67% faster |

---

## Real-World Tips

1. **Partition only on high-cardinality, frequently-filtered columns**
   - Good: type_id (18 values), generation_id (9 values)
   - Bad: is_default (2 values), pokemon_id (1000+ values)

2. **Z-order 2-3 columns max**
   - More columns = overhead

3. **VACUUM on schedule (daily/weekly)**
   - Removes outdated files
   - Reclaims storage

4. **Monitor costs**
   - Compute time × Warehouse size = cost
   - Optimization pays for itself in weeks

---

## Troubleshooting

**Q: OPTIMIZE takes too long**  
A: Run during off-hours; can be cancelled if needed

**Q: Cache evicted (memory full)**  
A: Query recomputed; normal behavior on small clusters

**Q: "Cannot run VACUUM on table without Delta format"**  
A: Ensure table created with `USING DELTA`

---

**✓ Completed Project 5? You've learned:** Optimization, partitioning, performance tuning. 🎉 All projects done!

## Certification Prep Summary

After all 5 projects, you've covered:
- ✓ Delta Lake features
- ✓ ETL/medallion patterns
- ✓ Governance & security
- ✓ Advanced transformations
- ✓ Performance tuning
- ✓ Databricks platform

**Next:** Take practice exam at https://www.databricks.com/learn/training/databricks-certification-exam-preparation
