# Crystal Lane — art attribution

All shipped art is **CC0 1.0 Universal** (public domain dedication).  
This project is **not affiliated with Nintendo, Game Freak, The Pokémon Company, Stick War, or Max Games.**  
No official Pokémon names, sprites, ROM dumps, or Nintendo CDN assets.

## Packs used

| Pack | Author | License | URL | Used for |
|------|--------|---------|-----|----------|
| **Kenney 1-Bit Pack** (1.2) | Kenney (www.kenney.nl) | CC0 | https://kenney.nl/assets/1-bit-pack | Lane décor: trees, grass tufts, fences, plants (atlas `assets/env/kenney_1bit_colored_packed.png`). Monochrome sheet kept for HUD chrome. |
| **FANTASY-crystal-set** | MELLE (Melissa Krautheim) | CC0 | https://opengameart.org/content/fantasy-crystal-set | `crystal_blue.png` → player crystal (LEFT). `crystal_red.png` → enemy crystal (RIGHT). |
| **Kenney Shape Characters** (1.0) | Kenney (www.kenney.nl) | CC0 | https://kenney.nl/assets/shape-characters | Unit bodies, faces, hands. Square → Tank/Rock, rhombus → Melee/Fighting, circle → Ranged/Psychic, squircle → Support/Fairy. Blue = player, red = enemy. |
| **Kenney UI Pack** (2.0) | Kenney (www.kenney.nl) | CC0 | https://kenney.nl/assets/ui-pack | HUD panels, spawn/spell buttons, gold/mana/HP bars, gold star, Kenney Future fonts. |

Support Kenney: https://kenney.nl/donate · https://patreon.com/kenney  
Credit is not required under CC0; we list authors here because they asked nicely.

## Repo layout

```
assets/
  env/          Kenney 1-Bit packed tilesheets (16×16, 49×22)
  crystals/     MELLE blue + red gems
  units/        Shape Characters bodies / faces / hands
  ui/           Kenney UI Pack buttons, bars, fonts
  licenses/     Upstream License.txt copies
  placeholders/ Geometric Godot fallbacks (still in scripts)
  ATTRIBUTION.md
```

## Role mapping (original names only)

| Role | Shape | Face | Hands | Creature name |
|------|-------|------|-------|----------------|
| Tank / Rock | square | e | closed | Cragback |
| Melee / Fighting | rhombus | g | rock | Knuckhorn |
| Ranged / Psychic | circle | i | open | Veilray |
| Support / Fairy | squircle | c | peace | Gleamlet |

## Re-download

If you need to refresh the files:

```bash
./scripts/download_cc0_assets.sh
```

Primary URLs are Kenney.nl zip links and OpenGameArt PNG links. Geometric `_draw()` placeholders remain as a fallback if a texture fails to load.

## Not used (and not allowed)

- Official Pokémon sprites, names, cries, or lookalikes
- `Pokemon Pathways 9.1.3 Alpha Release.rar` / ROM dumps / spriters-resource Gen 1 rips
- Nintendo CDN
- Tiny Creatures (Clint Bellanger) — optional alt on the download list; Shape Characters covers MVP
