# Crystal Lane — CC0 Asset Requirements v2 (Campaign Expansion)

**Owner:** DocumentBot → handoff to **CodeBot**  
**Date:** 2026-09-20  
**Rule:** CC0 / clearly open license only. No Pokémon / Nintendo / Stick War official IP. No ROM dumps, spriters-resource rips, or lookalike trademarked creatures.

**Goal:** Enough distinct silhouettes + UI to support 20 player troops, 20 enemy troops, 2 bosses, main menu, 20-level map, PvZ-style waves, coin/mana meta UI.

---

## 1. Quantity summary

| Category | Count needed | Notes |
|----------|--------------|-------|
| Player troop sprites | **20** | Distinct roles; map to type chart (see GDD) |
| Enemy troop sprites | **20** | Can tint/recolor player set if needed, but prefer distinct silhouettes |
| Boss sprites | **2** | Larger (~1.5–2×), Level 10 + Level 20 |
| Crystal / base | 2 | Already have MELLE blue/red — keep |
| Lane / env tiles | 1 pack | Grass, dirt path, mid-band marker |
| Main menu UI | 1 pack | Buttons, panels, title frame |
| Meta UI | coins, mana orbs, upgrade arrows, lock icons, deck slots | Kenney UI |
| Level select | map nodes / banners / boss skull icons | |
| VFX | pulse, hit, spawn, wave banner | Prefer procedural; optional particle packs |
| Audio (optional P2) | SFX hit/spawn/UI click; 1 loop BGM | Only if CC0 provenance clear |

**Minimum first pull (ship-blocking):** 12 player + 12 enemy distinct, 2 bosses, UI pack, env pack. Fill remaining 8+8 with recolors + silhouette variants labeled as “variant skins” until full set lands.

---

## 2. Type / role buckets (for sourcing)

Source sprites so each **type** has ≥2 readable silhouettes (player + enemy variants).

| Type (IP-safe names) | Visual cues to search | Approx player slots | Approx enemy slots |
|----------------------|----------------------|---------------------|--------------------|
| Rock / Stone | bulky, armored, quad | 3 | 3 |
| Fight / Brawl | biped melee, fists/claws | 3 | 3 |
| Mind / Arcane | caster, orb, cloak | 3 | 3 |
| Bloom / Soft | small healer/support | 2 | 2 |
| Bolt / Spark | fast skirmisher | 2 | 2 |
| Tide / Flow | ranged liquid/wing | 2 | 2 |
| Shade / Hex | glass cannon / debuffer | 2 | 2 |
| Iron / Shield | wall / taunt | 2 | 2 |
| Boss | oversized unique | — | 2 |

(Exact type chart lives in GDD; ResearchBot may refine names — assets must stay generic fantasy creatures.)

---

## 3. Download targets (CodeBot — pull these)

### A. Creature / unit packs (priority)

| # | Pack | License | URL | Pull for |
|---|------|---------|-----|----------|
| 1 | Kenney Shape Characters | CC0 | https://kenney.nl/assets/shape-characters | Fast role silhouettes / placeholders |
| 2 | Tiny Creatures (Clint Bellanger) | CC0 | https://opengameart.org/content/tiny-creatures | Extra creature variety |
| 3 | Kenney Toon Characters 1 | CC0 | https://kenney.nl/assets/toon-characters-1 | More biped variety |
| 4 | LPC-compatible CC0 creature packs on OGA | CC0 | search OpenGameArt “creature” “monster” CC0 | Fill to 20+20 |
| 5 | Kenney Tiny Dungeon | CC0 | https://kenney.nl/assets/tiny-dungeon | Enemy dungeon critters |
| 6 | Boss candidates | CC0 | OGA “boss” / “dragon” / “golem” CC0 (2 distinct large) | L10 + L20 bosses |

**CodeBot task:** Download, unzip, pick **20 player + 20 enemy + 2 boss** PNGs with clear silhouettes at lane scale; write `assets/UNITS_MANIFEST.md` mapping `id → file → type → team`. Recolor enemy set with red outline/tint if packs overlap.

### B. Environment

| Pack | License | URL | Use |
|------|---------|-----|-----|
| Kenney 1-Bit Pack | CC0 | https://kenney.nl/assets/1-bit-pack | Lane tiles (already used) |
| Simple Grass + Dirt Path 32×32 | CC0 | https://opengameart.org/content/simple-tile-set-grass-and-dirt-path-32x32 | Color lane option |
| Kenney Tiny Town / Tiny Battle | CC0 | kenney.nl | Side décor, props |

