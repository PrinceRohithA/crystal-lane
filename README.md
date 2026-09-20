# Crystal Lane

A tiny **Godot 4** 1-lane battler: blue crystal on the left, red crystal on the right. Spend gold to train original creature stand-ins. Spend mana on one spell. Win when the enemy crystal hits 0 HP.

This is a fan-inspired prototype (Stick War–style lane + a clean 2.5D side path). It is **not affiliated with, endorsed by, or connected to Nintendo, Game Freak, The Pokémon Company, Stick War, or Max Games.** No official names, sprites, or audio. Units are geometric placeholders (blue team / red team).

## Clone

```bash
git clone https://github.com/PrinceRohithA/crystal-lane.git
cd crystal-lane
```

GitHub: https://github.com/PrinceRohithA/crystal-lane

## How to open (editor)

1. Install **Godot 4.3+** from [godotengine.org](https://godotengine.org/download).
2. In the Project Manager, choose **Import**, then select this folder’s `project.godot`.
3. Press **F5** to run `scenes/main.tscn`.

```bash
godot --path .
```

## Play in a browser (Web export)

A Godot 4.3 **Web** (HTML5) build lives in `build/web/` (`index.html`, `index.js`, `index.wasm`, `index.pck`). Rebuild with `./export-web.sh` if binaries are missing. It is a **single-thread** export (no SharedArrayBuffer / COOP-COEP).

```bash
python3 scripts/serve_web.py --port 43180
```

## Goal

Train units with **gold**. Cast **Type Pulse** with **mana**. At most **8** units can be alive on the lane. Reduce the red crystal to 0 HP to win. If the blue crystal hits 0, you lose.

## Units (original names)

| Key | Role | Creature | Gold |
| --- | --- | --- | --- |
| `1` | Tank (Rock) | Cragback | 70 |
| `2` | Melee (Fighting) | Knuckhorn | 45 |
| `3` | Ranged (Psychic) | Veilray | 60 |
| `4` | Support (Fairy) | Gleamlet | 55 |

Gleamlet heals a nearby ally. Type Pulse (`Space`, 55 mana) damages and slows **enemy units in the middle third of the lane only**.
