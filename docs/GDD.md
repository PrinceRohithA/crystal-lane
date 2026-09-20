# Crystal Lane — Game Design Document

**Version:** 1.1 (Campaign numbers LOCKED)  
**Owner:** DocumentBot  
**Date:** 2026-09-20 (Asia/Calcutta)  
**Repo:** https://github.com/PrinceRohithA/crystal-lane  
**Engine:** Godot 4.3 · Web (HTML5) · **CC0 assets only**  
**Research:** `/workspace/crystal-lane/research-campaign-v1.md` (ResearchBot)  
**Live tunnel (prototype):** https://solutions-ceremony-continued-south.trycloudflare.com  

**Pillars:** Fun first · meaningful type matchups · CC0 / original creatures only · **no official Pokémon IP**.

---

## 0. Product vision

Evolve the Stick War–style lane prototype into a **campaign lane-defender** with:

- 20 player + 20 enemy troops + 2 bosses
- Locked **8-type** chart (IP-safe names)
- **PvZ-style waves** across **20 levels** (bosses @ 10 & 20)
- **Global coins** (meta) vs **mana-only** in battle
- Deck **4 → 5 @ L10 → 6 @ L20**
- Exponential mana / unlock / meta curves

Prototype kernel (lane combat, Type Pulse, soft tutor) remains the ship baseline. **Retire in-match gold / kill bounty** for campaign mode (mana-only deploys + Pulse).

---

## 1. Elevator pitch

Defend your blue crystal across 20 wave-based levels. Build a deck of up to 6 troops, spend **mana** in battle to deploy them, and use type advantage to carve through escalating enemy waves. Between levels, spend **global coins** to unlock troops and upgrade mana regen / cap. Clear waves (and bosses at 10 & 20) to advance.

---

## 2. Modes & flow

```
Main Menu
  → Continue / New Campaign
  → Troop Barracks (unlock / view roster)
  → Mana Lab (upgrade max mana + regen — meta)
  → Settings / Credits (CC0 attribution)
  → Level Select (1–20)
       → Pre-level Deck Build (4–6 slots)
            → Battle (mana only)
                 → Victory / Defeat → coins → map
```

Main menu: Play, Barracks, Mana Lab, Credits/Attribution, Quit.

---

## 3. Combat kernel

| Element | Spec |
|---------|------|
| Lane | Single 2.5D; player left / enemy right |
| Win | Clear all waves (boss levels: defeat boss wave) and/or crystal rules per level |
| Lose | Player crystal 0 HP |
| In-battle currency | **Mana only** (deploys + Type Pulse). No gold in-match |
| Field cap | Balance TBD (~8–12 alive) |
| Signature spell | Type Pulse (early unlock) |

---

## 4. Type chart — LOCKED (8 types)

**IDs:** STN Stone · STR Strike · MND Mind · BLM Bloom · EMB Ember · TID Tide · GAL Gale · SHD Shade  

**Multipliers:** Super **×1.5** · Neutral **×1** · Resist **×0.5** · no immunities.  
**Rule:** If A is Super vs B, then B vs A is Resist.

### Teach cycles
1. **World ring:** Ember → Bloom → Tide → Gale → Ember  
2. **Force ring:** Strike → Stone → Shade → Mind → Strike  

### Super summary

| Attacker | Super (×1.5) vs | Weak to (takes ×1.5) |
|----------|-----------------|----------------------|
| Ember | Bloom, Stone | Gale, Mind |
| Bloom | Tide, Shade | Ember, Strike |
| Tide | Gale, Mind | Bloom, Stone |
| Gale | Ember, Strike | Tide, Shade |
| Strike | Stone, Bloom | Gale, Mind |
| Stone | Shade, Tide | Ember, Strike |
| Shade | Mind, Gale | Bloom, Stone |
| Mind | Strike, Ember | Tide, Shade |

Each type: exactly **2** strengths and **2** weaknesses.

### Full matrix (rows = attacker, cols = defender)

`S` = ×1.5, `R` = ×0.5, `.` = ×1

```
     STN STR MND BLM EMB TID GAL SHD
STN   .   R   .   .   R   S   .   S
STR   S   .   R   S   .   .   R   .
MND   .   S   .   .   S   R   .   R
BLM   .   R   .   .   R   S   .   S
EMB   S   .   R   S   .   .   R   .
TID   R   .   S   R   .   .   S   .
GAL   .   S   .   .   S   R   .   R
SHD   R   .   S   R   .   .   S   .
```

### Jam remap
Rock/Fighting/Psychic/Fairy → Stone/Strike/Mind/Bloom. Volt/Steel cut (use Gale/Tide/Stone fantasy instead).

### Boss dual-types
- **L10 Tidebound Colossus:** Tide / Stone  
- **L20 Veilpyre Sovereign:** Shade / Ember  

Primary-vs-primary for dual-type resolution in v1 (same as GDD v1.0 simplify rule) unless CodeBot implements dual averaging later.

### Roster weight (P+E = 20+20)

