---
phase: 1
plan: 1
wave: 1
depends_on: []
files_modified:
  - healthguard_app/pubspec.yaml
  - healthguard_app/lib/services/whisper_service.dart
autonomous: false

must_haves:
  truths:
    - "whisper_ggml_plus compiles and initializes successfully on Android"
    - "ggml-tiny.en.bin model is downloaded to the device storage"
    - "Audio can be recorded and transcribed locally without internet"
  artifacts:
    - "healthguard_app/lib/services/whisper_service.dart"
---

# Plan 1.1: Local Whisper Service + Model

<objective>
Create the on-device speech-to-text engine using whisper_ggml_plus (whisper.cpp).
This is the foundation of the "Ear" — everything in Phase 1 depends on this service working.

Purpose: Enable fully offline, private speech-to-text on the student's phone.
Output: A `WhisperService` class that can record audio and transcribe it locally.
</objective>

<context>
Load for context:
- .gsd/SPEC.md (Section 5: Technology Stack, Section 4C: Phantom Voice Feedback)
- healthguard_app/pubspec.yaml
</context>

<tasks>

<task type="auto">
  <name>Add dependencies and verify resolution</name>
  <files>healthguard_app/pubspec.yaml</files>
  <action>
    Add to `dependencies:` section:
    - `whisper_ggml_plus: ^1.3.3` (local whisper.cpp inference)
    - `record: ^5.1.2` (audio recording)
    - `path_provider: ^2.1.2` (temp file storage for recorded audio)

    Run `flutter pub get` in `healthguard_app/`.

    AVOID: Modifying existing dependency versions. The existing `speech_to_text` and `flutter_tts` packages must remain intact — they serve different purposes (speech_to_text is for voice COMMANDS, whisper is for CLASSROOM TRANSCRIPTION).
  </action>
  <verify>cd healthguard_app; flutter pub get</verify>
  <done>`flutter pub get` succeeds. `pubspec.lock` contains `whisper_ggml_plus`, `record`, `path_provider`.</done>
</task>

<task type="auto">
  <name>Create WhisperService with model download and local inference</name>
  <files>healthguard_app/lib/services/whisper_service.dart</files>
  <action>
    Create `WhisperService` as a singleton class with these methods:

    1. `Future<void> initialize()`:
       - Use `whisper_ggml_plus` to check if the model exists on local storage (via `path_provider` getApplicationDocumentsDirectory).
       - If model does not exist, download `ggml-base.en.bin` (or `ggml-small.en.bin` for even better accuracy since you have the RTX 4060) from the public Hugging Face URL:
         `https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin`
       - Initialize the whisper instance with the downloaded model path.
       - Expose an `isInitialized` getter.

    2. `Future<void> startRecording()`:
       - Use the `record` package to begin recording audio to a temp `.wav` file.
       - Save to `<appDocDir>/whisper_recording.wav`.
       - Set format to WAV, sample rate 16000 Hz (what Whisper expects).

    3. `Future<String> stopAndTranscribe()`:
       - Stop the recorder.
       - Pass the WAV file path to whisper_ggml_plus for local inference.
       - Return the transcribed text string.
       - Handle errors (model not loaded, empty audio, inference failure) gracefully with try/catch.

    4. `void dispose()`:
       - Clean up the whisper instance and recorder resources.

    AVOID:
    - Any network calls for transcription (model download is a ONE-TIME setup).
    - Storing large model files in Flutter assets (download to app storage instead).
    - Blocking the main isolate — ensure inference runs asynchronously.
  </action>
  <verify>cd healthguard_app; dart analyze lib/services/whisper_service.dart</verify>
  <done>`WhisperService` compiles with zero analysis errors. Exposes `initialize()`, `startRecording()`, `stopAndTranscribe()`, `dispose()` methods.</done>
</task>

<task type="checkpoint:human-verify">
  <name>Verify Whisper inference on a real device</name>
  <files>healthguard_app/lib/services/whisper_service.dart</files>
  <action>
    Build and run the app on a real Android device.
    Invoke `WhisperService.initialize()` (will download ~75MB model on first run).
    Record a few seconds of speech and call `stopAndTranscribe()`.
    Verify the returned string matches what was spoken.
  </action>
  <verify>Manual test on real Android device. Check logcat output for transcription result.</verify>
  <done>WhisperService successfully transcribes spoken English on-device without internet.</done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] `flutter pub get` resolves all dependencies
- [ ] `dart analyze` passes with zero errors on `whisper_service.dart`
- [ ] Model downloads on first app launch
- [ ] Transcription works offline after model is cached
</verification>

<success_criteria>
- [ ] All tasks verified
- [ ] Must-haves confirmed
</success_criteria>
