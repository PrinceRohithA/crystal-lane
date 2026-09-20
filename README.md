# Crystal Lane

A tiny **Godot 4.3** 1-lane battler: blue crystal on the left, red crystal on the right. Spend **gold** to train original creature stand-ins. Spend **mana** on one spell, **Type Pulse**. Win when the enemy crystal hits 0 HP.

Stick War–style single lane. CC0 Kenney + MELLE art. Geometric `_draw()` placeholders remain as fallbacks.

This prototype is **not affiliated with, endorsed by, or connected to Nintendo, Game Freak, The Pokémon Company, Stick War, or Max Games.** No official names, sprites, or audio.

## Clone

Public GitHub mirror:

```bash
git clone https://github.com/PrinceRohithA/crystal-lane.git
cd crystal-lane
```

Origin is the **source of truth** for this project; GitHub is the public mirror. After fetching from Origin, publish the same branch with:

```bash
git remote add github https://github.com/PrinceRohithA/crystal-lane.git
git push -u github cursor/cc0-assets-and-polish-831a
```

GitHub `main` was seeded separately (unrelated history). Prefer pushing the polish branch and opening a PR rather than force-updating `main`. To replace `main` after review: `git push github cursor/cc0-assets-and-polish-831a:main` (may need `--force-with-lease` because the histories diverge).

## How to open (editor)

1. Install **Godot 4.3+** from [godotengine.org](https://godotengine.org/download).
2. In the Project Manager, choose **Import**, then select this folder’s `project.godot`.
3. Press **F5** to run `scenes/main.tscn`.

```bash
godot --path .
```

## Play in a browser (Web export)

A Godot 4.3 **Web** (HTML5) build lives in `build/web/` (`index.html`, `index.js`, `index.wasm`, `index.pck`). It is a **single-thread** export (no SharedArrayBuffer / COOP-COEP), so any static host or tunnel works.

Serve it (correct `application/wasm` MIME):

```bash
python3 scripts/serve_web.py --port 43180
# → http://127.0.0.1:43180/
```

Or rebuild, then serve:

```bash
chmod +x export-web.sh
# Optional: export GODOT_BIN=/path/to/Godot_v4.3-stable_linux.x86_64
./export-web.sh --serve
```

### Export from Godot yourself

1. Install **Godot 4.3** and its **export templates** (Editor → Manage Export Templates, or unzip `Godot_v4.3-stable_export_templates.tpz` into `~/.local/share/godot/export_templates/4.3.stable/` so `web_nothreads_release.zip` is present).
2. This repo already has `export_presets.cfg` with a **Web** preset writing to `build/web/index.html` (`variant/thread_support=false`).
3. Editor: Project → Export → Web → Export Project…  
   Headless: `godot --headless --path . --export-release Web build/web/index.html`

`export-web.sh` wraps that headless command and prints template-install steps if the Web template is missing.

Exact template install if the editor wizard is unavailable:

```bash
curl -L -o /tmp/Godot_v4.3-stable_export_templates.tpz \
  https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_export_templates.tpz
mkdir -p ~/.local/share/godot/export_templates/4.3.stable
unzip -j /tmp/Godot_v4.3-stable_export_templates.tpz \
  'templates/version.txt' 'templates/web_*.zip' \
  -d ~/.local/share/godot/export_templates/4.3.stable
./export-web.sh
```

## Goal

Train units with **gold**. Cast **Type Pulse** with **mana**. At most **8** units can be alive on the lane. Reduce the red crystal to 0 HP to win. If the blue crystal hits 0, you lose. The red team auto-spawns on a timer.

Type Pulse spends 55 mana, sends a wave across the **whole lane**, and **damages + slows only in the middle third** (marked on the path).

## Units (original names)

| Key | Role | Creature | Gold | Stub |
| --- | --- | --- | --- | --- |
| `1` | Tank (Rock) | Cragback | 70 | High HP, 28% damage resist, holds the line (taunt) |
| `2` | Melee (Fighting) | Knuckhorn | 45 | Fast, high damage, extra punch vs crystals |
| `3` | Ranged (Psychic) | Veilray | 60 | Long-range motes; kites if foes close in |
| `4` | Support (Fairy) | Gleamlet | 55 | Heals a nearby ally and grants a short haste buff |

Restart after victory/defeat with `R` or Enter.

## Art (CC0 only)

See [`assets/ATTRIBUTION.md`](assets/ATTRIBUTION.md).

| Folder | Pack |
| --- | --- |
| `assets/env/` | Kenney 1-Bit Pack tilesheets |
| `assets/crystals/` | MELLE FANTASY-crystal-set (blue L / red R) |
| `assets/units/` | Kenney Shape Characters (square / rhombus / circle / squircle) |
| `assets/ui/` | Kenney UI Pack panels, bars, buttons, fonts |

Refresh from upstream:

```bash
./scripts/download_cc0_assets.sh
```

## Layout

```
scenes/main.tscn          Battlefield + HUD
scripts/game.gd           Gold, mana, cap, Type Pulse, win/lose
scripts/unit.gd           Four roles + lane AI
scripts/tower.gd          Blue / red crystals
scripts/projectile.gd     Veilray motes
scripts/hud.gd            Gold, mana, both crystal HP
scripts/battlefield.gd    Perspective lane + 1-bit décor
scripts/pulse_fx.gd       Type Pulse wave
scripts/art.gd            CC0 texture helpers
scripts/download_cc0_assets.sh
scripts/serve_web.py      Static server for the Web build
export_presets.cfg        Godot 4.3 Web (HTML5) preset
export-web.sh             Headless Web export
build/web/                Playable HTML5/wasm/pck output
assets/                   CC0 packs + ATTRIBUTION.md
```
