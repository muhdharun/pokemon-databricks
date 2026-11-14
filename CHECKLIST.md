# Pokémon Databricks - Learning Checklist

Track your progress through all 5 projects here.

## Prerequisites ✓
- [ ] Databricks free tier account created (https://databricks.com/try)
- [ ] Read QUICK_START.md and followed setup steps
- [ ] Created workspace with name: _____________
- [ ] Created SQL warehouse: `pokemon-warehouse`
- [ ] Created catalog: `pokemon_catalog` with schemas (bronze, silver, gold)

---

## Project 1: Type Coverage Analysis
**Status:** [ ] Not Started [ ] In Progress [ ] Complete

- [ ] Read `project-1-type-coverage/README.md`
- [ ] Review `project-1-type-coverage/schema.md`
- [ ] Upload 4 CSV files to bronze schema
- [ ] Create `01-silver-transform` notebook
- [ ] Create `02-gold-analysis` notebook
- [ ] Run queries and verify results
- [ ] Query top 20 Pokémon by type coverage
- [ ] Understand medallion Bronze→Silver→Gold flow

**Time Spent:** ______ mins  
**Key Insight:** _____________________________________________

---

## Project 2: Multi-Table ETL Pipeline
**Status:** [ ] Not Started [ ] In Progress [ ] Complete

- [ ] Read `project-2-etl-pipeline/README.md`
- [ ] Review `project-2-etl-pipeline/schema.md`
- [ ] Upload 7 CSV files to bronze schema
- [ ] Create `02-bronze-validation` notebook
- [ ] Create `02-silver-clean` notebook
- [ ] Create `02-gold-aggregations` notebook
- [ ] Verify all Silver tables created (3 tables)
- [ ] Verify all Gold tables created (2 tables)
- [ ] Create Databricks Job: `pokemon-pipeline`
- [ ] Run job successfully
- [ ] Set job schedule (e.g., hourly)
- [ ] Understand full medallion + orchestration

**Time Spent:** ______ mins  
**Key Insight:** _____________________________________________

---

## Project 3: Governance & Permissions
**Status:** [ ] Not Started [ ] In Progress [ ] Complete

- [ ] Read `project-3-governance/README.md`
- [ ] Review `project-3-governance/schema.md`
- [ ] Create 3 catalogs: bronze_raw, silver_staging, gold_analytics
- [ ] Create schemas in each catalog
- [ ] Upload data to bronze_raw
- [ ] Set table ownership
- [ ] Create `03-column-security` notebook
- [ ] Create masked view (pokemon_masked)
- [ ] Create row-level view (gen1_pokemon)
- [ ] Create `03-permissions-audit` notebook
- [ ] Run audit queries
- [ ] Verify permissions set correctly
- [ ] Understand RBAC hierarchy and views

**Time Spent:** ______ mins  
**Key Insight:** _____________________________________________

---

## Project 4: Incremental Processing & SCD
**Status:** [ ] Not Started [ ] In Progress [ ] Complete

- [ ] Read `project-4-scd/README.md`
- [ ] Review `project-4-scd/schema.md`
- [ ] Upload 5 CSV files to bronze schema
- [ ] Create `04-scd-dimension` notebook
- [ ] Create initial SCD Type 2 dimension table
- [ ] Load historical data from pokemon_stats_past
- [ ] Create `04-merge-incremental` notebook
- [ ] Implement Merge operation for incremental load
- [ ] Query historical changes (stat evolution)
- [ ] Create `04-time-travel` notebook
- [ ] Test time-travel (VERSION AS OF, TIMESTAMP AS OF)
- [ ] Run DESCRIBE HISTORY to see versions
- [ ] Understand SCD Type 2 and Merge patterns

**Time Spent:** ______ mins  
**Key Insight:** _____________________________________________

---

## Project 5: Performance Optimization
**Status:** [ ] Not Started [ ] In Progress [ ] Complete

- [ ] Read `project-5-optimization/README.md`
- [ ] Review `project-5-optimization/schema.md`
- [ ] Upload 7 CSV files to bronze schema
- [ ] Create `05-baseline-queries` notebook
- [ ] Run baseline queries and note execution time
- [ ] Create `05-partitioned-table` notebook
- [ ] Create partitioned table (pokemon_by_type)
- [ ] Compare query performance vs baseline
- [ ] Create `05-z-order` notebook
- [ ] Apply Z-ordering optimization
- [ ] Run ANALYZE for statistics
- [ ] Run VACUUM to clean up old versions
- [ ] Run optimization queries again
- [ ] Verify ~75% performance improvement
- [ ] Understand partitioning, Z-ordering, caching

**Time Spent:** ______ mins  
**Key Insight:** _____________________________________________

---

## Post-Learning

- [ ] Review all 5 projects for areas of weakness
- [ ] Revisit documentation for unclear concepts
- [ ] Take Databricks practice exam
- [ ] Schedule certification exam
- [ ] **Optional:** Extend projects (add more data, create dashboards, try Delta sharing)

**Certification Exam Date:** _____________  
**Result:** [ ] Passed [ ] Failed - Retry Date: ___________

---

## Overall Statistics

| Metric | Value |
|--------|-------|
| Total projects | 5 |
| Total time planned | 4-5 hours |
| Total time spent | ______ hours |
| CSV files ingested | 30 |
| Tables created | ~20 |
| Notebooks written | ~15 |
| Key concepts mastered | 8+ |

---

## Key Takeaways

What I learned about Databricks:
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________
4. _________________________________________________
5. _________________________________________________

What I'll use in real projects:
1. _________________________________________________
2. _________________________________________________
3. _________________________________________________

---

## Resources Used

- ✓ QUICK_START.md (Databricks free tier setup)
- ✓ All 5 project READMEs
- ✓ All schema.md files
- ✓ INDEX.md (quick reference)
- [ ] Databricks SQL Reference (https://docs.databricks.com/sql/)
- [ ] Unity Catalog Guide (https://docs.databricks.com/en/uc/)
- [ ] Exam Prep Guide (https://www.databricks.com/learn/training/databricks-certification-exam-preparation)

---

## Notes & Reflections

_____________________________________________________________________

_____________________________________________________________________

_____________________________________________________________________

_____________________________________________________________________

---

**Last Updated:** ____________  
**Next Review:** ____________
