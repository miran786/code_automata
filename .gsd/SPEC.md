# SYNAPSE — The Bio-Digital Larynx

> Full-Duplex Communication Suit for Deaf-Mute Students
> Hackathon Track: ET-4 — Inclusive Learning Platform for Specially-Abled Students

---

## 1. Problem

Current assistive technology is **passive**. It gives deaf-mute students a screen to read, but:

- **No instant participation.** They can't raise a hand and speak in class.
- **No intent.** A raw sign-language-to-word lookup produces robotic, fragmented output ("Teacher... question") instead of fluent speech.
- **No emotion.** Synthesized voices sound dead. A student's excitement or anxiety is lost.
- **No feedback loop.** The student never "hears" their own voice, breaking the neurological connection between expression and sound.

**Result:** Isolation, not inclusion.

---

## 2. Solution

SYNAPSE is a **hardware + software communication suit** that acts as a physical extension of the body:

| Direction | Flow | Innovation |
|-----------|------|------------|
| **Hand → Voice** | Smart Glove gestures → 7D vector matching → Gemini LLM context → Fluent speech | Neural-Intent Engine |
| **Heart → Voice** | Pulse sensor → TTS pitch/rate modulation | Affective Resonance |
| **Voice → Bone** | Classroom audio → Local Whisper STT → Bone conduction | Phantom Voice Feedback |

The student signs. The system speaks fluently, with emotion. The student hears their own digital voice vibrating in their skull. For the first time, signing **feels like speaking.**

---

## 3. System Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                    SMART GLOVE & IOT                          │
│  5× Flex Sensors │ MPU6050 Gyro │ Pulse Sensor               │
│         └──────────────┬──────────────┘                      │
│              Arduino Uno (reads sensors, drives amp)          │
│                        │ Serial                              │
└────────────────────────┼─────────────────────────────────────┘
                         │
┌────────────────────────┼─────────────────────────────────────┐
│              PC HUB (The Brain & Voice)                       │
│                        │                                     │
│  ┌─────────────────────┴───────────────────────────┐         │
│  │           Serial Listener                         │        │
│  │  Receives: <F1,F2,F3,F4,F5,GX,GY>               │        │
│  └──────┬──────────────┬───────────────┬────────────┘        │
│         │              │               │                     │
│  ┌──────┴──────┐ ┌─────┴─────┐  ┌──────┴──────┐             │
│  │ GestureEngine│ │VoiceService│  │ VitalsReceiver│<─(WiFi)─┐ │
│  │ 7D Cosine   │ │ TTS Output │  │ Modulates   │          │ │
│  │ Similarity  │ │ to Arduino │  │ HR→Pitch    │          │ │
│  └──────┬──────┘ └─────┬─────┘  └─────────────┘          │ │
│         │              │                                 │ │
│  ┌──────┴──────┐       │                                 │ │
│  │IntentService│       │                                 │ │
│  │ Gemini LLM  │───────┘                                 │ │
│  │ Context Gen │                                         │ │
│  └─────────────┘                                         │ │
│                                                          │ │
│  ┌──────────────────────────────────────────────┐        │ │
│  │          Whisper STT                           │        │ │
│  │  Classroom mic → Whisper.cpp (PC GPU)          │        │ │
│  │  → Bone Conduction transducer connected to     │        │ │
│  │    Arduino                                     │        │ │
│  └──────────────────────────────────────────────┘        │ │
└────────────────────────┬─────────────────────────────────────┘
                         │                                 │
┌────────────────────────┼─────────────────────────────────┼───┐
│              FLUTTER APP (Vitals Client)                 │   │
│                        │                                 │   │
│  ┌───────────────────────────────────────────────┐       │   │
│  │  HealthService (Health Connect vitals)          ├───────┘   │
│  │  TelemetryClient (Sends HR to PC over WiFi)     │           │
│  │  ApiService (Backend sync)                      │           │
│  │  ChatService (Gemini AI chat)                   │           │
│  │  DashboardScreen (Views health/device stat)     │           │
│  └───────────────────────────────────────────────┘           │
└──────────────────────────────────────────────────────────────┘
                         │
┌────────────────────────┼─────────────────────────────────────┐
│              NODE.JS BACKEND (Existing)                       │
│  Express + SQLite │ Patient/Doctor/Vitals/Appointments        │
└──────────────────────────────────────────────────────────────┘

OUTPUT HARDWARE:
  └── PAM8403 Amp → Bone Conduction Transducer (8Ω)
      └── Connected to Arduino PWM / DAC output
