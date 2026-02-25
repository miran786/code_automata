import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/config/ai_config.dart';
import 'package:mobile/models/chat_message.dart';
import 'package:mobile/models/user_vitals.dart';
import 'package:mobile/services/api_service.dart';

class ChatService {
  final String userId;

  /// Multi-turn conversation history for this session.
  /// Gemini uses roles "user" and "model".
  final List<Map<String, dynamic>> _history = [];

  ChatService({this.userId = ApiService.defaultUserId});

  String _vitalsContext(UserVitals? vitals) {
    if (vitals == null) return 'No vitals data available.';
    final parts = <String>[];
    if (vitals.heartRates.isNotEmpty) {
      parts.add('Heart rate: ${vitals.heartRates.first.value} bpm');
    }
    if (vitals.bloodPressures.isNotEmpty) {
      final bp = vitals.bloodPressures.first;
      parts.add('Blood pressure: ${bp.systolic}/${bp.diastolic} mmHg');
    }
    if (vitals.bloodGlucose.isNotEmpty) {
      parts.add('Blood glucose: ${vitals.bloodGlucose.first.value} mg/dL');
    }
    if (vitals.todaySteps > 0) {
      parts.add('Steps today: ${vitals.todaySteps}');
    }
    if (vitals.todayCalories > 0) {
      parts.add(
        'Calories burned: ${vitals.todayCalories.toStringAsFixed(0)} kcal',
      );
    }
    if (vitals.todayActiveMinutes > 0) {
      parts.add('Active minutes: ${vitals.todayActiveMinutes} min');
    }
    return parts.isEmpty ? 'No vitals data available.' : parts.join(', ');
  }

  /// Send a message to the Gemini AI health assistant.
  Future<ChatMessage?> sendMessage(String text, {UserVitals? vitals}) async {
    _history.add({
      'role': 'user',
      'parts': [
        {'text': text},
      ],
    });

    try {
      final response = await http
          .post(
            Uri.parse(AiConfig.baseUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'system_instruction': {
                'parts': [
                  {
                    'text':
                        'You are HealthGuard AI, a friendly and knowledgeable personal health assistant. '
                            'You provide personalised, empathetic health guidance based on the user\'s real-time vitals. '
                            'Keep responses concise (2–4 sentences). Always recommend consulting a doctor for medical decisions.\n\n'
                            'Current patient vitals: ${_vitalsContext(vitals)}',
                  },
                ],
              },
              'contents': _history,
              'generationConfig': {'maxOutputTokens': 512},
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final responseText =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        _history.add({
          'role': 'model',
          'parts': [
            {'text': responseText},
          ],
        });

        // Keep conversation window at most 20 messages (10 turns)
        if (_history.length > 20) {
          _history.removeRange(0, 2);
        }

        return ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        _history.removeLast();
        // ignore: avoid_print
        print('[ChatService] Non-200 response: ${response.statusCode}\n${response.body}');
        return _offlineFallback(text, vitals);
      }
    } catch (e) {
      if (_history.isNotEmpty) _history.removeLast();
      // ignore: avoid_print
      print('[ChatService] API error: $e');
      return _offlineFallback(text, vitals);
    }
  }

  /// Keyword-based fallback when the API is unreachable.
  ChatMessage _offlineFallback(String text, UserVitals? vitals) {
    String reply =
        "I'm having trouble reaching the AI server right now. Please check your internet connection and try again.";

    final lower = text.toLowerCase();
    if (lower.contains('blood pressure') || lower.contains(' bp')) {
      if (vitals != null && vitals.bloodPressures.isNotEmpty) {
        final bp = vitals.bloodPressures.first;
        reply =
            'Your latest blood pressure is ${bp.systolic}/${bp.diastolic} mmHg.';
      }
    } else if (lower.contains('heart rate') || lower.contains('pulse')) {
      if (vitals != null && vitals.heartRates.isNotEmpty) {
        reply =
            'Your latest heart rate is ${vitals.heartRates.first.value} bpm.';
      }
    } else if (lower.contains('glucose') || lower.contains('sugar')) {
      if (vitals != null && vitals.bloodGlucose.isNotEmpty) {
        reply =
            'Your latest blood glucose is ${vitals.bloodGlucose.first.value} mg/dL.';
      }
    }

    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: reply,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  Future<List<ChatMessage>> getChatHistory() async => [];
}
