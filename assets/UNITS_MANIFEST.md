# Crystal Lane — unit sprite manifest

**GDD lock:** v1.3.1 Appendix E (`docs/GDD.md`)  
**Named checklist:** `docs/ASSET_REQUIREMENTS_v2.md` §7  
**On-disk:** **20 player + 20 enemy + 2 bosses** (min 12+12+2 met; stretch 20/20/2 landed)  
**License:** CC0 only. Original names. No Pokémon / Nintendo / ROM art.

**Types (GDD v1.3.1):** STN Stone · STR Strike · MND Mind · BLM Bloom · EMB Ember · TID Tide · GAL Gale · SHD Shade

Kernel combat still uses four roles + P0 Rock/Fighting/Fairy/Psychic affinity. The 8×8 chart lives in `scripts/gdd_balance.gd` and is **not yet applied to damage** (P3, tomorrow).

`scripts/roster.gd` still carries the interim 12+12 names from the first pull. **This manifest is the Appendix E lock.** Do not wire p13–p20 / e13–e20 into combat tonight.

---

## Pack counts

| Pack | Curated files | Role | License | Source |
|------|---------------|------|---------|--------|
| Kenney Shape Characters | 4 player (`p01`–`p04`) | Starters | CC0 | https://kenney.nl/assets/shape-characters |
| Tiny Creatures (Clint Bellanger / Kenney) | 16 player + 20 enemy + B01 | Roster + L10 boss | CC0 | https://opengameart.org/content/tiny-creatures |
| Kenney Toon Characters | 1 robot idle | B02 Veilpyre Sovereign | CC0 | https://kenney.nl/assets/toon-characters |
| Kenney Tiny Dungeon | env tilesheet | Lane décor | CC0 | https://kenney.nl/assets/tiny-dungeon |
| Kenney UI Pack RPG Expansion | 7 menu + 7 meta | Title / locks | CC0 | https://kenney.nl/assets/ui-pack-rpg-expansion |
| Kenney Animal Pack Redux | 0 roster (license on disk) | Reserved variant skins | CC0 | https://opengameart.org/content/animal-pack-redux |
| Kenney 1-Bit + UI Pack + MELLE | kernel | Lane, HUD, crystals | CC0 | see `ATTRIBUTION.md` |

**On-disk:** player **20** · enemy **20** · bosses **2** · `ui/menu` **7** · `ui/meta` **7**

Refresh:

```bash
./scripts/download_cc0_assets.sh
```

Tiles are 1-indexed (`tile_0001.png` = sheet cell 0). Curator: `scripts/curate_campaign_sprites.py`.

---

## Player (`assets/units/player/`)

Unlock coins: `min(900, round(40 * 1.22^k))` for unlock order `k = 0…15` (GDD App E). Starters have no coin cost.

| ID | file | name | type | tier | mana | unlock | pack | source tile / file |
|----|------|------|------|------|------|--------|------|--------------------|
| P01 | `p01.png` | Cragback | STN Stone | 1 | 12 | Start | Shape | `blue_body_square.png` |
| P02 | `p02.png` | Knuckhorn | STR Strike | 1 | 12 | Start | Shape | `blue_body_rhombus.png` |
| P03 | `p03.png` | Veilray | MND Mind | 1 | 12 | Start | Shape | `blue_body_circle.png` |
| P04 | `p04.png` | Gleamlet | BLM Bloom | 1 | 12 | Start | Shape | `blue_body_squircle.png` |
| P05 | `p05.png` | Cindercurl | EMB Ember | 2 | 17 | L2 / 40 | Tiny Creatures | `tile_0004.png` ×4 |
| P06 | `p06.png` | Brinefin | TID Tide | 2 | 17 | L3 / 49 | Tiny Creatures | `tile_0061.png` ×4 |
| P07 | `p07.png` | Petalward | BLM Bloom | 2 | 17 | L4 / 60 | Tiny Creatures | `tile_0012.png` ×4 |
| P08 | `p08.png` | Rivetfist | STR Strike | 2 | 17 | L5 / 73 | Tiny Creatures | `tile_0022.png` ×4 |
| P09 | `p09.png` | Zephyrick | GAL Gale | 3 | 25 | L6 / 89 | Tiny Creatures | `tile_0011.png` ×4 |
| P10 | `p10.png` | Boulderbrace | STN Stone | 3 | 25 | L7 / 108 | Tiny Creatures | `tile_0118.png` ×4 |
| P11 | `p11.png` | Cognivolt | MND Mind | 3 | 25 | L8 / 132 | Tiny Creatures | `tile_0067.png` ×4 |
| P12 | `p12.png` | Duskneedle | SHD Shade | 3 | 25 | L9 / 161 | Tiny Creatures | `tile_0005.png` ×4 |
| P13 | `p13.png` | Pyremaw | EMB Ember | 4 | 37 | L11 / 197 | Tiny Creatures | `tile_0034.png` ×4 |
| P14 | `p14.png` | Abysshell | TID Tide | 4 | 37 | L12 / 240 | Tiny Creatures | `tile_0050.png` ×4 |
| P15 | `p15.png` | Squallwing | GAL Gale | 4 | 37 | L13 / 293 | Tiny Creatures | `tile_0144.png` ×4 |
| P16 | `p16.png` | Bloomspire | BLM Bloom | 4 | 37 | L14 / 357 | Tiny Creatures | `tile_0114.png` ×4 |
| P17 | `p17.png` | Shatterjaw | STR Strike | 4 | 37 | L15 / 436 | Tiny Creatures | `tile_0016.png` ×4 |
| P18 | `p18.png` | Gravemaw | STN Stone | 5 | 53 | L16 / 532 | Tiny Creatures | `tile_0166.png` ×4 |
| P19 | `p19.png` | Nullwraith | SHD Shade | 5 | 53 | L17 / 649 | Tiny Creatures | `tile_0031.png` ×4 |
| P20 | `p20.png` | Astralith | MND Mind | 5 | 53 | L19 / 792 | Tiny Creatures | `tile_0059.png` ×4 |

