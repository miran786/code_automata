# SYNAPSE: ET-4 Hackathon Demo Rehearsal

*The Bio-Digital Larynx for Deaf-Mute Students*

> **Goal:** Prove to the judges that SYNAPSE is a real, working, zero-latency system that bridges physical gesture, intelligent context, and biological emotion. Do not rely on "imagine if" statements. Show them.

## The 5-Step Presentation Climax

### Step 1: The Silence (Hardware Intro)
- **Action:** Hold up the IoT Smart Glove. Open the `SYNAPSE` Flutter App on the phone. Ensure the PC terminal is visible.
- **Script:** *"For millions of deaf-mute students, the classroom is a silent movie. Today, we give them a voice. This is the SYNAPSE Smart Glove. It continuously streams 7-Dimensional vector data of hand movements. Let's start the engine."*

### Step 2: The Connection (System Boot)
- **Action:** Run `python hub/main_server.py` on the PC.
- **Visuals:** The terminal displays `THE SYNAPSE HUB IS ONLINE`. The Flutter App immediately connects and the `WAITING FOR GLOVE...` text turns into a live telemetry feed.
- **Script:** *"The Hub is alive. Our Flutter App is now synchronously paired with the brain via WebSockets on port 82, acting as our Telemetry Dashboard."*

### Step 3: The Intelligence (Generative Context)
- **Action:** Use `simulate_glove.py` to trigger the `question` intent (or physically sign it if hardware is wired).
- **Visuals:** The Flutter App flashes `[ SIGN DETECTED: QUESTION ]`. Instantly, underneath, it expands to `Translation: "Excuse me, Professor. I have a question about photosynthesis."`
- **Script:** *"A generic sign for 'question' is useless without context. SYNAPSE listens to the classroom audio via Whisper, and processes the intent locally through Ollama to generate a contextually perfect sentence. It knows the teacher is talking about photosynthesis."*

### Step 4: The Emotion (Affective Resonance)
- **Action:** In `simulate_glove.py`, type `hr 120` to spike the heart rate to an anxious level. Sign `question` again.
- **Visuals/Audio:** The system plays the TTS audio out loud, but visibly and audibly *faster* (1.30x speed).
- **Script:** *"Digital voices sound dead. SYNAPSE reads the student's heartbeat. If their heart rate is 75 BPM, the voice is calm. If they are anxious, excited, or rushed—like an HR of 120 BPM—the voice speeds up. This is Affective Resonance."*

### Step 5: The Climax (Bone Conduction)
- **Action:** Hand the wired 8Ω Bone Conduction Transducer (connected to the PAM8403) directly to the judge.
- **Script:** *"Hold this against your cheekbone. I'm going to speak for the student."*
- **Action:** Sign a final phrase. Let the TTS play directly into the transducer.
- **Script:** *"We don't just speak for them. We let them physically feel their synthesized voice vibrating through their skull. This is the Bio-Digital Larynx."*

---
**END OF DEMO**
