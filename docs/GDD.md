# Crystal Lane — Game Design Document

**Version:** 1.3.3 (tip 3e24ccf QA — Must #1 still FAIL)  
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


---

---

## Appendix B — Kernel Must QA (latest)

### TesterBot 2026-09-21 · tip `3e24ccf` · tunnel validation-period-suspension-competitions
**Verdict: FAIL** — Must #1 pacing.

| Must | Status |
|------|--------|
| #1 Early Grace / Pressure Curve | **Verify → harden** — Campaign L1 blue dies before ~30s (need ~45–60s) |
| #2 Soft Tutor | Not reached (dies too fast) |
| #3 Kill Bounty | OK in Practice |
| #4 Affinity | (prior partial; not re-stamped Done) |

Also OK: Pulse, Practice Victory reachable, end-screen Menu/Select, HUD mostly OK (some 1–4 glyph ambiguity).  
**CodeBot:** harden Campaign Early Grace again before next export. Do not stamp Must #1 Done.


## Appendix C — Economy tables (ResearchBot lock, for CodeBot)

### Troop tier stats
| Tier | Mana | HP | DPS |
|------|------|----|-----|
| 1 | 12 | 80 | 8.0 |
| 2 | 17 | 97 | 9.7 |
| 3 | 25 | 120 | 12.0 |
| 4 | 37 | 149 | 14.9 |
| 5 | 53 | 181 | 18.1 |

Alive cap optional: **8 → 10 @ L10 → 12 @ L20**.

### Mana Lab (meta coins)
**Regen:** Lv1–7 buy costs 50 / 75 / 112 / 169 / 253 / 380 / 570 → regen 2.24…4.42/s (base 2.0).  
**Cap:** Lv1–7 buy costs 40 / 62 / 96 / 149 / 231 / 358 / 555 → cap 125…275 (`100+25*n`).

### Level clear coins (1★)
| L | Total | L | Total |
|---|-------|---|-------|
| 1 | 25 | 11 | 181 |
| 2 | 30 | 12 | 221 |
| 3 | 37 | 13 | 270 |
| 4 | 45 | 14 | 329 |
| 5 | 55 | 15 | 401 |
| 6 | 67 | 16 | 489 |
| 7 | 82 | 17 | 597 |
| 8 | 100 | 18 | 728 |
| 9 | 122 | 19 | 888 |
| **10** | **299** (149+150) | **20** | **1483** (1083+400) |

Campaign ~6.5k coins one-clear. Optional ★ bonus +10%/+25%/+40%.

Unlock troops: soft-ceiling `min(900, round(40*1.22^k))` (see App E). Deck slots stay level-gated (not coin).

---

## Appendix D — Wave bands (PvZ)

| Band | Lv | Waves | Flags | Lull | HP mult |
|------|----|-------|-------|------|---------|
| Teach | 1–3 | 3 | 0–1 | 8–10s | ×1.00–1.17 |
| Early | 4–6 | 4 | 1 | 7–8s | ×1.26–1.47 |
| Mid | 7–9 | 4–5 | 1–2 | 6–7s | ×1.59–1.85 |
| Boss | **10** | 5 | 2+boss | 5–6s | fodder×2.0 / boss×2.7 |
| Mid-late | 11–14 | 5 | 2 | 5–6s | ×2.16–2.72 |
| Late | 15–19 | 5–6 | 2–3 | 4–5s | ×2.94–4.00 |
| Finale | **20** | 6 | 3+boss | 4s | fodder×4.0 / boss×6.7 |

Template: Prep 12–20s → Wave (50% HP or 22–35s timeout) → Lull 4–10s → Huge flag prefers full clear.  
Fodder HP: `1.08^(L-1)`. Full L1/L10/L20 sketches in `research-campaign-v1.md`.

**Boss telegraphs:** L10 Tidebound Colossus — 66%/33% phases, slam 1.2s, brings Strike/Ember. L20 Veilpyre Sovereign — 70%/40%/15%, mist→nova, enrage t>180s.


---

## Appendix E — Full roster (ResearchBot v1 · DocumentBot economy lock)

**Source:** `research-roster-curriculum-v1.md`  
**Must #1–4:** untouched (TesterBot paused).  
**Names:** placeholders for CodeBot `UNITS_MANIFEST.md` mapping (CC0 art).

### Economy resolution (LOCKED)

Research’s raw `40*1.4^k` summed ≈ **21.7k** vs one-clear ≈ **6.5k**.  
**DocumentBot lock:** soft-ceiling unlocks so a one-clear path can buy a meaningful Barracks path and still fund Mana Lab:

`unlock_coin(k) = min(900, round(40 * 1.22^k))` for unlock order `k = 0…15`

Approx: **40, 49, 60, 73, 89, 108, 132, 161, 197, 240, 293, 357, 436, 532, 649, 792** (sum ≈ **4.2k**).  
★ bonuses / replays fund Mana Lab + optional full roster. Do **not** use uncapped 6223 late unlocks.

### Player roster (20)

| ID | Name | Type | Tier | Mana | Unlock |
|----|------|------|------|------|--------|
| P01 | Cragback | Stone | 1 | 12 | Start |
| P02 | Knuckhorn | Strike | 1 | 12 | Start |
| P03 | Veilray | Mind | 1 | 12 | Start |
| P04 | Gleamlet | Bloom | 1 | 12 | Start |
| P05 | Cindercurl | Ember | 2 | 17 | L2 |
| P06 | Brinefin | Tide | 2 | 17 | L3 |
| P07 | Petalward | Bloom | 2 | 17 | L4 |
| P08 | Rivetfist | Strike | 2 | 17 | L5 |
| P09 | Zephyrick | Gale | 3 | 25 | L6 |
| P10 | Boulderbrace | Stone | 3 | 25 | L7 |
| P11 | Cognivolt | Mind | 3 | 25 | L8 |
| P12 | Duskneedle | Shade | 3 | 25 | L9 |
| P13 | Pyremaw | Ember | 4 | 37 | L11 |
| P14 | Abysshell | Tide | 4 | 37 | L12 |
| P15 | Squallwing | Gale | 4 | 37 | L13 |
| P16 | Bloomspire | Bloom | 4 | 37 | L14 |
| P17 | Shatterjaw | Strike | 4 | 37 | L15 |
| P18 | Gravemaw | Stone | 5 | 53 | L16 |
| P19 | Nullwraith | Shade | 5 | 53 | L17 |
| P20 | Astralith | Mind | 5 | 53 | L19 |

L10 / L20 = deck slots (not troop unlocks). L18 = Lab / coin sink (no new troop).

### Enemy roster (20) — first appearance

| ID | Name | Type | Tier | First @ | Tag |
|----|------|------|------|---------|-----|
| E01 | Brawlgrub | Strike | 1 | L1 | Fodder |
| E02 | Graveltusk | Stone | 1 | L1 | Fodder |
| E03 | Sparkpup | Ember | 1 | L3 | Fodder |
| E04 | Softspore | Bloom | 1 | L3 | Fodder |
| E05 | Puddlefin | Tide | 1 | L4 | Fodder |
| E06 | Gustling | Gale | 1 | L5 | Fodder |
| E07 | Hexmite | Mind | 2 | L6 | Fodder |
| E08 | Cinderbrute | Ember | 2 | L5 | Elite |
| E09 | Ripcurrent | Tide | 2 | L6 | Elite |
| E10 | Cleaverkin | Strike | 2 | L7 | Elite |
| E11 | Bastionmite | Stone | 2 | L7 | Elite |
| E12 | Gloomwisp | Shade | 2 | L8 | Fodder |
| E13 | Vinewretch | Bloom | 3 | L9 | Elite |
| E14 | Deepmaw | Tide | 3 | L9 | Elite |
| E15 | Ashreaver | Ember | 3 | L11 | Elite |
| E16 | Psychospike | Mind | 3 | L12 | Elite |
| E17 | Cycloneer | Gale | 3 | L13 | Elite |
| E18 | Nightpiercer | Shade | 4 | L14 | Elite |
| E19 | Ironshard | Stone | 4 | L15 | Elite |
| E20 | Ragemaw | Strike | 4 | L16 | Elite |

**Bosses:** B01 Tidebound Colossus (L10 Tide/Stone) · B02 Veilpyre Sovereign (L20 Shade/Ember).

---

## Appendix F — L1–20 type-teaching curriculum

**Wave counts:** follow **Appendix D** bands (late 5–6 waves, not 5–7).

| Band | Levels | Teach |
|------|--------|-------|
| Force open | L1–2 | Strike/Stone fodder; starters |
| World open | L3–6 | Ember → Tide → Gale tutors; first unlocks |
| Force mid | L7–9 | Strike/Stone elites + Shade intro; pre-boss |
| Boss A | **L10** | Tidebound Colossus; unlock deck slot 5 |
| Mid-late | L11–14 | Ember/Tide heavy + Gale/Shade answers |
| Synergy | L15–19 | Mixed flags; T4–T5 unlocks |
| Finale | **L20** | Veilpyre Sovereign; unlock deck slot 6 |

Full per-level enemy lists / recommended answers: `research-roster-curriculum-v1.md` §3. CodeBot maps IDs → sprites in `UNITS_MANIFEST.md`.


---

## Tonight handoff (2026-09-20)

**User stop line:** complete through **asset scouting + full GDD docs**; continue build tomorrow. TesterBot remains paused.

| Doc | Status | Location |
|-----|--------|----------|
| GDD v1.3 | **Complete** for tonight | `docs/GDD.md` (chart, economy, waves, roster, curriculum, Must QA appendix) |
| Asset requirements v2 | **Complete** + named scouting checklist | `docs/ASSET_REQUIREMENTS_v2.md` |
| Research sources | Reference | `research-campaign-v1.md`, `research-roster-curriculum-v1.md` |

**Tomorrow:** CodeBot continues Early Grace → packs on disk → P1/P2; DocumentBot amends GDD only if build discovers gaps; TesterBot waits for explicit go.


---

## Implementation progress (CodeBot · 2026-09-21)

| Phase | Status | Notes |
|-------|--------|-------|
| P0 Early Grace | In tip | Softer waves on polish |
| P1 Menu / L1–3 | **Done** | Tip includes menu + campaign L1–3 |
| P2 Waves + Barracks | **Done** | P05–P08 unlockable; mana-only campaign + wave director |
| P3 Type chart | **Partial→wired** | 8-type chart live for Stone/Strike/Mind/Bloom starters |
| P4–P6 | **Open** | Full 20/20 combat, Mana Lab, bosses L10/L20, deck slots 5–6 |

**Build tip:** `63f7877` on polish branch (ahead of older export `ccdf42d`).

## Changelog

- **v1.3.3 (2026-09-21):** TesterBot tip `3e24ccf` FAIL — Must #1 Verify→harden (Campaign L1 <30s).
- **v1.3.2 (2026-09-21):** CodeBot P1–P3 on polish `63f7877`; P4–P6 still open.
- **v1.3.1 (2026-09-20):** Tonight handoff — full GDD + named asset scouting checklist; stop line for build resume tomorrow.
- **v1.3 (2026-09-20):** Roster 20+20+2 + L1–20 curriculum (App E/F); unlock soft-ceiling `min(900, round(40*1.22^k))` resolves 21.7k vs 6.5k; wave counts follow App D.
- **v1.2 (2026-09-20):** Folded ResearchBot economy + wave-band tables (App C/D) for CodeBot P2/P3; TesterBot paused per user.
- **v1.1.1 (2026-09-20):** TesterBot Must-build FAIL — Must #1 Verify→harden; #2–4 stay Implemented · pending QA (partial).
- **v1.1 (2026-09-20):** Stamped ResearchBot campaign lock — 8 types (Stone…Shade), ×1.5/0.5 matrix, mana/coin formulas, PvZ anchors, boss names; retired in-match gold for campaign; P3 unblocked.
- **v1.0:** Campaign expansion skeleton.
- **v0.2.x:** Fun-factor Must backlog / jam kernel.
