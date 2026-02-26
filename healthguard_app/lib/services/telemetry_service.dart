import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class TelemetryData {
  final String intent;
  final String speech;

  TelemetryData({required this.intent, required this.speech});

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      intent: json['intent'] ?? '',
      speech: json['speech'] ?? '',
    );
  }
}

class TelemetryService {
  // Use 10.0.2.2 for Android Emulator connecting to host localhost
  // Or put your PC's local IP address if using a physical device
  final String _wsUrl = 'ws://10.0.2.2:82';
  WebSocketChannel? _channel;

  Stream<TelemetryData>? get telemetryStream {
    if (_channel == null) return null;
    return _channel!.stream.map((data) {
      try {
        final decoded = jsonDecode(data);
        if (decoded['type'] == 'telemetry') {
          return TelemetryData.fromJson(decoded);
        }
      } catch (e) {
        print("Telemetry parsing error: $e");
      }
      return TelemetryData(intent: '', speech: '');
    });
  }

  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      print("Connected to Telemetry Server at $_wsUrl");
    } catch (e) {
      print("Failed to connect to Telemetry Server: $e");
    }
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
