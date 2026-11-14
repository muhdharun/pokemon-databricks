# Project 1: Schema Reference

## Bronze Tables (Raw Data)

### pokemon.csv → pokemon
| Column | Type | Description |
|--------|------|-------------|
| id | int | Unique Pokémon ID |
| identifier | string | Pokémon name (lowercase, no spaces) |
| species_id | int | Species reference |
| height | int | Height in decimeters |
| weight | int | Weight in hectograms |
| base_experience | int | XP earned when defeated |
| order | int | Sort order |
| is_default | int | 1 = default form, 0 = alternate form |

### pokemon_types.csv → pokemon_types
| Column | Type | Description |
|--------|------|-------------|
| pokemon_id | int | Pokémon ID (FK: pokemon.id) |
| type_id | int | Type ID (FK: types.id) |
| slot | int | Type order (1 = primary, 2 = secondary) |

### types.csv → types
| Column | Type | Description |
|--------|------|-------------|
| id | int | Unique type ID |
| identifier | string | Type name (e.g., "fire", "water") |
| generation_id | int | When type was introduced |
| damage_class_id | int | Physical, Special, Status |

### type_efficacy.csv → type_efficacy
| Column | Type | Description |
|--------|------|-------------|
| damage_type_id | int | Attacking type (FK: types.id) |
| target_type_id | int | Defending type (FK: types.id) |
| damage_factor | int | Effectiveness: 0=immune, 50=resist, 100=normal, 200=super-effective |

---

## Silver Tables (Cleaned)

### pokemon_types_clean
| Column | Type | Source |
|--------|------|--------|
| pokemon_id | int | pokemon.id |
| pokemon_name | string | pokemon.identifier |
| type_id | int | pokemon_types.type_id |
| type_name | string | types.identifier |
| type_slot | int | pokemon_types.slot |

**Filters Applied:**
- Only default Pokémon forms (`is_default = 1`)
- Cleaned duplicates

---

## Gold Tables (Insights)

### pokemon_type_coverage
| Column | Type | Description |
|--------|------|-------------|
| pokemon_id | int | Pokémon ID |
| pokemon_name | string | Pokémon name |
| total_resistances | int | Count of types this Pokémon resists/is immune to |
| immunity_count | int | Count of type immunities |
| resist_count | int | Count of type resistances |
| resisted_types | array | List of type names resisted |

**Calculation:**
- Counts incoming damage where `damage_factor <= 100` (resist or immune)
- Immune = `damage_factor = 0`
- Resist = `damage_factor < 100`

---

## Key Relationships

```
pokemon (1) ──── (M) pokemon_types
    ↓                    ↓
    └────────→ types ←───┘

types (1) ──── (M) type_efficacy (M) ──── (1) types
  (as target)              (as damage)
```

---

## Quick Queries

**Count rows in each table:**
```sql
SELECT 'pokemon' as table_name, COUNT(*) as row_count FROM pokemon_catalog.bronze.pokemon
UNION ALL
SELECT 'pokemon_types', COUNT(*) FROM pokemon_catalog.bronze.pokemon_types
UNION ALL
SELECT 'types', COUNT(*) FROM pokemon_catalog.bronze.types
UNION ALL
SELECT 'type_efficacy', COUNT(*) FROM pokemon_catalog.bronze.type_efficacy;
```

**Find Pokémon with multiple types:**
```sql
SELECT pokemon_name, COUNT(DISTINCT type_id) as type_count
FROM pokemon_catalog.silver.pokemon_types_clean
GROUP BY pokemon_name
HAVING COUNT(DISTINCT type_id) > 1
ORDER BY type_count DESC;
```

**List all type matchups:**
```sql
SELECT 
  d.identifier as attacking_type,
  t.identifier as defending_type,
  te.damage_factor as effectiveness
FROM pokemon_catalog.bronze.type_efficacy te
INNER JOIN pokemon_catalog.bronze.types d ON te.damage_type_id = d.id
INNER JOIN pokemon_catalog.bronze.types t ON te.target_type_id = t.id
LIMIT 10;
```
