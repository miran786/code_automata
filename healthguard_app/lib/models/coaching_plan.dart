class CoachingPlanItem {
  final String title;
  final String description;
  final String icon;

  CoachingPlanItem({
    required this.title,
    required this.description,
    required this.icon,
  });

  factory CoachingPlanItem.fromJson(Map<String, dynamic> json) {
    return CoachingPlanItem(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'info',
    );
  }
}

class CoachingPlan {
  final String userId;
  final String dailyFocus;
  final List<CoachingPlanItem> dietSuggestions;
  final List<CoachingPlanItem> exerciseRoutine;
  final double caloriesBurned;
  final DateTime generatedAt;

  CoachingPlan({
    required this.userId,
    required this.dailyFocus,
    required this.dietSuggestions,
    required this.exerciseRoutine,
    this.caloriesBurned = 0.0,
    required this.generatedAt,
  });

  factory CoachingPlan.fromJson(Map<String, dynamic> json) {
    return CoachingPlan(
      userId: json['user_id'] ?? '',
      dailyFocus: json['daily_focus'] ?? '',
      dietSuggestions: (json['diet_suggestions'] as List? ?? [])
          .map((item) => CoachingPlanItem.fromJson(item))
          .toList(),
      exerciseRoutine: (json['exercise_routine'] as List? ?? [])
          .map((item) => CoachingPlanItem.fromJson(item))
          .toList(),
      generatedAt: DateTime.parse(
        json['generated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