| Type | Player | Enemy |
|------|--------|-------|
| Stone | 3 | 3 |
| Strike | 3 | 3 |
| Mind | 3 | 2 |
| Bloom | 3 | 2 |
| Ember | 2 | 3 |
| Tide | 2 | 3 |
| Gale | 2 | 2 |
| Shade | 2 | 2 |

Starters: Stone / Strike / Mind / Bloom (teach Force + soft support).

---

## 5. Economy — LOCKED formulas

### In-match mana
- `start_mana = 40`
- `base_regen = 2 / s`
- `base_cap = 100`
- Deploy + Pulse spend mana only

**Troop deploy mana (tier t = 1…):**  
`troop_mana(t) = round(12 * 1.45^(t-1))` → 12 / 17 / 25 / 37 / 53 …

**HP/DPS scale:** `*(cost/12)^0.55` (sublinear so expensive ≠ always best)

### Meta coins (outside battle)
**Mana Lab regen upgrade n:** `regen_coin(n) = round(50 * 1.50^n)`  
**Mana Lab cap upgrade n:** `cap_coin(n) = round(40 * 1.55^n)`  

**Level clear coins:**  
`level_coins(L) = round(25 * 1.22^(L-1))`  
+ boss bonus **150 @ L10** / **400 @ L20**

Troop unlock coin costs: geometric (CodeBot may use `round(50 * 1.35^(t-1))` or align to ResearchBot spreadsheet in research-campaign-v1.md).

### Retire
In-match gold + kill bounty gold in campaign mode. Optional post-level coin crumb OK.

---

## 6. Waves (PvZ-style) — LOCKED pacing notes

| Concept | Spec |
|---------|------|
| Wave banner | “Wave N / M” + ~1.5s pause |
| Between waves | ~3–5s lull |
| Flag / huge wave | Denser; boss levels replace finale |

**Anchors:**
- **L1:** 3 waves — teach Strike / Stone  
- **L10:** 5 waves + 2 huge flags — **Tidebound Colossus**  
- **L20:** 6 waves + 3 flags + enrage — **Veilpyre Sovereign**  

Default band: L1–9 → 3–5 waves · L11–19 → 5–7 waves. Full per-level tables in `research-campaign-v1.md`.

---

## 7. Deck system

| Rule | Spec |
|------|------|
| Max carry | **6** |
| Start | **4** slots |
| Clear L10 | Unlock **5th** |
| Clear L20 | Unlock **6th** |
| Fill from | Owned roster only |

---

## 8. Rosters & bosses

- **20** player unlockable · **20** enemy types · **2** bosses  
- Interim milestone: 15/15 OK before full 20/20  
- Asset min pull: 12+12+2 (see `docs/ASSET_REQUIREMENTS_v2.md`)  
- Update type bucket names in asset reqs to Stone/Strike/Mind/Bloom/Ember/Tide/Gale/Shade

---

## 9. Phased delivery

| Phase | Scope | Exit |
|-------|-------|------|
| **P0** | Kernel + Must QA | TesterBot stamp |
| **P1** | Main menu + Level Select (L1–3 stub) | Click-to-battle |
| **P2** | Wave director + coins + Barracks (8 troops) | 3-level loop |
| **P3** | Wire **this** 8×8 chart + mana formulas | Matchups meaningful |
| **P4** | Toward 15/15 + Mana Lab | Milestone |
| **P5** | 20/20 + Boss L10 | Mid campaign |
| **P6** | Boss L20 + deck 5–6 + polish | Complete |

**P3 gate:** Chart + formulas in this GDD are **stamped** — CodeBot may wire (do not invent alternate chart).

---

## 10. Assets

See `docs/ASSET_REQUIREMENTS_v2.md`. CC0 only. CodeBot: Kenney + OGA → `UNITS_MANIFEST.md` + `ATTRIBUTION.md`.

---

## 11. Non-goals

Official Pokémon IP · capture/Pokédex · multiplayer · multi-lane · inventing a different type chart at P3 · shipping all 40 units before P1 menu.

---

## 12. Team

| Role | Agent |
|------|--------|
| GDD | **DocumentBot** |
| Campaign numbers | ResearchBot (`research-campaign-v1.md`) |
| Build / assets | CodeBot |
| QA | TesterBot |
| PM | ProjectBot |

---

## 13. Success criteria

- [ ] Menu → L1 waves playable  
- [ ] Mana-only battle; coins meta  
- [ ] Stamped 8-type chart changes outcomes  
- [ ] Deck 4 / 5@L10 / 6@L20  
- [ ] 20 levels; bosses at 10 & 20 named above  
- [ ] CC0 attribution  
- [ ] Roster 20/20+2 (15/15 interim OK)

---

## Changelog

- **v1.1 (2026-09-20):** Stamped ResearchBot campaign lock — 8 types (Stone…Shade), ×1.5/0.5 matrix, mana/coin formulas, PvZ anchors, boss names; retired in-match gold for campaign; P3 unblocked.
- **v1.0:** Campaign expansion skeleton.
- **v0.2.x:** Fun-factor Must backlog / jam kernel.
