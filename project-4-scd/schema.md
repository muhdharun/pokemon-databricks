# Project 4: Schema Reference

## CSV Files

### pokemon_stats_past.csv → pokemon_stats_past (Bronze)
Contains historical stat data across generations
| Column | Type | Rows |
|--------|------|------|
| pokemon_id | int | Variable |
| stat_id | int | (1-6: HP, Atk, Def, SpA, SpD, Spe) |
| base_stat | int | Base stat value |
| generation_id | int | Game generation |

### pokemon_species.csv → pokemon_species (Bronze)
Pokémon species metadata
| Column | Type |
|--------|------|
| id | int |
| identifier | string |
| generation_id | int |
| evolves_from_species_id | int |

### pokemon_evolution.csv → pokemon_evolution (Bronze)
Evolution triggers and conditions
| Column | Type |
|--------|------|
| id | int |
| evolved_species_id | int |
| evolution_trigger_id | int |
| minimum_level | int |

## Silver SCD Dimension

### pokemon_stats_dimension (Type 2 SCD)
| Column | Type | Purpose |
|--------|------|---------|
| pokemon_id | int | FK: pokemon |
| pokemon_name | string | Denormalized name |
| stat_id | int | FK: stats (1-6) |
| stat_name | string | HP, Attack, Defense, etc. |
| base_stat | int | Stat value |
| generation_id | int | Game generation (partition key) |
| effective_date | date | When this stat became current |
| end_date | date | When this stat ended (9999-12-31 if current) |
| is_current | bool | TRUE if most recent |
| load_date | timestamp | ETL load timestamp |
| row_hash | string | MD5 hash for change detection |

**Partitioned by:** generation_id  
**Change Data Feed:** Enabled  

### Quick SCD Query
```sql
-- See all stat changes for a Pokémon
SELECT * FROM pokemon_stats_dimension
WHERE pokemon_name = 'bulbasaur'
ORDER BY stat_id, generation_id
```

## Time-Travel Examples

```sql
-- Query as of 1 hour ago
SELECT * FROM pokemon_stats_dimension
TIMESTAMP AS OF CURRENT_TIMESTAMP() - INTERVAL 1 HOUR;

-- Query first version
SELECT * FROM pokemon_stats_dimension VERSION AS OF 0;

-- Show all versions
DESCRIBE HISTORY pokemon_stats_dimension;
```
