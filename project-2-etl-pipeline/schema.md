# Project 2: Schema Reference

## CSV Files Loaded to Bronze

### pokemon.csv → pokemon
| Column | Type | Rows |
|--------|------|------|
| id | int | 1,025 |
| identifier | string | Pokémon name |
| species_id | int | Species ID |
| height | int | Height in decimeters |
| weight | int | Weight in hectograms |
| base_experience | int | XP from battle |
| order | int | Sort order |
| is_default | int | 1 = default form |

### pokemon_types.csv → pokemon_types
| Column | Type | Rows |
|--------|------|------|
| pokemon_id | int | 1,681 |
| type_id | int | Type ID |
| slot | int | 1 or 2 (primary/secondary) |

### types.csv → types
| Column | Type | Rows |
|--------|------|------|
| id | int | 18 |
| identifier | string | Type name |
| generation_id | int | Intro generation |
| damage_class_id | int | Physical/Special/Status |

### pokemon_stats.csv → pokemon_stats
| Column | Type | Rows |
|--------|------|------|
| pokemon_id | int | 5,125 |
| stat_id | int | Stat ID (1-6) |
| base_stat | int | Base stat value |
| effort | int | EV yield |

### stat_names.csv → stat_names
| Column | Type | Rows |
|--------|------|------|
| stat_id | int | ~108 |
| language_id | int | 9=English |
| name | string | Stat name (HP, Attack, etc.) |

### type_efficacy.csv → type_efficacy
| Column | Type | Rows |
|--------|------|------|
| damage_type_id | int | 540 |
| target_type_id | int | Defending type |
| damage_factor | int | 0/50/100/200 |

### moves.csv → moves
| Column | Type | Rows |
|--------|------|------|
| id | int | 918 |
| identifier | string | Move name |
| generation_id | int | Intro generation |
| type_id | int | Move type |
| power | int | Move power |
| pp | int | Power points |
| accuracy | int | Accuracy % |

## Silver Tables (Cleansed)

### pokemon_clean
- Only default forms (`is_default = 1`)
- Deduplicated by ID
- ~1,025 rows

### pokemon_types_enriched
- Joins pokemon + types with names
- Ready for analysis
- ~1,681 rows

### pokemon_stats_enriched
- Stats with human-readable names
- English only
- ~5,125 rows

## Gold Tables (Analytics)

### type_metrics
- Aggregated by type
- Count of Pokémon per type
- Avg/min/max stats per type
- 18 rows (one per type)

### pokemon_summary
- Complete Pokémon profile
- All 6 stats denormalized
- Type array
- ~1,025 rows
