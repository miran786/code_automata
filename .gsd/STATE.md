# STATE.md — Project Memory

## Last Session Summary
On 2026-02-25, completely pivoted project to actualize **SYNAPSE (The Bio-Digital Larynx)** targeting Hackathon PS ET-4.
- Integrated complete IoT Hardware BOM (Arduino, ESP8266, MPU6050, Flex Sensors, Pulse Sensor, Bone Conduction).
- Replaced Phone-Vitals dependency with physical Pulse Sensor on the Smart Glove.
- Upgraded Gesture Matching to 7D Vector-Space Recognition via Cosine Similarity.
- Added Affective Resonance (Heart Rate modulates TTS Pitch/Speed).
- Re-architected data flow to rely on ESP8266 WebSocket streaming instead of USB serial.
- Phase 1 executed successfully. 2 plans, 6 tasks completed (PC Hub Whisper WebSocket Server + Flutter Audio Stream Service).

## Current Position
- **Phase**: 2
- **Task**: Planning complete
- **Status**: Ready for execution

## Technology Decisions
| Decision | Choice | Why |
|----------|--------|-----|
| Central Brain | PC Hub (Python) | Processes Whisper, Cosine Similarity, and Ollama in one beefy local machine |
| App Role | Mic & Display Dashboard | App captures mic audio and sends to PC. It runs ZERO logic, but displays detected signs (e.g. "I Miran") and expansions (e.g. "I am Miran") |
| Audio Recording | `record` package (Flutter) | Modern, robust Flutter audio capturing library for capturing classroom context |
| Local Whisper | faster-whisper (Python) | running on the PC Hub, parses the audio chunks sent by the Flutter App |
| Microcontrollers | Arduino Uno (or Nano) + ESP8266 | Split-brain architecture: 5V analog muscles (Uno) + 3.3V WiFi brain (ESP) |
| Hub Sync | Python WebSocket Server | Receives Audio/Vectors, and streams Transcripts and inferred signs back to the App |
| Output Audio | PAM8403 + Bone Conduction | Phantom voice feedback creates neurological loop of speaking |
| AI Intent | Local Ollama (Python layer) | Translates shorthand phrases locally, ensuring ultra-low latency, privacy, and full offline capability without API keys |

## Key Improvements (from deep analysis)
- Hardware replaces finicky smartwatch integration (Pulse Sensor directly on I2C/Analog).
- Smart Glove is truly wireless using ESP8266 WiFi Gateway.
- Vector matching is resilient to shaky hands unlike raw if/else thresholds.

## Next Steps
1. Run `/execute 2` to implement hardware wiring docs, firmware, and mock generator.
2. Procure missing physical hardware if not already done. Use the mock generator to continue PC Hub development in parallel.
