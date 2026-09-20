# Crystal Lane — art attribution

All shipped art is **CC0 1.0 Universal** (public domain dedication).  
This project is **not affiliated with Nintendo, Game Freak, The Pokémon Company, Stick War, or Max Games.**  
No official Pokémon names, sprites, ROM dumps, or Nintendo CDN assets.

Credit is not required under CC0; we list authors because they asked nicely.

## Packs used

| Pack | Author | License | URL | Used for |
|------|--------|---------|-----|----------|
| **Kenney 1-Bit Pack** (1.2) | Kenney | CC0 | https://kenney.nl/assets/1-bit-pack | Lane décor (`assets/env/kenney_1bit_colored_packed.png`). |
| **FANTASY-crystal-set** | MELLE | CC0 | https://opengameart.org/content/fantasy-crystal-set | Blue LEFT / red RIGHT crystals. |
| **Kenney Shape Characters** | Kenney | CC0 | https://kenney.nl/assets/shape-characters | Kernel bodies + campaign `p01`–`p04`. |
| **Kenney UI Pack** (2.0) | Kenney | CC0 | https://kenney.nl/assets/ui-pack | HUD panels, buttons, Kenney Future fonts. |
| **Tiny Creatures** | Clint Bellanger / Kenney | CC0 | https://opengameart.org/content/tiny-creatures | `p05`–`p20`, `e01`–`e20`, Tidebound Colossus (`tile_0174.png`). |
| **Kenney Tiny Dungeon** | Kenney | CC0 | https://kenney.nl/assets/tiny-dungeon | `kenney_tiny_dungeon_packed.png` (env only). |
| **Kenney Toon Characters** | Kenney | CC0 | https://kenney.nl/assets/toon-characters | Veilpyre Sovereign (`boss_l20.png`). |
| **Kenney UI Pack RPG Expansion** | Kenney | CC0 | https://kenney.nl/assets/ui-pack-rpg-expansion | `assets/ui/menu/`, `assets/ui/meta/`. |
| **Kenney Animal Pack Redux** | Kenney | CC0 | https://opengameart.org/content/animal-pack-redux | Scouted; **not assigned** to P/E IDs (style reserve). |

Support Kenney: https://kenney.nl/donate · https://patreon.com/kenney

License copies: `assets/licenses/`. Unit map: [`UNITS_MANIFEST.md`](UNITS_MANIFEST.md).

### License files on disk

| File | Pack |
|------|------|
| `assets/licenses/kenney_1-bit-pack_License.txt` | 1-Bit Pack |
| `assets/licenses/kenney_shape-characters_License.txt` | Shape Characters |
| `assets/licenses/kenney_ui-pack_License.txt` | UI Pack |
| `assets/licenses/tiny-creatures_License.txt` | Tiny Creatures |
| `assets/licenses/kenney_tiny-dungeon_License.txt` | Tiny Dungeon |
| `assets/licenses/kenney_toon-characters_License.txt` | Toon Characters |
| `assets/licenses/kenney_ui-pack-rpg-expansion_License.txt` | UI Pack RPG Expansion |
| `assets/licenses/kenney_animal-pack-redux_License.txt` | Animal Pack Redux |

---

## Repo layout

```
assets/
  env/              Kenney 1-Bit + Tiny Dungeon
  crystals/         MELLE blue + red
  units/            Shape Characters (kernel faces / hands)
  units/player/     p01..p20.png
  units/enemy/      e01..e20.png (red tint)
  units/bosses/     Tidebound Colossus, Veilpyre Sovereign
  ui/               Kenney UI Pack HUD
  ui/menu/          RPG expansion (7)
  ui/meta/          locks, arrows (7)
  licenses/         upstream License.txt copies
  UNITS_MANIFEST.md
  ATTRIBUTION.md
```

## Kernel role mapping (arcade / Practice Lane)

| Role | Shape | P0 affinity | GDD v1.3.1 type | Creature |
|------|-------|-------------|-----------------|----------|
| Tank | square | Rock | Stone | Cragback |
| Melee | rhombus | Fighting | Strike | Knuckhorn |
| Ranged | circle | Psychic | Mind | Veilray |
| Support | squircle | Fairy | Bloom | Gleamlet |

## Counts (tonight)

| Category | Count |
|----------|-------|
| Player troops | **20** / 20 |
| Enemy troops | **20** / 20 |
| Bosses | **2** / 2 |
| Menu UI | 7 |
| Meta UI | 7 |

## Re-download

```bash
./scripts/download_cc0_assets.sh
```

## Not used (and not allowed)

- Official Pokémon sprites, names, cries, or lookalikes
- ROM dumps / spriters-resource rips / Nintendo CDN
- Stick War / Max Games rips
