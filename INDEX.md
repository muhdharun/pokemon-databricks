# Pokémon Databricks Learning Index

Quick reference guide for all 5 projects.

## Project Summary Table

| # | Project | Focus | Time | Key Skills | Data Files |
|---|---------|-------|------|-----------|-----------|
| 1 | Type Coverage | Basics + Medallion Intro | 45-60 min | Ingest, joins, medallion Bronze/Silver/Gold | pokemon, pokemon_types, types, type_efficacy |
| 2 | ETL Pipeline | Full Medallion + Jobs | 60-90 min | ETL, data quality, orchestration, scheduling | +pokemon_stats, stat_names, moves |
| 3 | Governance | RBAC + Security | 60 min | Catalogs, ownership, permissions, views | Reuse Project 2 data |
| 4 | SCD & Merge | Advanced Patterns | 60-90 min | Type 2 SCD, Merge, time-travel, lineage | pokemon_stats_past, pokemon_evolution |
| 5 | Optimization | Tuning & Performance | 30-45 min | Partitioning, Z-ordering, VACUUM, caching | Reuse Project 2 data |

## Files per Project

### Project 1
```
project-1-type-coverage/
├── README.md (start here)
├── schema.md (table reference)
└── data/
    ├── pokemon.csv
    ├── pokemon_types.csv
    ├── types.csv
    └── type_efficacy.csv
```

### Project 2
```
project-2-etl-pipeline/
├── README.md
├── schema.md
├── data/ (7 CSV files)
├── notebooks/ (3 template notebooks)
└── jobs/
    └── job_config.json
```

### Project 3
```
project-3-governance/
├── README.md
├── schema.md
├── data/ (7 CSV files, reused)
├── notebooks/ (4 SQL notebooks)
└── permissions/
    └── permissions_audit.sql
```

### Project 4
```
project-4-scd/
├── README.md
├── schema.md
├── data/
│   ├── pokemon.csv
│   ├── pokemon_species.csv
│   ├── pokemon_evolution.csv
│   ├── pokemon_stats.csv
│   └── pokemon_stats_past.csv
└── notebooks/ (4 SQL notebooks)
```

### Project 5
```
project-5-optimization/
├── README.md
├── schema.md
├── data/ (7 CSV files, reused)
└── notebooks/ (5 SQL notebooks)
```

## Key Databricks Concepts by Project

### Project 1 ✓
- **Concepts:** Delta Lake, Unity Catalog, medallion architecture
- **SQL:** SELECT, JOIN, GROUP BY, aggregations
- **Databricks UI:** Data upload, table creation, SQL editor

### Project 2 ✓
- **Concepts:** ETL flows, data quality, Databricks Jobs
- **SQL:** CREATE TABLE, INSERT, data validation
- **Databricks UI:** Jobs creation, scheduling, Notebook linking

### Project 3 ✓
- **Concepts:** Governance, RBAC, security
- **SQL:** CREATE VIEW, GRANT, permission queries
- **Databricks UI:** Catalog/schema/table management, permissions tab

### Project 4 ✓
- **Concepts:** SCD Type 2, Merge, time-travel
- **SQL:** MERGE operation, window functions, time-travel queries
- **Databricks UI:** DESCRIBE HISTORY, version comparison

### Project 5 ✓
- **Concepts:** Performance tuning, partitioning, optimization
- **SQL:** OPTIMIZE, ZORDER, ANALYZE, DESCRIBE DETAIL
- **Databricks UI:** Query profiling, execution plan analysis

## Databricks Certification Domains Covered

| Domain | Project | Coverage |
|--------|---------|----------|
| Delta Lake Architecture | 1, 2, 4, 5 | Full |
| ETL/ELT Pipelines | 2, 4 | Full |
| Data Governance | 3 | Full |
| SQL Transformations | 1, 2, 4, 5 | Full |
| Databricks Platform | 2, 3, 5 | Full |
| Performance Tuning | 5 | Full |

## Quick Navigation

**Just getting started?**  
→ Read `QUICK_START.md`, then start Project 1

**Familiar with medallion?**  
→ Skip Project 1, start Project 2

**Ready for advanced?**  
→ Jump to Project 4 (SCD/Merge)

**Need optimization?**  
→ Jump to Project 5

**Focused on governance?**  
→ Do Project 2 first (setup), then Project 3

## Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| "Table not found" | Table in wrong schema | Use full name: `catalog.schema.table` |
| "No cluster attached" | Warehouse not selected | Click dropdown top-right, select warehouse |
| "Permission denied" | Wrong ownership | Ask workspace admin or check GRANT statements |
| "Merge ambiguous" | Duplicate join condition | Add more join predicates or alias tables |
| "VACUUM won't run" | Not Delta format | Use `USING DELTA` in CREATE TABLE |

## Resources

### Databricks Docs
- [SQL Reference](https://docs.databricks.com/sql/)
- [Unity Catalog](https://docs.databricks.com/en/uc/)
- [Delta Lake Guide](https://docs.databricks.com/en/delta/)

### Certification
- [Exam Prep](https://www.databricks.com/learn/training/databricks-certification-exam-preparation)
- [Study Guide](https://www.databricks.com/blog/category/databricks-certifications)

### This Repo
- `README.md` - Main overview
- `QUICK_START.md` - Free tier setup

## Time Estimate

| Project | Time | Running Total |
|---------|------|---|
| 1 | 45-60 min | 45-60 min |
| 2 | 60-90 min | 1.75-2.5 hours |
| 3 | 60 min | 2.75-3.5 hours |
| 4 | 60-90 min | 3.75-4.75 hours |
| 5 | 30-45 min | 4.25-5.25 hours |

**Total:** ~4-5 hours of focused learning

## Troubleshooting

**Q: Notebooks are slow to load**  
A: Free tier has limited resources; try refreshing browser

**Q: Data won't upload**  
A: File >5GB? Split it; file has special chars? Rename

**Q: Job never completes**  
A: Free tier may have queue limits; check job logs

**Q: Can't create third catalog**  
A: Free tier limit; ask admin or reuse existing catalogs

---

**Status:** ✓ All files ready  
**Last Updated:** 2024  
**Version:** 1.0
