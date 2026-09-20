# Crystal Lane — Game Design Document

**Version:** 1.0 (Campaign Expansion)  
**Owner:** DocumentBot  
**Date:** 2026-09-20 (Asia/Calcutta)  
**Repo:** https://github.com/PrinceRohithA/crystal-lane  
**Engine:** Godot 4.3 · Web (HTML5) · **CC0 assets only**  
**Live tunnel (prototype):** https://solutions-ceremony-continued-south.trycloudflare.com  

**Pillars:** Fun first · meaningful type matchups · CC0 / original creatures only · **no official Pokémon IP**.

---

## 0. Product vision

Evolve the Stick War–style lane prototype into a **campaign lane-defender** with:

- Large unlockable troop roster (player + enemy)
- A real **type chart** (Pokémon-*inspired*, original type names)
- **Plants vs Zombies–style waves** across **20 levels**
- Bosses at **Level 10** and **Level 20**
- **Global coins** (meta) vs **mana-only** in battle
- Deck building with slot unlocks
- Exponential cost / power curves

Prototype v0.2.x (4 roles, Pulse, bounty, tutor, affinity) remains the **combat kernel** and ship baseline.

---

## 1. Elevator pitch

Defend your blue crystal across 20 wave-based levels. Build a deck of up to 6 troops, spend **mana** in battle to deploy them on a single lane, and use type advantage to carve through escalating enemy waves. Between levels, spend **global coins** to unlock troops and upgrade your mana capacity / regen. Shatter the red crystal (or clear the final boss wave) to win the stage.

---

## 2. Modes & flow

```
Main Menu
  → Continue / New Campaign
  → Troop Barracks (unlock / view roster)
  → Mana Lab (upgrade max mana + regen — meta)
  → Settings / Credits (CC0 attribution)
  → Level Select (1–20, locked until previous cleared)
       → Pre-level Deck Build (4–6 slots)
            → Battle (mana only)
                 → Victory / Defeat → coins → back to map
```

### Main menu (new)

Must include: Play, Barracks, Mana Lab, Credits/Attribution, Quit. Title art uses CC0 crystals + lane mock; no Nintendo marks.

---

## 3. Combat kernel (inherits prototype)

| Element | Spec |
|---------|------|
| Lane | Single 2.5D side lane; player left / enemy right |
| Win | Enemy crystal 0 HP **or** final wave cleared (level rules) |
| Lose | Player crystal 0 HP |
| In-battle currency | **Mana only** (no coins in match) |
| Cap on field | Start **4** deploy slots worth of presence; hard cap TBD (~8–12 units alive — balance later) |
| Signature spell | Type Pulse retained as early unlock; later spells optional |

---

## 4. Wave system (PvZ-style)

Each level is a sequence of **waves**, not a continuous infinite spawn.

| Concept | Spec |
|---------|------|
| Wave banner | “Wave N / M” toast + short pause (~1.5s) |
| Intra-wave | Enemies spawn on a curve (front-loaded or back-loaded per level) |
| Between waves | Brief downtime (~3–5s) for mana regen / redeploy |
| Flag wave | Last wave of a level is denser; boss levels replace last wave with boss + adds |
| Progress | Clearing all waves + crystal rules = level clear |

**Level structure (default):** Levels 1–9 → 3–5 waves · Level 10 boss · Levels 11–19 → 5–7 waves · Level 20 final boss.

---

## 5. Campaign: 20 levels + bosses

| Level | Theme beat | Special |
|-------|------------|---------|
| 1–3 | Teach deploy + types | Soft tutor |
| 4–6 | Introduce 2nd type pressure | |
| 7–9 | Economy stress (mana) | |
| **10** | **Boss A** | Mid-campaign gate |
| 11–14 | New types / armor waves | Deck slot 5 already unlocked |
| 15–19 | Mixed affinity hell | |
| **20** | **Boss B** | Finale + deck slot 6 already unlocked |

**Boss A (L10):** High HP, phase 2 at 50% (summons a mini-wave).  
**Boss B (L20):** Higher HP, two adds every 20s, weak to a specific type triangle (telegraphed).

---

## 6. Rosters

### 6.1 Player troops — **20** unlockable

Design target: **20 unique player-side troops**.  
Milestone A (first shippable): **12** fully distinct; remaining 8 may be typed variants until art lands.

Each troop defines: `id`, display name (original), type(s), role tag, unlock cost (coins), deploy **mana** cost, HP, ATK, ASPD, special (1 line max).

### 6.2 Enemy troops — **20** + **2 bosses**

**20** enemy unit types for wave composition + **Boss A** + **Boss B**.  
Enemies do not use the player deck; they are authored per wave table.

### 6.3 Earlier note “15 each team”

Interpreted as an **interim roster milestone** (15 player / 15 enemy) on the way to **20 / 20 + 2 bosses**. GDD locks the north star at 20/20+2.

### 6.4 Starter set

New campaign starts with **4 unlocked troops** covering different types so affinity matters immediately.

---

## 7. Type chart (Pokémon-inspired, IP-safe)

**8 types** (enough meaning, not a full Pokédex):

| ID | Name | Beats (×1.5) | Weak to (×0.65) |
|----|------|--------------|-----------------|
| ROCK | Rock | BOLT, SHADE | TIDE, FIGHT |
| FIGHT | Fight | ROCK, IRON | MIND, BLOOM |
| MIND | Mind | FIGHT, BLOOM | SHADE, BOLT |
| BLOOM | Bloom | FIGHT, TIDE | ROCK, SHADE |
| BOLT | Bolt | MIND, TIDE | ROCK, IRON |
| TIDE | Tide | ROCK, BOLT | BLOOM, IRON |
| SHADE | Shade | MIND, BLOOM | ROCK, FIGHT |
| IRON | Iron | BOLT, TIDE | FIGHT, SHADE |

