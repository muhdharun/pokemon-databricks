# Project 5: Schema Reference

## Optimization Targets

### pokemon_by_type (Optimized Table)
**Partitioned by:** type_id  
**Z-Ordered by:** (type_id, base_stat)  

| Column | Type |
|--------|------|
| pokemon_id | int |
| pokemon_name | string |
| type_id | int (partition key) |
| type_name | string |
| base_stat | int |
| stat_id | int |

**Rows:** ~5,125

## Performance Metrics

### Query Baseline (Unoptimized)
```sql
-- Full table scan, no partitioning
SELECT pokemon_name, type_name, ROUND(AVG(base_stat), 2) as avg_stat
FROM bronze.pokemon_types_joined
WHERE type_id = 10  -- Fire
GROUP BY pokemon_name, type_name;
-- Expected: 1-2 seconds
```

### Query After Optimization
```sql
-- Partitioned + Z-ordered
SELECT pokemon_name, type_name, ROUND(AVG(base_stat), 2) as avg_stat
FROM silver.pokemon_by_type
WHERE type_id = 10
GROUP BY pokemon_name, type_name;
-- Expected: 0.2-0.5 seconds (75% faster)
```

## Optimization Steps Applied

1. **Partitioning by type_id**
   - Eliminates irrelevant partitions
   - Reduces data scanned by ~94% for single-type filter

2. **Z-Ordering by (type_id, base_stat)**
   - Improves clustering
   - Speeds up range queries

3. **ANALYZE for statistics**
   - Optimizer creates better query plans
   - ~10-15% improvement

4. **VACUUM for cleanup**
   - Removes old file versions
   - Frees storage (Delta Lake keeps 7 days by default)

## Monitoring

```sql
-- Check table size
SELECT ROUND(SUM(size) / 1024.0 / 1024.0, 2) as size_mb
FROM pokemon_by_type;

-- Check optimization status
DESCRIBE DETAIL pokemon_by_type;

-- Show file statistics
SELECT COUNT(*) as num_files, SUM(size) as total_size
FROM pokemon_by_type;
```

## Scaling Considerations

For larger datasets (>1TB):
- Partition more aggressively (by type_id + generation_id)
- Use Z-ordering on frequently filtered columns
- Schedule VACUUM weekly
- Monitor SQL Warehouse compute costs
