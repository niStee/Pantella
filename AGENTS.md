# Pantella

> Parent: [~/AGENTS.md](../../AGENTS.md) — environment-wide · [~/Projects/AGENTS.md](../AGENTS.md) — project index
> Generated: 2026-07-04 · Commit: `d4773e4a` · Branch: `dev/pantella-wow`

Public GitHub fork of [Pantella](https://github.com/Pathos14489/Pantella) — Skyrim/FO4/FNV/Oblivion mod for natural speech interaction with NPCs via LLM inference. This fork is maintained as an upstream-compatible mirror; World of Warcraft integration lives in the separate [pantella-wow](https://github.com/niStee/pantella-wow) repo, which is included here as a Git submodule at `addons/pantella-wow`. Run `git submodule update --init --recursive` after cloning to populate it.

## Stack

- Python 3.10 (main application)
- OpenAI-compatible / local LLM inference backends
- Modular TTS backends (Piper, xVASynth, xTTS, GPT-SoVITS, Chatterbox, OmniVoice, Pocket-TTS, etc.)
- Gradio web UIs for memory editing, config, and debug

## Structure

```
Pantella/
├── main.py                        # Application entry point
├── src/                           # Core application modules (see src/AGENTS.md)
├── addons/                        # Self-contained addon packs (TTS, inference, game interfaces, behaviors)
├── characters/                    # Per-game character JSON entries (Skyrim, FNV, etc.)
├── data/                          # Models, voice samples, Piper TTS voice tensors
├── interface_configs/             # JSON interface configuration templates
├── prompt_styles/                 # LLM prompt style templates
├── behavior_styles/               # Behavior configuration templates
├── libraries/                     # Vendored / forked third-party libraries (modify upstream, not here)
├── piper/                         # Piper TTS runtime assets (vendored)
├── xtts-api-server-pantella/    # xTTS API server (vendored fork)
└── scripts/                       # Utility scripts (currently empty)
```

## Where to Look

| Task | Location | Notes |
|------|----------|-------|
| Start the app | `main.py` | Loads startup.json, selects game interface, creates conversation manager |
| Add a new LLM backend | `src/inference_engines/` + `addons/openai_api_addon/inference_engines/` | Inherit from `base_llm.py` |
| Add a new TTS backend | `src/tts_types/` | Inherit from `base_tts.py` |
| Add a new game interface | `src/game_interfaces/` + `addons/pantella-wow/game_interfaces/` | Inherit from `base_interface.py` |
| Add a new behavior | `src/behaviors/` | Loaded by `behavior_manager.py` |
| Change character data | `characters/<game_id>/` | JSON files with `bio`, `voice_model`, `base_id`, etc. |
| Edit ChromaDB memories | `src/chromadb_memory_editor.py` | Web UI at `http://localhost:8022` when enabled |
| Configuration schema | `src/config_loader.py` | Large config loader; defines defaults and UI generation |

## CODE MAP

| Symbol | Type | Location | Role |
|--------|------|----------|------|
| `main` | function | `main.py` | Entry point, startup dialog, conversation loop |
| `ConfigLoader` | class | `src/config_loader.py` | Central configuration, settings descriptions, web configurator |
| `ConversationManager` | class | `src/conversation_manager.py` + `src/conversation_managers/` | Orchestrates game interface, TTS, LLM, memory |
| `LanguageModel` | class | `src/language_model.py` | LLM abstraction wrapper |
| `base_llm` | class | `src/inference_engines/base_llm.py` | Base class for inference engines |
| `llama_cpp_python` | class | `src/inference_engines/llama_cpp_python.py` | Local GGUF inference engine |
| `openai_api` | class | `addons/openai_api_addon/inference_engines/openai_api.py` | OpenAI/OpenRouter compatible API engine |
| `base_tts` | class | `src/tts_types/base_tts.py` | Base class for TTS backends |
| `base_interface` | class | `src/game_interfaces/base_interface.py` | Base class for game interfaces |
| `creation_engine_file_buffers` | class | `src/game_interfaces/creation_engine_file_buffers.py` | Skyrim/FO4 file-buffer game interface |
| `fnv_file_buffers` | class | `src/game_interfaces/fnv_file_buffers.py` | Fallout New Vegas file-buffer interface |
| `base_character_db` | class | `src/character_dbs/base_character_db.py` | Character database loader |
| `chromadb_memory` | class | `src/memory_managers/chromadb_memory.py` | ChromaDB-based long-term memory |
| `message_formatter` | module | `src/message_formatter.py` | Builds prompts from templates |
| `stt` / `tts` | modules | `src/stt.py`, `src/tts.py` | Speech-to-text and text-to-speech orchestrators |

## Conventions

- This is a vendored fork — prefer upstream changes over local modifications.
- Keep the fork synchronized with upstream via `git pull origin main`.
- New capabilities are added via the addon system under `addons/` rather than by editing core.
- Third-party code in `libraries/`, `piper/`, and `xtts-api-server-pantella/` should be treated as vendored: do not modify in place; patch upstream or fork instead.
- Python 3.10 is the supported runtime; dependencies are in `requirements.txt` and `launcher_requirements.txt`.
- Configuration is JSON-driven; per-game config files live in `configs/<game_id>_config.json` and are generated at first run.

## Anti-Patterns (This Project)

- Do not modify vendored code in `libraries/`, `piper/`, or `xtts-api-server-pantella/` directly.
- Do not bypass `config_loader.ConfigLoader` for settings; raw config reads should be rare.
- Avoid hard-coding game-specific paths or IDs outside `game_interfaces/` and `characters/`.
- Do not rely on Mantella's old summary-memory system; Pantella uses ChromaDB.

## Commands

```bash
# Run with conda (recommended)
conda create -n pantella python=3.10
conda activate pantella
pip install -r requirements.txt
python main.py

# First run creates startup.json and configs/<game_id>_config.json
```

## Notes

- The Launcher (Windows-only) manages the Python environment, repo updates, and plugin deployment. Linux users run `main.py` directly.
- The ChromaDB memory editor and debug UI require `gradio`; startup continues if gradio is missing but those UIs are unavailable.
- CI/CD is minimal: GitHub Actions CodeQL only (public fork).

## Fork-Specific Notes

This section applies to the `niStee/Pantella` fork only.

### Branch Strategy

| Branch | Purpose | Default? |
|--------|---------|----------|
| `main` | Upstream-compatible mirror, synced from `Pathos14489/Pantella:main` | Yes |
| `dev/pantella-wow` | Integration branch for fork-specific WoW work (if any) | No |

Keep `main` as close to upstream as possible. All fork-specific work (WoW integration, docs, tooling changes not suitable for upstream) goes on `dev/pantella-wow`.

### Upstream Sync

- `.github/workflows/sync-upstream.yml` runs daily and on demand.
- It fetches `Pathos14489/Pantella:main` and **merges** it into `niStee/Pantella:main`.
- The merge-based approach preserves fork-specific commits (the workflow file and `.gitignore` entries) instead of force-resetting the branch.
- Trigger manually from the repo’s Actions tab if you need an immediate sync.

### `pantella-wow` Addon Layout

The WoW addon has its own repository (`niStee/pantella-wow`) and is **not** a submodule of this fork. To work locally:

- Linux/macOS: clone `pantella-wow` anywhere (e.g. `~/Projects/pantella-wow`). You may also keep a checkout at `Pantella/addons/pantella-wow/` for convenience.
- Windows: clone to `D:\repos\pantella-wow` (or another path outside `Program Files`) and junction it into WoW’s AddOns folder.

`Pantella/addons/pantella-wow/` and `.omo/` are gitignored so the standalone clone does not show up as untracked when working on this repo.

### Windows Embedded-Python WoW Runtime

The Windows machine (`192.168.178.115`, user `2glea`) runs Pantella via the Launcher's embedded Python, not conda/venv. The layout uses a **standalone addon + dual junction** architecture: the canonical addon repo at `D:\repos\pantella-wow` is linked into both the Pantella core checkout and the WoW AddOns folder via NTFS junctions. This matches the `ai-infra/scripts/bootstrap-windows.ps1.tmpl` template.

**Layout:**

| Path | Purpose |
|------|---------|
| `D:\repos\Pantella-Launcher\Pantella_Launcher\` | Launcher root with `python-3.10.11-embed\python.exe` |
| `D:\repos\Pantella\` | Active Pantella core checkout (this fork, `dev/pantella-wow` branch) |
| `D:\repos\pantella-wow\` | Canonical WoW addon repo (`windows-runtime-fixes` local branch, not pushed) |
| `D:\repos\Pantella\addons\pantella-wow\` | **Junction** → `D:\repos\pantella-wow` (backend loads addon from here) |
| `C:\games\World of Warcraft\_retail_\Interface\AddOns\MantellaWoW\` | **Junction** → `D:\repos\pantella-wow\MantellaWoW` (game loads addon from here) |
| `C:\games\World of Warcraft\_retail_\` | WoW Midnight (12.0.7.68275) installation |

**WoW version details (Midnight expansion):**

- WoW.exe version: `12.0.7.68275`
- Window class changed from `GxWindowClass` to `waApplication Window` (DX12 minimum)
- Interface version: `120007`
- TOC dependencies removed (Questie/DBM-Core/Details are optional)

**Minimal WoW config:**

All config files must be written via Python `json.dump()` — PowerShell `Set-Content -Encoding UTF8` adds a BOM that breaks `json.load()`.

- `startup.json` — `default_interface: "wow"`, `first_time_setup: false`, `always_open_interface_selection: false`
- `config.json` — `{"game_id": "wow"}`
- `configs/wow_config.json` — TTS (`piper_binary`), inference engine (`openai_api`), model (`meta-llama/llama-3.3-70b-instruct:free`), `alternative_openai_api_base` set to OpenRouter, `stt_enabled: false`, `chromadb_memory_editor_enabled: false` (in both root and `chromadb_memory` section), `remove_mei_folders: false`
- `GPT_SECRET_KEY.txt` — OpenRouter API key (retrieved from KWallet `secret-tool lookup openrouter api-key`)

**Bootstrap workaround (`pantella_wow_bootstrap.py`):**

The embedded Python's `python310._pth` only puts the embed directory on `sys.path`. Running `main.py` directly fails with `ModuleNotFoundError: No module named 'src.logging'`. The bootstrap injects the repo root and sets the working directory to D: drive (avoids `os.path.relpath()` cross-drive `ValueError`):

```python
# pantella_wow_bootstrap.py — placed in the repo root
import os, runpy, sys
os.chdir(r'D:\repos\Pantella')
sys.path.insert(0, r'D:\repos\Pantella')
runpy.run_path(r'D:\repos\Pantella\main.py', run_name='__main__')
```

**Launch methods (ordered by reliability):**

| Method | Survives SSH disconnect? | Can see WoW window? | Notes |
|--------|-------------------------|--------------------|----|
| `New-Object Process` + async stream readers + `WaitForExit` | ❌ Dies when parent exits | ❌ Session 0 | Keeps process alive only during SSH session; async readers prevent stdout buffer deadlock |
| `schtasks /create /tn "X" /tr "python.exe bootstrap.py" /sc once /st 00:00 /ru 2glea /f` + `schtasks /run /tn X` | ✅ Independent process | ❌ Session 0 | Process survives but can't enumerate interactive desktop windows |
| `Start-Process -WindowStyle Hidden` | ❌ Dies when parent exits | ❌ | Same session limitation |
| Interactive desktop (Terminal on the machine) | ✅ | ✅ | Only reliable way to access WoW window |

Startup takes ~4-5 minutes (chromadb, pyannote, speechbrain, all TTS engines import eagerly). The `faster_whisper` module must be banlisted in `src/module_banlist` (causes silent crash during import in detached sessions).

### Backend Fixes Applied for WoW

These fixes are committed to the `dev/pantella-wow` branch of this fork. They were originally developed on the Windows checkout and then synced back to `niStee/Pantella`.

| Fix | File | Problem | Solution |
|-----|------|---------|----------|
| Banlist `llama_cpp_python` | `src/module_banlist` | Broken `llama.dll` causes `KeyError: 'llama_cpp_python'` crash | Added `llama_cpp_python` to banlist |
| Banlist `faster_whisper` | `src/module_banlist` | Silent crash during import in detached sessions | Added `faster_whisper` to banlist |
| Default LLM fallback | `src/language_model.py` line 59 | `LLM_Types["default"] = LLM_Types[default]` crashes when default unavailable | Wrapped in try/except, falls back to first available engine |

> WoW-specific prompt styles and runtime helpers have been moved to the `pantella-wow` addon submodule; they are no longer tracked in the core fork.

### Player Input Channel

The WoW conversation manager now reads player input via the addon slash command `/cm` (Companion Message). This avoids collisions with built-in WoW slash commands (`/mt` is a party command, `/pantella` is also built-in).

In-game usage:
```
/cm Hello, companion.
```

The Lua addon stores the message in `MantellaWoWDB.player_input` and increments `player_input_id`. The Python `WoWGameInterface.get_text_input()` polls the hidden `MantellaWoW_State` EditBox for new `player_input_id` values, consumes the message, and returns it to the conversation loop. This is a temporary channel until the pixel-encoding IPC is implemented.

### Pantella-WoW Addon Fixes Applied

These fixes address compatibility issues between the pantella-wow addon and the current Pantella core. They are committed to the `niStee/pantella-wow` repo.

| Fix | File | Problem | Solution |
|-----|------|---------|----------|
| Enable addon | `metadata.json` | Addon disabled by default (`enabled` defaults to `False`) | Added `"enabled": true` |
| TOC interface version | `MantellaWoW/*.toc` | Interface `110000` (War Within) incompatible with WoW 12.0.7 (Midnight) | Updated to `120007` |
| TOC dependencies | `MantellaWoW/*.toc` | `## Dependencies: Questie, DBM-Core, Details` blocks loading | Removed dependencies line |
| Window class | `game_interfaces/wow.py` line 176 | `FindWindow("GxWindowClass", ...)` finds nothing in Midnight | Changed to `"waApplication Window"` |
| `__init__` signature | `game_interfaces/wow.py` line 82 | `WoWGameInterface.__init__` took 2 args, factory passes 3 | Updated to `(self, conversation_manager, valid_games, interface_slug)`, pass all to `super().__init__()` |
| Class alias | `game_interfaces/wow.py` (end) | Factory expects `module.GameInterface`, class is `WoWGameInterface` | Added `GameInterface = WoWGameInterface` |
| `/cm` player input | `MantellaWoW/MantellaWoW.lua` + `game_interfaces/wow.py` | No way to send player text to the backend from WoW | Added `/cm` slash command and EditBox polling reader |
| `manager_slug` | `conversation_managers/wow_conversation_manager.py` | Missing `manager_slug` attribute → addon doesn't register | Rewrote with `manager_slug`, `valid_games`, `ConversationManager` class, `await_and_setup_conversation()` and `step()` implementation |
| Stub character manager | `character_managers/wow_character_manager.py` | Imports non-existent `skyrim_character_manager` | Replaced with minimal stub: `manager_slug`, `valid_games`, `Character` class |
| Stub character generator | `character_generators/wow_character_generator.py` | Imports non-existent `skyrim_character_generator` | Replaced with minimal stub: `generator_name`, `Character` class |
| Stub character DB | `character_db/wow_character_db.py` | Imports non-existent `skyrim_character_db` | Replaced with minimal stub: `db_slug`, `valid_games`, `CharacterDB` class |
| Interface config | `interface_configs/wow.json` | `character_db: "wow_character_db"` not in DB_Types (dir is `character_db/` singular, code expects `character_dbs/` plural) | Changed to `base_db` |
| Overlay copy | `overlay.py` | Present in standalone repo but missing from active checkout | Copied from `D:\repos\pantella-wow\overlay.py` |

### WoW Addon IPC Architecture (Research Findings, July 2026)

The current IPC mechanism (Lua EditBox → Win32 `WM_GETTEXT`) is **fundamentally broken** in WoW Midnight (12.0+). WoW's UI frames are internal rendering objects, not Win32 controls. `EnumChildWindows` never finds them. This was confirmed through extensive testing on the Windows machine.

**Research was conducted via 7 parallel agents covering:** Blizzard ToS/EULA compliance, WoW Lua API capabilities, combat log file format, existing AI companion addons, RP addon data export patterns, Details!/WarcraftLogs desktop IPC mechanisms, and all known WoW IPC approaches.

#### Viable IPC mechanisms (ranked by suitability):

**1. Pixel Encoding (recommended primary channel)**

The addon draws a small colored pixel strip (e.g., 1×20px at a screen corner) encoding JSON state as RGB values. The Python backend captures the WoW window via Windows Graphics Capture (WGC) or DXGI and decodes the pixel values.

- Latency: ~16ms per frame
- ToS-safe: reading your own screen pixels is passive observation, not prohibited
- Works in instances (unlike addon messages, which are blocked in 12.0)
- Proven by: LibSerpix (CBOR-encoded pixel columns), WowClassicGrindBot (32-bit integers packed into RGB), ConRO_Skills
- Limitation: UI scale must be known, color-altering overlays (Reshade, NVIDIA Freestyle) can corrupt encoding

**2. Combat Log + `SendAddonMessageLogged` (secondary channel)**

`C_ChatInfo.SendAddonMessageLogged("Pantella", json, "GUILD")` writes addon messages directly to `Logs/WoWCombatLog.txt`. Python tails the file (infrastructure already exists in pantella-wow's `CombatLogHandler`).

- Real-time, battle-tested (WarcraftLogs/Archon App uses this for combat events)
- Limitations: 255-byte message limit, throttled (10/sec), **blocked in instances** in 12.0, requires guild channel
- `SendAddonMessage()` (non-logged variant) does NOT write to the file — only `SendAddonMessageLogged()` does

**3. SavedVariables polling (fallback/persistence)**

Addon writes state to SavedVariables, Python polls file mtime. **Only written on logout/reload** — not during gameplay. Used by fjoelnr/wow-ai-companion and Loothing (Tauri desktop app) for session data.

#### What's definitively impossible from WoW Lua:

- HTTP/web requests (sandbox blocks networking)
- Direct file I/O (no `C_FileIO` namespace exists)
- Clipboard access
- Named pipes / sockets
- Memory reading (bannable — Warden anti-cheat)

#### Recommended architecture:

The formal Architecture Decision Record for IPC transport is at `docs/ADR-001-ipc-transport.md` in the [`niStee/pantella-wow`](https://github.com/niStee/pantella-wow) addon repo (merged on `main`). It documents the channel-neutral message envelope, anti-goals, and implementation milestones.

```
Addon (Lua)                    Python Backend
─────────────                  ───────────────
Pixel encoder ────pixels─────► Screen capture (WGC/DXGI)
  (1×N pixel strip)              → decode RGB → JSON state

SendAddonMessageLogged           Combat log tailer
  ("Pantella", json) ──file───► → parse addon messages

SavedVariables ────file──────► mtime poll (fallback/persistence)
  (on logout/reload)
```

#### Similar projects found:

| Project | IPC mechanism | Status |
|---------|--------------|--------|
| fjoelnr/wow-ai-companion | SavedVariables polling + combat log tail | Early dev (most architecturally similar) |
| Loothing (CurseForge) | Tauri desktop app watching SavedVariables | Production |
| mklabs/arena-recorder.wow | Screenshot detection via `chokidar` | Working |
| LibSerpix | Pixel encoding (CBOR via pixel columns) | Proof of concept |
| ChattyLittleNPC | Pre-generated AI voice packs, no IPC | Production (different approach) |

### Dependency Updates

This fork tracks upstream for dependency updates. Dependabot version-update pull requests on `niStee/Pantella` are closed intentionally; security alerts remain enabled. If a dependency change is needed specifically for WoW work, apply it on `dev/pantella-wow`.

### Branch Hygiene

Stale branches for merged or superseded work should be deleted after the corresponding PR is closed/merged. Retained long-lived branches:

- `main`
- `dev/pantella-wow`
