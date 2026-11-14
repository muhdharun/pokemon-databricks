# Pokémon Databricks Learning Projects

A series of 5 focused, time-boxed projects designed to master Databricks for the **Data Engineering Associate Certification**. Each project (30 mins to 2 hours) covers specific Databricks features using Pokémon-themed datasets.

## Quick Facts
- **Target Audience:** Data engineers familiar with SQL, Iceberg/Polaris, and catalog concepts
- **Time Commitment:** ~6-8 hours total for all 5 projects
- **Databricks Tier:** Free (Community Edition)
- **Data Source:** Pokémon API datasets (187 CSV files covering Pokémon, types, stats, moves, abilities, etc.)

## Projects Overview

| Project | Focus | Time | Key Databricks Features |
|---------|-------|------|------------------------|
| **1. Type Coverage** | Basic ingest & medallion architecture | 45 min - 1 hr | Unity Catalog, Delta Lake, medallion layers |
| **2. ETL Pipeline** | Multi-table ETL with data quality & jobs | 1-1.5 hrs | Medallion (full), Jobs, orchestration, quality checks |
| **3. Governance** | Permissions, RBAC, row-level security | 1 hr | Unity Catalog governance, RBAC, column/row-level access |
| **4. SCD & Incremental** | Type 2 SCD, Merge, time-travel | 1-1.5 hrs | Slowly Changing Dimensions, MERGE, versioning, lineage |
| **5. Optimization** | Query tuning, partitioning, Z-ordering | 30-45 min | Partitioning, Z-ordering, query optimization, cost |

## Architecture Overview

```
Bronze Layer (Raw)
    ↓ (ETL)
Silver Layer (Clean, validated)
    ↓ (Transform)
Gold Layer (Analysis-ready)
    ↓ (Query)
Insights & Reports
```

Each project builds on previous learnings:
- **Project 1** → Foundation (basic ingest, medallion intro)
- **Project 2** → Advanced medallion (full flow, jobs, quality)
- **Project 3** → Governance (security, permissions, compliance)
- **Project 4** → Advanced patterns (SCD, Merge, time-travel)
- **Project 5** → Performance (optimization, cost)

## Before You Start

### Prerequisites
- Databricks free tier account (https://databricks.com/try)
- Basic SQL knowledge
- Familiarity with ETL/medallion concepts
- Python or SQL notebook editing comfort

### Setup
1. Clone this repo
2. Read `QUICK_START.md` for free-tier setup
3. Start with Project 1

## Folder Structure
```
pokemon-databricks/
├── README.md (you are here)
├── QUICK_START.md (setup guide)
├── project-1-type-coverage/
├── project-2-etl-pipeline/
├── project-3-governance/
├── project-4-scd/
└── project-5-optimization/
```

Each project folder contains:
- **README.md** - Project goals, step-by-step UI instructions, learning outcomes
- **data/** - Required CSV files (pre-copied from pokeapi)
- **notebooks/** - Python/SQL templates to accelerate implementation
- **schema.md** - Table definitions and relationships
- Additional files (job configs, permission scripts, etc.)

## Key Concepts You'll Learn

✓ **Delta Lake** - ACID transactions, time-travel, optimization  
✓ **Medallion Architecture** - Bronze→Silver→Gold best practices  
✓ **Unity Catalog** - Tables, schemas, catalogs, ownership  
✓ **RBAC & Governance** - Permissions, row/column-level security  
✓ **Slowly Changing Dimensions** - Type 2 SCD, Merge operations  
✓ **Databricks Jobs** - Orchestration, scheduling, parameterization  
✓ **Query Optimization** - Partitioning, Z-ordering, caching  
✓ **Data Quality** - Validation, deduplication, cleanliness checks  

## Certification Alignment

These projects prepare you for **Databricks Data Engineering Associate** exam by covering:
- Delta Lake fundamentals and advanced features
- ETL/ELT pipeline design and implementation
- Data governance and security
- SQL transformations and analytics
- Databricks platform architecture
- Performance tuning and optimization

## Time Management Tips

Since you have limited time:
1. Use notebook templates provided (saves 20+ mins per project)
2. Don't memorize Databricks UI—just follow the step-by-step guides in each README
3. Copy-paste SQL/Python from templates; focus on *understanding* the logic
4. Skim optional sections (marked [OPTIONAL] in READMEs)
5. Run one project per sitting (don't try to do all 5 in one day)

## Next Steps

👉 **Start here:** Read `QUICK_START.md`, then open `project-1-type-coverage/README.md`

## Resources

- [Databricks Free Tier Guide](https://databricks.com/try)
- [Databricks SQL Reference](https://docs.databricks.com/sql/)
- [Unity Catalog Guide](https://docs.databricks.com/en/uc/)
- [Exam Preparation Guide](https://www.databricks.com/learn/training/databricks-certification-exam-preparation)

---

**Last Updated:** 2024  
**Status:** Ready to use  
**Version:** 1.0
