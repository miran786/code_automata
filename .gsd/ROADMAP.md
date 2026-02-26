# ROADMAP: SYNAPSE (The Bio-Digital Larynx)

> Execution plan to evolve into a Full-Duplex Communication Suit for deaf-mute students.
> Tagline: From Raw Muscle Signals to Fluent, Resonant Conversation.
> **Hackathon PS:** ET-4: Inclusive Learning Platform for Specially-Abled Students

---

## Phase 1: The Ear (Context Pipeline)
**Status**: ✅ Complete
**Milestone:** The Flutter App records classroom audio via the phone's microphone and streams it over WebSocket to the PC Hub. A Python script on the Hub uses `faster-whisper` to transcribe the stream locally, providing context for the LLM.

| # | Task | Target | Wave |
|---|------|--------|------|
| 1.1 | Setup virtual environment & install `faster-whisper` on PC | Hub | 1 |
| 1.2 | Create `whisper_service.py` to receive audio chunks via WebSocket and transcribe them | Hub | 1 |
| 1.3 | Implement audio recording in Flutter App using `record` package | App | 2 |
| 1.4 | Build WebSocket Client in App to stream raw audio chunks to the Hub | App | 2 |

---

## Phase 2: The IoT Glove (Input Array)
**Milestone:** Smart Glove acts as a hardware telemetry hub gathering 7D vectors (5 fingers + 2 tilt) and Heart Rate, broadcasting over WiFi.

| # | Task | Target | Wave |
|---|------|--------|------|
| 2.1 | Wire Arduino Uno with 5x Flex Sensors, MPU6050 (I2C), and Pulse Sensor | Hardware | 1 |
| 2.2 | Wire Split-Brain Bridge: Uno (5V TX) to ESP8266 (3.3V RX via Voltage Divider) | Hardware | 1 |
| 2.3 | Write Arduino C++ Firmware to format CSV strings `<F1..5, GX, GY, HR>` | Arduino | 2 |
| 2.4 | Write ESP8266 Firmware to establish WiFi and host WebSocket Server | ESP8266 | 2 |

---

## Phase 3: The Neural-Intent Engine (PC Hub Processing)
**Milestone:** PC Hub acts as the central brain. It receives vectors from the Glove, matches gestures robustly, queries local Ollama, and broadcasts the final sentence + context to the App via WebSocket.

| # | Task | Target | Wave |
|---|------|--------|------|
| 3.1 | Build Python WebSocket Server on PC Hub to receive IoT Glove data & sync App | Hub | 1 |
| 3.2 | Implement Vector-Space Recognition in Python: Cosine similarity against `GestureLibrary.json` | Hub | 1 |
| 3.3 | Create `intent_service.py` connecting to local Ollama API (e.g. Llama3/Mistral) | Hub | 2 |
| 3.4 | Implement prompt logic: Expand shorthand (e.g. "I Miran" -> "I am Miran") using Whisper context | Hub | 2 |
| 3.5 | Broadcast recognized gestures, Whisper transcripts, and Ollama output to Flutter App | Hub | 2 |

---

## Phase 4: The Bio-Digital Larynx (Output Array)
**Milestone:** Affective Resonance TTS changes voice based on heart rate, outputting back into the skull.

| # | Task | Target | Wave |
|---|------|--------|------|
| 4.1 | Wire PAM8403 Amplifier (with 100uF cap) to Audio Out and Bone Transducer | Hardware | 1 |
| 4.2 | Implement `voice_service.py` on PC Hub to generate local TTS audio | Hub | 1 |
| 4.3 | Add Affective Resonance logic: Modulate pitch and speed based on HR | Hub | 2 |

---

## Phase 5: Integration & The App Dashboard
**Milestone:** Seamless End-to-End System test. The Flutter App acts as a sleek "Telemetry Dashboard" showing exactly what the PC Hub is thinking and doing, including raw recorded audio, detected signs, and expanded sentences.

| # | Task | Target | Wave |
|---|------|--------|------|
| 5.1 | Build Flutter UI to display detected signs (e.g. "I Miran") and contextual expansions (e.g. "I am Miran") dynamically | App | 1 |
| 5.2 | Build unified `main.py` entrypoint on PC (coordinates Whisper, Serial, Ollama, TTS, WebSocket) | Hub | 2 |
| 5.3 | Rebrand App to SYNAPSE (Deep Purple/Cyan theme) | App | 2 |
| 5.4 | Rehearse 5-Step Demo (The Silence, Connection, Intelligence, Emotion, Climax) | Docs | 3 |

## Phase 6: Dockerization (Environment Harmony)
**Milestone:** Complete project containerization to eliminate "it works on my machine" issues. Hub, Backend, and Database all running in a single `docker-compose` network.

| # | Task | Target | Wave |
|---|------|--------|------|
| 6.1 | Create `Dockerfile` for Node.js Backend (Express + SQLite) | Backend | 1 |
| 6.2 | Create `Dockerfile` for PC Hub (Python + Whisper + Serial) | Hub | 1 |
| 6.3 | Configure `docker-compose.yml` to orchestrate Backend, Hub, and Ollama | DevSecOps | 1 |
| 6.4 | Optimize PC Hub image for GPU acceleration (if NVIDIA container toolkit available) | Hub | 2 |

---

## Phase 7: The Developer Cockpit (Quality of Life)
**Milestone:** A suite of internal tools to speed up iteration for the PC Hub and IoT transitions.

| # | Task | Target | Wave |
|---|------|--------|------|
| 7.1 | Setup `nodemon` / `debugpy` for the Python Hub to auto-reload on code changes | Hub | 1 |
| 7.2 | Create `scripts/simulate_glove.py` to pipe mock finger data into the WebSocket | Dev Tool | 1 |
| 7.3 | Implement an "Intent Playground" (simple CLI/UI to test Gemini/Ollama prompts) | Hub | 2 |
| 7.4 | Add a "Latency Probe" to the web dashboard to measure end-to-end delay (Glove → TTS) | Full Stack | 2 |

---

## Dependency Graph



```
Phase 1 (PC Whisper) ────┐
                         ├──▶ Phase 3 (PC Intent) ──▶ Phase 4 (PC Voice) ──▶ Phase 5
Phase 2 (IoT Glove) ──────┘                                                      ▲
                                                                                │
Phase 5a (App Theme / UI Polish) ───────────────────────────────────────────┤
                                                                                │
Phase 6 (Dockerization) ────────────────────────────────────────────────────────┘
```
