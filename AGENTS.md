# Pantella

> Parent: [~/AGENTS.md](../../AGENTS.md) — environment-wide · [~/Projects/AGENTS.md](../AGENTS.md) — project index
> Generated: 2026-06-30 · Commit: `6e872100` · Branch: `feat/pantella-wow-submodule`

Public GitHub fork of [Mantella](https://github.com/Pathos14489/Pantella) — Skyrim/FO4/FNV mod for natural speech interaction with NPCs via LLM inference.

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
