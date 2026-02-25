import 'package:flutter/material.dart';
import 'package:mobile/models/coaching_plan.dart';
import 'package:mobile/services/coaching_service.dart';
import 'package:mobile/services/health_service.dart';

class CoachingScreen extends StatefulWidget {
  const CoachingScreen({super.key});

  @override
  State<CoachingScreen> createState() => _CoachingScreenState();
}

class _CoachingScreenState extends State<CoachingScreen> {
  final CoachingService _coachingService = CoachingService();
  final HealthService _healthService = HealthService();
  CoachingPlan? _plan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCoachingPlan();
  }

  Future<void> _loadCoachingPlan() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final vitals = await _healthService.fetchAllVitals(
        startTime: now.subtract(const Duration(days: 1)),
        endTime: now,
      );

      if (vitals != null) {
        final plan = await _coachingService.getCoachingPlan(vitals);
        if (mounted) {
          setState(() {
            _plan = plan;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Coaching'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCoachingPlan,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _plan == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No coaching plan available.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadCoachingPlan,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDailyFocus(size),
                  const SizedBox(height: 20),
                  // ── Calories burned today ──────────────────────────
                  _buildCaloriesCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Dietary Plan', Icons.restaurant),
                  const SizedBox(height: 12),
                  ..._plan!.dietSuggestions.map(
                    (item) => _buildCoachingCard(item),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Exercise Routine', Icons.fitness_center),
                  const SizedBox(height: 12),
                  ..._plan!.exerciseRoutine.map(
                    (item) => _buildCoachingCard(item),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCaloriesCard() {
    final calories = _plan?.caloriesBurned ?? 0.0;
    final goal = 500.0; // daily calorie burn goal
    final progress = (calories / goal).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: Colors.orange.shade700,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Calories Burned Today',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
              const Spacer(),
              Text(
                '${calories.toStringAsFixed(0)} kcal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.orange.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% of daily goal (${goal.toInt()} kcal)',
            style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyFocus(Size size) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade400, Colors.teal.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb, color: Colors.amber, size: 24),
              SizedBox(width: 8),
              Text(
                'DAILY FOCUS',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _plan!.dailyFocus,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCoachingCard(CoachingPlanItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade50,
          child: Icon(_getIconData(item.icon), color: Colors.teal),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(item.description),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'water_drop':
        return Icons.water_drop;
      case 'restaurant':
        return Icons.restaurant;
      case 'apple':
        return Icons.apple;
      case 'directions_walk':
        return Icons.directions_walk;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'timer':
        return Icons.timer;
      case 'favorite':
        return Icons.favorite;
      default:
        return Icons.info;
    }
  }
}