- Dual-type troops: multiply once per attack using **attacker primary vs defender primary** for v1 (simplify).  
- Neutral = ×1.0.  
- HUD: small attacker→defender icon flash on advantage hits.  
- ResearchBot may tune multipliers; DocumentBot owns names in GDD.

---

## 8. Deck system

| Rule | Spec |
|------|------|
| Max carry | **6** troop IDs in deck |
| Start | **4** deck slots unlocked |
| Level 10 clear | Unlock **5th** deck slot |
| Level 20 clear | Unlock **6th** deck slot |
| Pre-level | Player fills unlocked slots from **owned** roster |
| In battle | Hotkeys / buttons for each deck slot (mana cost shown) |

Cannot put locked/unowned troops in deck.

---

## 9. Dual economy

### 9.1 Global coins (OUTSIDE battle only)

Earn on: level clear (base + star bonus), first-clear bonus, optional daily later (out of scope).

Spend on:

- Unlocking troops in Barracks (exponential prices)
- **Mana Lab** meta upgrades (max mana, regen speed)

### 9.2 Mana (IN battle only)

- Starts at `base_max` with `base_regen / sec` from Mana Lab rank
- Spend only on troop deploy (+ optional Pulse / in-match mana upgrades)

### 9.3 In-match mana upgrades

During battle, spend mana on a small upgrade track:

| Rank | Effect |
|------|--------|
| +1 | +regen |
| +2 | +max mana |
| +3 | +regen |
| … | Caps at rank 5 for v1 |

Lets players bank for “bigger troops” mid-level (user ask).

---

## 10. Exponential curves (design targets)

Use geometric growth so late troops feel premium.

**Unlock coin cost (troop tier t = 1…20):**  
`coins(t) = round(50 * 1.35^(t-1))`  
→ ~50, 68, 91, … climbing into thousands for top tiers.

**Deploy mana cost (power tier p):**  
`mana(p) = round(10 * 1.28^(p-1))`

**Power budget (HP×ATK proxy):**  
`power(p) ≈ 100 * 1.22^(p-1)`  
(Tune so mana efficiency isn’t strictly linear — high tier = spike, not always optimal.)

**Mana Lab meta:**  
Rank r cost `coins = round(80 * 1.4^r)`; each rank +10% max or +8% regen (alternating).

ResearchBot to validate numbers in a spreadsheet pass; CodeBot implements constants table.

---

## 11. Phased delivery (so CodeBot doesn’t boil the ocean)

| Phase | Scope | Exit |
|-------|-------|------|
| **P0** | Keep current playable kernel + Must QA stamp | TesterBot pass on live tunnel |
| **P1** | Main menu + Level Select shell (levels 1–3 wave stub) | Click-to-battle path |
| **P2** | Wave director + coin rewards + Barracks unlock 8 troops | 3-level loop fun |
| **P3** | Type chart 8×8 wired to all units | Matchups feel meaningful |
| **P4** | Expand toward 15/15 roster + Mana Lab | Milestone “15 each” |
| **P5** | Full 20/20 + Boss L10 | Mid campaign |
| **P6** | Boss L20 + deck slots 5–6 + polish | Campaign complete |

Asset pull (CodeBot) starts **immediately in parallel** with P1 (see `ASSET_REQUIREMENTS_v2.md`).

---

## 12. Asset requirements (summary)

Full list: **`docs/ASSET_REQUIREMENTS_v2.md`**

| Need | Count |
|------|-------|
| Player sprites | 20 (min first pull 12) |
| Enemy sprites | 20 (min 12) |
| Bosses | 2 |
| UI / menu / meta | Kenney UI packs |
| Env | Kenney / OGA grass-path |
| License | **CC0 / open only** |

CodeBot downloads from Kenney + OpenGameArt; writes `UNITS_MANIFEST.md` + `ATTRIBUTION.md`.

---

## 13. Explicit non-goals

Official Pokémon names/sprites/audio · capture/evolution Pokédex · multiplayer · multi-lane · paid asset packs without clear license · shipping all 40 units before P1 menu exists.

---

## 14. Team handoffs

| Role | Now |
|------|-----|
| **DocumentBot** | Owns this GDD + asset requirements |
| **ResearchBot** | Type-chart tune, exponential curve validation, PvZ wave pacing tables |
| **CodeBot** | Pull CC0 assets per requirements; implement by phase |
| **TesterBot** | Finish Must #2–4 stamp; then phase playtests |
| **ProjectBot** | Scope/schedule; re-export tunnels |

---

## 15. Success criteria (campaign v1)

- [ ] Main menu → level 1 playable with waves  
- [ ] Coins unlock ≥1 new troop; mana-only in battle  
- [ ] Type chart changes outcomes (player can explain a counter)  
- [ ] Deck 4 slots; slot 5 at L10; slot 6 at L20  
- [ ] 20 levels authored (even if some reuse wave templates)  
- [ ] Bosses at 10 and 20  
- [ ] All art CC0-attributed  
- [ ] Roster north star 20 player / 20 enemy / 2 bosses (15/15 interim OK)

---

## 16. Changelog

- **v1.0 (2026-09-20):** Campaign expansion per user: rosters, type chart, waves, 20 levels, bosses, dual economy, deck unlocks, exponential costs, phased plan, asset requirements handoff.
- **v0.2.1:** P0 Must #2–4 implemented · pending QA.
- **v0.2:** Fun-factor backlog ranked.
- **v0.1:** 2h prototype lock.

---

## Appendix A — Prototype carry-forward

Still true unless a phase replaces it: keys 1–4 style deploy, Type Pulse, kill bounty, soft tutor, early grace verify, Origin polish SHAs for kernel combat.