```

---

## 4. Core Innovations

### 4A. Neural-Intent Engine (Gesture → Fluent Speech)

**The Problem with naive gesture recognition:** Mapping "Hello" sign → word "Hello" produces robotic output.

**Our approach:**

1. **Vector-Space Recognition:** Each hand gesture is a **7-dimensional vector**: `[Flex1, Flex2, Flex3, Flex4, Flex5, GyroX, GyroY]`. We compare incoming vectors against a reference `GestureLibrary` using **Cosine Similarity**, which is tolerant of:
   - Tired or shaky hands
   - Variations in signing style
   - Partial gestures

2. **Context-Aware Refinement:** The matched intent (e.g., "question") is NOT spoken directly. Instead:
   ```
   Intent: "question"
   Classroom Context (from Whisper): "The teacher is explaining photosynthesis"
   → Gemini LLM generates: "Excuse me, Professor. I have a question about photosynthesis."
   ```

3. **Implementation:** Cosine similarity function in Dart, `GestureLibrary.json` as reference vectors, existing `ChatService`/Gemini integration modified to accept gesture intents.

### 4B. Affective Resonance (Heart → Voice Emotion)

**The Problem:** Synthesized speech sounds dead regardless of the student's emotional state.

**Our approach:**

- The Pulse Sensor on the glove measures real-time heart rate.
- The heart rate modulates `flutter_tts` parameters:

| Heart Rate | Emotion Proxy | TTS Pitch | TTS Rate |
|------------|---------------|-----------|----------|
| < 65 BPM   | Calm          | 0.8×      | 0.85×    |
| 65–85 BPM  | Normal        | 1.0×      | 1.0×     |
| 85–100 BPM | Engaged       | 1.1×      | 1.1×     |
| > 100 BPM  | Excited/Anxious | 1.3×    | 1.25×    |

- **Result:** When a student excitedly signs "Win!", the voice **sounds** excited. This is the Bio-Digital Larynx effect.

### 4C. Phantom Voice Feedback (Voice → Bone)

**The Problem:** Deaf students have never heard their own voice. There is no neurological loop between expression and sound.

**Our approach:**

- A **bone conduction transducer** on the cheekbone vibrates sound directly into the skull, bypassing the ear canal.
- The student feels their generated speech the **instant** they sign.
- Over time, this creates a neurological association: signing → feeling sound → "speaking."
- Audio is streamed via WiFi from the phone to the ESP8266, completely untethering the student from the device.

---

## 5. Technology Stack

### Software

| Component | Package | Version | Why This One |
|-----------|---------|---------|--------------|
| Local STT | `whisper_ggml_plus` | ^1.3.3 | whisper.cpp bindings, Large-v3-Turbo support, 1.2K downloads, active maintenance |
| WebSocket | `web_socket_channel` | ^3.0.3 | Official Dart team package, 5.5M downloads, battle-tested |
| TTS | `flutter_tts` | ^4.2.5 | Already in project, supports pitch/rate modulation |
| LLM | `google_generative_ai` | ^0.4.0 | Already in project (Gemini), used for context-aware sentence generation |
| Health Data | `health` | ^13.0.0 | Already in project, Health Connect integration |
| Audio Record | `record` | ^5.1.2 | Modern Flutter audio recording |
| Model Weights | `ggml-tiny.en.bin` | — | ~75MB quantized Whisper model for on-device inference |

### Hardware

| Component | Qty | Role |
|-----------|-----|------|
| Arduino Uno R3 | 1 | Sensor reader (5V analog + I2C) |
| ESP8266 NodeMCU | 1 | WiFi gateway (WebSocket server) |
| Flex Sensors (2.2") | 5 | Finger bend detection |
| MPU6050 | 1 | 6-axis gyro/accelerometer for hand tilt |
| Pulse Sensor | 1 | Heart rate for emotion modulation |
| Bone Conduction Transducer (8Ω) | 1 | Sound output through skull vibration |
| PAM8403 Class-D Amp | 1 | Audio amplification |

### Existing Codebase (Reused)

| Service | Reuse Level | What Changes |
|---------|-------------|--------------|
| `HealthService` | Full reuse | None — continues reading Health Connect vitals |
| `ApiService` | Full reuse | None — backend sync unchanged |
| `ChatService` | Modified | Accepts gesture intent + Whisper context as input |
| `CoachingService` | Full reuse | None |
| `SpikeAlertService` | Full reuse | None — HR spike alerts still work |
| Backend (Node.js) | Full reuse | None |

---

## 6. Data Flow (End-to-End)

```
STUDENT SIGNS "QUESTION"
        │
        ▼
[Arduino reads flex sensors + gyro]
        │ Serial: "512,890,200,780,340,0.45,-0.12"
        ▼
[PC Hub Python Script parses Serial]
        │
        ├──▶ GestureEngine: cosine_similarity([512,890,200,780,340,0.45,-0.12]) → "question"
        │
        ├──▶ Whisper (PC): classroom audio → "The teacher is explaining photosynthesis"
        │
        ├──▶ IntentService (Gemini on PC): intent="question" + context="photosynthesis" 
        │         → "Excuse me, Professor. I have a question about photosynthesis."
        │
        ├──▶ VoiceService (PC): Receives HR via WebSocket from Flutter App
        │         → HR=78 (Normal) → pitch=1.0, rate=1.0
        │         → Plays TTS Audio over Serial/Audio Out to Arduino
        │
        └──▶ Arduino routes audio to PAM8403 + Bone Conduction transducer
              Student hears their own voice in their skull
```

---

## 7. Success Criteria

For the hackathon demo, SYNAPSE must demonstrate:

- [ ] **Gesture → Speech:** Sign at least 5 gestures (Hello, Question, Yes, No, Help) and hear fluent, context-aware sentences.
- [ ] **Emotion in Voice:** Demonstrate pitch/speed change when heart rate varies (e.g., jog in place → excited voice).
- [ ] **Classroom Listening:** Whisper transcribes spoken words locally on the phone (no internet required).
- [ ] **Bone Conduction:** A judge can feel sound vibrations through the transducer on their cheekbone.
- [ ] **Health Monitoring:** Dashboard shows live vitals from the watch (existing feature).
- [ ] **AI Chat:** Student can ask health questions, get AI responses (existing feature).

---

## 8. Non-Goals (For This Hackathon)

- Training a custom ML model for gesture classification (Cosine Similarity is sufficient and more explainable to judges).
- Supporting multiple languages (English only for the demo, via `ggml-tiny.en.bin`).
- Manufacturing a polished physical glove (focus is on the software brain).
- Multi-user classroom support (single student demo).
