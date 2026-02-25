# STATE.md — Project Memory

## Last Session Summary
On 2026-02-25, completed deep roadmap analysis and improvement.
- Fixed `pubspec.yaml`: moved `google_generative_ai` to production deps (was in dev_deps → release crash), removed unused `speech_to_text`, added `web_socket_channel`
- Rewrote `ROADMAP.md` with improved 5-phase plan: added mock services, model download manager, permission handling, calibration flow, demo mode, offline templates, and structural patterns
- Updated `ARCHITECTURE.md` technical debt (2 items resolved)
- Updated project description to "SYNAPSE — Bio-Digital Larynx for Deaf-Mute Students"

## Current Position
- **Phase**: 1 (The Ear — Local Whisper STT)
- **Task**: Plans ready, awaiting execution
- **Status**: Run `/execute 1` to begin

## Technology Decisions
| Decision | Choice | Why |
|----------|--------|-----|
| Local Whisper | whisper_ggml_plus ^1.3.3 | whisper.cpp bindings, Large-v3-Turbo support, 1.2K downloads |
| WebSocket | web_socket_channel ^3.0.3 | Official Dart team, 5.5M downloads |
| Audio Recording | record ^5.1.2 | Modern Flutter recording |
| Model | ggml-tiny.en.bin | 75MB, fast inference, English-only (sufficient for demo) |
| Gemini SDK | google_generative_ai ^0.4.0 | Now in production deps (was broken in dev_deps) |

## Key Improvements (from deep analysis)
- Every new service gets a Mock variant for demo reliability
- IntentService has offline template fallback (no internet → still speaks)
- Phase 3 can start in parallel using mock data from Phases 1 & 2
- Demo Mode button in Phase 5 for bulletproof hackathon demos

## Next Steps
1. Execute Phase 1 (Whisper + Classroom UI)
2. Then Phase 2 (IoT Telemetry)
3. Phases 1 & 2 can run in parallel
4. Phase 3 can begin early using mock services
