# ROADMAP: SYNAPSE (PC Hub Architecture)

> Execution plan to evolve HealthGuard → SYNAPSE
> This roadmap reflects the **PC Hub Architecture**, where a local PC acts as the "Brain" and the Flutter app acts as a telemetry client.

---

## Phase 1: The Ear (PC Whisper Pipeline)
**Milestone:** A Python script on the PC (RTX 4060) can listen to the classroom mic and transcribe locally in real-time.

| # | Task | Target | Wave |
|---|------|--------|------|
| 1.1 | Setup Python virtual environment & install `faster-whisper` | PC Hub | 1 |
| 1.2 | Download `ggml-base.en.bin` (or small) to PC storage | PC Hub | 1 |
| 1.3 | Create `whisper_service.py` (live mic stream → fast transcription chunks) | PC Hub | 1 |
| 1.4 | Add WebSocket server in Python to broadcast transcriptions to clients | PC Hub | 2 |
| 1.5 | Build simple Flutter `ClassroomScreen` that connects to PC WebSocket and displays text | Flutter | 2 |

**Demo:** Speak into PC mic → text appears instantly on the Flutter app screen. Fully offline inference.

---

## Phase 2: The Vitals Stream (Phone → PC)
**Milestone:** Flutter app streams real-time heart rate from smartwatch/Health Connect to the PC.

| # | Task | Target | Wave |
|---|------|--------|------|
| 2.1 | Add WebSocket endpoint `/vitals` to PC Python server | PC Hub | 1 |
| 2.2 | Update Flutter `HealthService` to read continuous HR (or mock HR for demo) | Flutter | 1 |
| 2.3 | Create `TelemetryClient` in Flutter to squirt HR data to PC WebSocket every second | Flutter | 1 |
| 2.4 | Create Python `vitals_receiver.py` to keep latest HR state in memory | PC Hub | 2 |

**Demo:** Jog wearing smartwatch → PC console logs rising heart rate in real-time.

---

## Phase 3: The Brain (Serial Gestures + Intent)
**Milestone:** Arduino sends flex data over USB/Serial. PC matches the gesture, asks Gemini for context, and generates a sentence.

| # | Task | Target | Wave |
|---|------|--------|------|
| 3.1 | Create `serial_listener.py` to read `<F1..5, GX, GY>` from Arduino | PC Hub | 1 |
| 3.2 | Create `gesture_engine.py` (cosine similarity against `gesture_library.json`) | PC Hub | 1 |
| 3.3 | Create `intent_service.py` to prompt Gemini API (gesture + recent whisper transcript) | PC Hub | 2 |
| 3.4 | Implement offline template fallback in Python (if Gemini rate-limited/offline) | PC Hub | 2 |

**Demo:** Bend glove fingers → PC terminal prints: "Gesture: Question. Generated: Excuse me, Professor..."

---

## Phase 4: The Voice (Affective Resonance TTS)
**Milestone:** PC generates speech via Edge TTS or local Python TTS, modulated by the heart rate received from Phase 2. Arduino drives the speaker.

| # | Task | Target | Wave |
|---|------|--------|------|
| 4.1 | Install `pyttsx3` or `edge-tts` in Python environment | PC Hub | 1 |
| 4.2 | Create `voice_service.py` with continuous HR → Pitch/Rate interpolation | PC Hub | 1 |
| 4.3 | Wire generation: Intent → VoiceService → Audio output channel (3.5mm out to PAM8403) | PC Hub | 2 |
| 4.4 | Configure PC audio routing to ensure Arduino PAM8403 receives output | Hardware | 2 |

**Demo:** Sign "Win" while HR is 120bpm → PC outputs high-pitched, fast "We're going to WIN!" audio directly to bone transducer.

---

## Phase 5: The Body (Integration & Polish)
**Milestone:** Full end-to-end system test. Rebranded app. Bulletproof demo mode.

| # | Task | Target | Wave |
|---|------|--------|------|
| 5.1 | Rebrand Flutter app to "SYNAPSE" (Deep Purple / Cyan theme, splash screen) | Flutter | 1 |
| 5.2 | Update Dashboard to show PC Connection Status (Red/Green LED) | Flutter | 1 |
| 5.3 | Build unified `main.py` entrypoint on PC (coordinates Whisper, Serial, TTS, WebSocket) | PC Hub | 2 |
| 5.4 | Create "Mock Serial" mode in Python for software-only testing | PC Hub | 2 |
| 5.5 | Write 3-minute Demo Script and rehearse | Documentation | 3 |

**Demo:** The ultimate "Wow" sequence. Glove → PC → Gemini → Voice out to Transducer + Phone shows transcript.

---

## Dependency Graph

```
Phase 1 (PC Whisper) ────┐
                         ├──▶ Phase 3 (PC Intent) ──▶ Phase 4 (PC Voice) ──▶ Phase 5
Phase 2 (Phone Vitals) ──┘                                                      ▲
                                                                                │
Phase 5a (Flutter Theme / UI Polish) ───────────────────────────────────────────┘
```
