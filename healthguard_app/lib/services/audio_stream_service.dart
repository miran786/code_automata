import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class AudioStreamService {
  WebSocketChannel? _channel;
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<List<int>>? _audioStreamSubscription;
  bool _isRecording = false;

  bool get isRecording => _isRecording;

  void connect(String wsUrl) {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      debugPrint("Connected to WebSocket: $wsUrl");
    } catch (e) {
      debugPrint("WebSocket connection error: $e");
    }
  }

  Future<void> startStreaming() async {
    if (_channel == null) {
      debugPrint("Cannot start streaming: WebSocket not connected.");
      return;
    }

    try {
      if (await _audioRecorder.hasPermission()) {
        // Start recording to a stream
        final stream = await _audioRecorder.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );

        _isRecording = true;
        debugPrint("Started audio streaming.");

        _audioStreamSubscription = stream.listen(
          (data) {
            // Send binary raw PCM data over WebSocket
            _channel?.sink.add(data);
          },
          onError: (error) {
            debugPrint("Error in audio stream: $error");
          },
          onDone: () {
            debugPrint("Audio stream ended.");
          },
        );
      } else {
        debugPrint("Microphone permission denied.");
      }
    } catch (e) {
      debugPrint("Failed to start audio streaming: $e");
    }
  }

  Future<void> stopStreaming() async {
    try {
      _isRecording = false;
      await _audioStreamSubscription?.cancel();
      _audioStreamSubscription = null;
      await _audioRecorder.stop();
      debugPrint("Stopped audio streaming.");
    } catch (e) {
      debugPrint("Error stopping audio stream: $e");
    }
  }

  void disconnect() {
    stopStreaming();
    _channel?.sink.close();
    _channel = null;
    debugPrint("Disconnected from WebSocket.");
  }
}
