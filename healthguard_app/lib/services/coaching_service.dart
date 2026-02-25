import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/config/ai_config.dart';
import 'package:mobile/models/coaching_plan.dart';
import 'package:mobile/models/user_vitals.dart';
import 'package:mobile/services/api_service.dart';

class CoachingService {
  final String userId;

  CoachingService({this.userId = ApiService.defaultUserId});

  String _vitalsContext(UserVitals vitals) {
    final parts = <String>[];
    if (vitals.heartRates.isNotEmpty) {
      parts.add('HR: ${vitals.heartRates.first.value} bpm');
    }
    if (vitals.bloodPressures.isNotEmpty) {
      final bp = vitals.bloodPressures.first;
      parts.add('BP: ${bp.systolic}/${bp.diastolic} mmHg');
    }
    if (vitals.bloodGlucose.isNotEmpty) {
      parts.add('Glucose: ${vitals.bloodGlucose.first.value} mg/dL');
    }
    parts.add('Steps: ${vitals.todaySteps}');
    parts.add('Active: ${vitals.todayActiveMinutes} min');
    parts.add(
      'Calories burned: ${vitals.todayCalories.toStringAsFixed(0)} kcal',
    );
    return parts.join(', ');
  }

  /// Fetch a personalised AI coaching plan based on the user's current vitals.
  Future<CoachingPlan?> getCoachingPlan(UserVitals vitals) async {
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
                        'You are a certified health coach AI. Respond ONLY with valid JSON and no extra text or markdown fences.',
                  },
                ],
              },
              'contents': [
                {
                  'role': 'user',
                  'parts': [
                    {
                      'text': '''Generate a personalised daily health coaching plan for this patient.
Patient vitals: ${_vitalsContext(vitals)}

Respond with this exact JSON structure (no markdown, no extra keys):
{
  "dailyFocus": "<one motivating sentence tailored to their vitals>",
  "dietSuggestions": [
    {"title": "<short title>", "description": "<1 sentence advice>", "icon": "water"},
    {"title": "<short title>", "description": "<1 sentence advice>", "icon": "leaf"},
    {"title": "<short title>", "description": "<1 sentence advice>", "icon": "restaurant"}
  ],
  "exerciseRoutine": [
    {"title": "<short title>", "description": "<1 sentence routine>", "icon": "directions_walk"},
    {"title": "<short title>", "description": "<1 sentence routine>", "icon": "fitness_center"}
  ]
}''',
                    },
                  ],
                },
              ],
              'generationConfig': {'maxOutputTokens': 800},
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final text =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        // Strip markdown fences if Gemini wraps the JSON anyway
        final cleaned = text
            .replaceAll(RegExp(r'^```json\s*', multiLine: true), '')
            .replaceAll(RegExp(r'^```\s*', multiLine: true), '')
            .trim();

        final planJson = jsonDecode(cleaned) as Map<String, dynamic>;

        return CoachingPlan(
          userId: userId,
          dailyFocus: planJson['dailyFocus'] as String,
          dietSuggestions: (planJson['dietSuggestions'] as List)
              .map(
                (item) =>
                    CoachingPlanItem.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
          exerciseRoutine: (planJson['exerciseRoutine'] as List)
              .map(
                (item) =>
                    CoachingPlanItem.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
          caloriesBurned: vitals.todayCalories,
          generatedAt: DateTime.now(),
        );
      }
    } catch (_) {
      // Fall through to offline plan
    }

    return _offlinePlan(vitals);
  }

  /// Rule-based fallback when the API is unreachable.
  CoachingPlan _offlinePlan(UserVitals vitals) {
    int systolic = 0;
    if (vitals.bloodPressures.isNotEmpty) {
      systolic = vitals.bloodPressures.first.systolic;
    }

    final focus = systolic > 130
        ? 'Focus on lowering your blood pressure by reducing sodium and doing light cardio.'
        : 'Maintain a balanced lifestyle and stay active.';

    return CoachingPlan(
      userId: userId,
      dailyFocus: focus,
      dietSuggestions: [
        CoachingPlanItem(
          title: 'Hydration',
          description: 'Drink at least 8 glasses of water today.',
          icon: 'water',
        ),
        CoachingPlanItem(
          title: 'Balanced Diet',
          description: 'Include green vegetables with every meal.',
          icon: 'leaf',
        ),
        if (systolic > 130)
          CoachingPlanItem(
            title: 'Low Sodium',
            description: 'Avoid salty snacks to help manage blood pressure.',
            icon: 'warning',
          ),
      ],
      exerciseRoutine: [
        CoachingPlanItem(
          title: 'Daily Walk',
          description: 'Take a 30-minute brisk walk in the evening.',
          icon: 'directions_walk',
        ),
        CoachingPlanItem(
          title: 'Stretching',
          description: 'Do a 10-minute stretch routine before bed.',
          icon: 'accessibility',
        ),
      ],
      caloriesBurned: vitals.todayCalories,
      generatedAt: DateTime.now(),
    );
  }
}
