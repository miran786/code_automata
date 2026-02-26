import 'package:flutter/material.dart';
import '../../services/audio_stream_service.dart';

class ClassroomScreen extends StatefulWidget {
  const ClassroomScreen({Key? key}) : super(key: key);

  @override
  State<ClassroomScreen> createState() => _ClassroomScreenState();
}

class _ClassroomScreenState extends State<ClassroomScreen> {
  final AudioStreamService _audioStreamService = AudioStreamService();
  bool _isRecording = false;
  final String _wsUrl =
      "ws://10.0.2.2:8765"; // Default Android emulator IP to host PC

  // Dummy data for visual proof-of-concept
  final List<String> _transcripts = ["Waiting for transcription..."];

  @override
  void initState() {
    super.initState();
    // Connect to WebSocket on init
    _audioStreamService.connect(_wsUrl);
  }

  @override
  void dispose() {
    _audioStreamService.disconnect();
    super.dispose();
  }

  void _toggleRecording() async {
    if (_isRecording) {
      await _audioStreamService.stopStreaming();
      setState(() {
        _isRecording = false;
      });
    } else {
      await _audioStreamService.startStreaming();
      setState(() {
        _isRecording = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _transcripts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _transcripts[index],
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: GestureDetector(
              onTap: _toggleRecording,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : Colors.deepPurple,
                  boxShadow: _isRecording
                      ? [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.6),
                            spreadRadius: 8,
                            blurRadius: 16,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
