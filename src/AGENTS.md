# src/ — Core Application Modules

> Parent: [../AGENTS.md](../AGENTS.md)

This directory contains the core Pantella application. Everything here is hot-swappable through the addon system in `addons/`, but the concrete implementations live here first.

## Structure

```
src/
├── inference_engines/    # LLM backends (llama-cpp-python, base class, etc.)
├── tts_types/            # TTS backends (Piper, xTTS, xVASynth, GPT-SoVITS, etc.)
├── game_interfaces/      # Game communication bridges (file buffers, WoW, Gradio debug)
├── character_dbs/        # Character database loaders
├── character_managers/   # Per-character runtime state
├── conversation_managers/# Conversation lifecycle implementations
├── memory_managers/      # ChromaDB and other long-term memory stores
├── behaviors/            # NPC behavior scripts
├── stt_types/            # Speech-to-text providers
├── speech_input_processor_types/ # Audio preprocessing pipelines
├── thought_processes/    # Chain-of-thought / reasoning templates
├── tokenizers/           # Tokenizer helpers
├── templates/            # Prompt / message templates
├── static/               # Web UI assets (FontAwesome, JS, CSS)
├── torchmoji/            # Emoji/sentiment model utilities
├── config_loader.py      # Central configuration + web configurator
├── conversation_manager.py # Factory for conversation managers
├── language_model.py     # LLM abstraction wrapper
├── message_formatter.py  # Prompt assembly from templates
├── stt.py / tts.py       # Speech orchestrators
├── ui.py                 # Tkinter dialogs
├── logging.py            # Custom logging + path filtering
└── utils.py              # Shared helpers
```

## Where to Look

| Task | Location | Notes |
|------|----------|-------|
| Add an LLM backend | `src/inference_engines/` | Subclass `base_llm.py`; register in `src/inference_engines/__init__.py` and `config_loader.py` |
| Add a TTS backend | `src/tts_types/` | Subclass `base_tts.py`; register in `src/tts_types/__init__.py` and `config_loader.py` |
| Add a game interface | `src/game_interfaces/` | Subclass `base_interface.py`; add JSON template in `interface_configs/` |
| Add a behavior | `src/behaviors/` | Implement the behavior contract; loaded by `behavior_manager.py` |
| Change memory storage | `src/memory_managers/` | Current default is ChromaDB (`chromadb_memory.py`) |
| Change prompts | `src/message_formatter.py` + `prompt_styles/` | Templates are JSON-driven |
| Add config settings | `src/config_loader.py` | Add to schema + descriptions; web UI auto-generates |
| Debug without a game | Set `debug_mode` / `conversation_manager_type = "gradio"` | Uses Gradio debug UI instead of file buffers |

## Conventions

- **Base-class driven**: nearly every subsystem uses `base_*.py` as the extension point.
- **JSON-driven configuration**: runtime settings live in `configs/<game_id>_config.json`; first run generates them via `config_loader.py`.
- **Plugin registration**: concrete implementations are typically imported/registered in `__init__.py` and referenced by string in config.
- **Custom logging**: use `from src.logging import logging`; `logging.block_logs_from` is set from config to silence noisy files.
- **Python 3.10**: match statements, modern typing, and newer stdlib features may be used; do not raise the floor without updating docs.

## Anti-Patterns (This Directory)

- Do not hard-code game-specific file paths or IDs outside `game_interfaces/`.
- Do not bypass `ConfigLoader` for runtime settings.
- Do not duplicate addon logic that should live in `addons/`.
- Avoid modifying the vendored `torchmoji/` code; treat it as an external dependency.

## Notes

- `src/static/` contains vendored FontAwesome assets; prefer CDN or upstream updates rather than hand-editing.
- `src/module_banlist` is an empty file placeholder; its purpose is unclear — check `config_loader.py` or `utils.py` before using it.
- Large files (e.g., `config_loader.py` ~92k, `base_llm.py` ~18k) are configuration-heavy; keep new code modular and out of those files when possible.