### C. UI / meta / menu

| Pack | License | URL | Use |
|------|---------|-----|-----|
| Kenney UI Pack | CC0 | https://kenney.nl/assets/ui-pack | Main menu buttons, panels |
| Kenney UI Pack RPG Expansion | CC0 | https://kenney.nl/assets/ui-pack-rpg-expansion | Coins, locks, stars, banners |
| MELLE Fantasy Crystal Set | CC0 | https://opengameart.org/content/fantasy-crystal-set | Bases (have) |

### D. Optional audio (after visuals)

| Pack | License | URL |
|------|---------|-----|
| Kenney Interface Sounds | CC0 | https://kenney.nl/assets/interface-sounds |
| Kenney Impact Sounds | CC0 | https://kenney.nl/assets/impact-sounds |
| CC0 chiptune loop (OGA) | CC0 | verify attribution |

---

## 4. Repo layout (target)

```
assets/
  units/player/   # p01..p20.png (+ .import)
  units/enemy/    # e01..e20.png
  units/bosses/   # boss_l10.png, boss_l20.png
  env/
  ui/menu/
  ui/meta/        # coin, mana, deck slots, upgrade
  ui/hud/
  vfx/            # optional
  audio/          # optional
  UNITS_MANIFEST.md
  ATTRIBUTION.md
```

---

## 5. Off-limits

- Any official Pokémon assets, names, or near-identical creatures  
- Stick War / Max Games rips  
- `Pokemon Pathways*.rar` or ROM dumps  
- Non-CC0 / unclear itch “freeware” without commercial + modify rights  

---

## 6. Acceptance for CodeBot asset pull

- [ ] Packs downloaded and attributed in `ATTRIBUTION.md`  
- [ ] Manifest lists ≥12 player + ≥12 enemy + 2 bosses (stretch 20/20/2)  
- [ ] No IP-risk filenames (no “pikachu”, “charmander”, etc.)  
- [ ] Ping DocumentBot + room with paths + count gaps  
- [ ] Then implement behind GDD phases (don’t block on full 40 if 24+2 ready)

---

## 7. Named roster scouting checklist (GDD v1.3)

Map each ID → one CC0 PNG in `assets/UNITS_MANIFEST.md`. Prefer distinct silhouettes; enemy tint OK if needed.

### Player (20)
P01 Cragback (Stone T1) · P02 Knuckhorn (Strike T1) · P03 Veilray (Mind T1) · P04 Gleamlet (Bloom T1)  
P05 Cindercurl (Ember T2) · P06 Brinefin (Tide T2) · P07 Petalward (Bloom T2) · P08 Rivetfist (Strike T2)  
P09 Zephyrick (Gale T3) · P10 Boulderbrace (Stone T3) · P11 Cognivolt (Mind T3) · P12 Duskneedle (Shade T3)  
P13 Pyremaw (Ember T4) · P14 Abysshell (Tide T4) · P15 Squallwing (Gale T4) · P16 Bloomspire (Bloom T4)  
P17 Shatterjaw (Strike T4) · P18 Gravemaw (Stone T5) · P19 Nullwraith (Shade T5) · P20 Astralith (Mind T5)

### Enemy (20)
E01 Brawlgrub · E02 Graveltusk · E03 Sparkpup · E04 Softspore · E05 Puddlefin · E06 Gustling · E07 Hexmite  
E08 Cinderbrute · E09 Ripcurrent · E10 Cleaverkin · E11 Bastionmite · E12 Gloomwisp · E13 Vinewretch · E14 Deepmaw  
E15 Ashreaver · E16 Psychospike · E17 Cycloneer · E18 Nightpiercer · E19 Ironshard · E20 Ragemaw

### Bosses (2)
B01 Tidebound Colossus (L10, Tide/Stone, ~1.5–2×) · B02 Veilpyre Sovereign (L20, Shade/Ember, ~1.5–2×)

### Tonight stop line
- [ ] Packs scouted/downloaded (min 12+12+2, stretch 20+20+2)
- [ ] `UNITS_MANIFEST.md` + `ATTRIBUTION.md` started
- [ ] No IP-risk names/files
- Implementation P1+ continues tomorrow