Type weight: Stone 3 · Strike 3 · Mind 3 · Bloom 3 · Ember 2 · Tide 2 · Gale 2 · Shade 2.

P2 Barracks (tomorrow) can unlock **P01–P08**. P09–P20 stay gallery-only until P4/P5.

---

## Enemy (`assets/units/enemy/`) — red-tinted ×4

| ID | file | name | type | tier | first @ | tag | source tile |
|----|------|------|------|------|---------|-----|-------------|
| E01 | `e01.png` | Brawlgrub | STR Strike | 1 | L1 | Fodder | `tile_0009.png` |
| E02 | `e02.png` | Graveltusk | STN Stone | 1 | L1 | Fodder | `tile_0158.png` |
| E03 | `e03.png` | Sparkpup | EMB Ember | 1 | L3 | Fodder | `tile_0028.png` |
| E04 | `e04.png` | Softspore | BLM Bloom | 1 | L3 | Fodder | `tile_0014.png` |
| E05 | `e05.png` | Puddlefin | TID Tide | 1 | L4 | Fodder | `tile_0063.png` |
| E06 | `e06.png` | Gustling | GAL Gale | 1 | L5 | Fodder | `tile_0141.png` |
| E07 | `e07.png` | Hexmite | MND Mind | 2 | L6 | Fodder | `tile_0006.png` |
| E08 | `e08.png` | Cinderbrute | EMB Ember | 2 | L5 | Elite | `tile_0046.png` |
| E09 | `e09.png` | Ripcurrent | TID Tide | 2 | L6 | Elite | `tile_0047.png` |
| E10 | `e10.png` | Cleaverkin | STR Strike | 2 | L7 | Elite | `tile_0021.png` |
| E11 | `e11.png` | Bastionmite | STN Stone | 2 | L7 | Elite | `tile_0128.png` |
| E12 | `e12.png` | Gloomwisp | SHD Shade | 2 | L8 | Fodder | `tile_0018.png` |
| E13 | `e13.png` | Vinewretch | BLM Bloom | 3 | L9 | Elite | `tile_0035.png` |
| E14 | `e14.png` | Deepmaw | TID Tide | 3 | L9 | Elite | `tile_0062.png` |
| E15 | `e15.png` | Ashreaver | EMB Ember | 3 | L11 | Elite | `tile_0040.png` |
| E16 | `e16.png` | Psychospike | MND Mind | 3 | L12 | Elite | `tile_0066.png` |
| E17 | `e17.png` | Cycloneer | GAL Gale | 3 | L13 | Elite | `tile_0039.png` |
| E18 | `e18.png` | Nightpiercer | SHD Shade | 4 | L14 | Elite | `tile_0002.png` |
| E19 | `e19.png` | Ironshard | STN Stone | 4 | L15 | Elite | `tile_0048.png` |
| E20 | `e20.png` | Ragemaw | STR Strike | 4 | L16 | Elite | `tile_0104.png` |

Type weight: Stone 3 · Strike 3 · Mind 2 · Bloom 2 · Ember 3 · Tide 3 · Gale 2 · Shade 2.

All enemy tiles are Tiny Creatures, nearest-neighbor ×4, red tint (`scripts/curate_campaign_sprites.py`).

---

## Bosses (`assets/units/bosses/`)

| ID | file | name | types | size | pack | source |
|----|------|------|-------|------|------|--------|
| B01 | `boss_l10.png` | Tidebound Colossus | TID / STN | 128×128 (tile ×8) | Tiny Creatures | `tile_0174.png` (whale) |
| B02 | `boss_l20.png` | Veilpyre Sovereign | SHD / EMB | 120×160 | Toon Characters | `character_robot_idle.png` |

Not spawned until P5/P6.

---

## Type coverage (player + enemy silhouettes)

Each GDD type has ≥2 player + ≥2 enemy tiles (checklist §2).

| Type | Player IDs | Enemy IDs |
|------|------------|-----------|
| Stone | P01 P10 P18 | E02 E11 E19 |
| Strike | P02 P08 P17 | E01 E10 E20 |
| Mind | P03 P11 P20 | E07 E16 |
| Bloom | P04 P07 P16 | E04 E13 |
| Ember | P05 P13 | E03 E08 E15 |
| Tide | P06 P14 | E05 E09 E14 |
| Gale | P09 P15 | E06 E17 |
| Shade | P12 P19 | E12 E18 |

---

## Gaps / deferred

- **Kenney Animal Pack Redux:** unzipped under the pull cache; **0 files copied into `units/`**. Cartoon round/square animals clash with 16px lane sprites. Keep as variant-skin reserve (P4+).
- **Kenney Tiny Dungeon creature tiles:** not used on the roster (ID collisions with Tiny Creatures `tile_NNNN.png`). Env tilesheet only.
- **`scripts/roster.gd`:** still 12+12 interim names. Remap to this table tomorrow with P1/P2 — do not treat the GDScript list as SoT tonight.

---

## Off-limits

Pokémon names/sprites · Nintendo CDN · ROM dumps · Stick War rips · `Pokemon Pathways*.rar`

```bash
./scripts/download_cc0_assets.sh
```
