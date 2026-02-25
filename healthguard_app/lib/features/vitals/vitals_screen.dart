import 'package:flutter/material.dart';
import '../../services/health_service.dart';
import '../../models/user_vitals.dart';

class VitalsScreen extends StatefulWidget {
  const VitalsScreen({super.key});

  @override
  State<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends State<VitalsScreen> {
  final HealthService _healthService = HealthService();
  UserVitals? _vitals;
  bool _isLoading = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _fetchVitals();
  }

  Future<void> _fetchVitals() async {
    setState(() {
      _isLoading = true;
      _status = '';
    });

    final now = DateTime.now();
    final vitals = await _healthService.fetchAllVitals(
      startTime: now.subtract(const Duration(days: 1)),
      endTime: now,
    );

    setState(() {
      _vitals = vitals;
      _isLoading = false;
      if (vitals == null) {
        _status = 'Please authorize Health Connect and fetch data.';
      }
    });
  }

  Future<void> _writeMockData() async {
    setState(() {
      _isLoading = true;
      _status = 'Writing mock data...';
    });

    final success = await _healthService.writeMockData();

    setState(() {
      _isLoading = false;
      _status = success
          ? 'Mock data injected successfully!'
          : 'Failed to inject mock data.';
    });
    if (success) _fetchVitals();
  }

  Widget _buildVitalTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(26), // ~0.1 opacity
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchVitals,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Daily Stats',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_vitals != null) ...[
                    _buildVitalTile(
                      'Steps',
                      '${_vitals!.todaySteps}',
                      Icons.directions_walk,
                      Colors.teal,
                    ),
                    _buildVitalTile(
                      'Calories',
                      '${_vitals!.todayCalories.toStringAsFixed(1)} kcal',
                      Icons.local_fire_department,
                      Colors.orange,
                    ),
                    _buildVitalTile(
                      'Active Minutes',
                      '${_vitals!.todayActiveMinutes} min',
                      Icons.timer,
                      Colors.green,
                    ),
                    const Divider(height: 32),
                    Text(
                      'Latest Readings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildVitalTile(
                      'Heart Rate',
                      _vitals!.latestHeartRate,
                      Icons.favorite,
                      Colors.red,
                    ),
                    _buildVitalTile(
                      'Blood Pressure',
                      _vitals!.latestBloodPressure,
                      Icons.speed,
                      Colors.blue,
                    ),
                    _buildVitalTile(
                      'Glucose',
                      _vitals!.latestGlucose,
                      Icons.bloodtype,
                      Colors.purple,
                    ),
                    _buildVitalTile(
                      'Sleep',
                      _vitals!.latestSleep,
                      Icons.nights_stay,
                      Colors.indigo,
                    ),
                    _buildVitalTile(
                      'SpO2',
                      _vitals!.latestSpo2,
                      Icons.air,
                      Colors.cyan,
                    ),
                    _buildVitalTile(
                      'Stress',
                      _vitals!.latestStress,
                      Icons.psychology,
                      Colors.amber,
                    ),
                  ] else ...[
                    const Center(
                      child: Text(
                        'No data found. Sync your watch or insert mock data.',
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _fetchVitals,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Data'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _writeMockData,
                    icon: const Icon(Icons.add),
                    label: const Text('Insert Mock Data (Testing)'),
                  ),
                  if (_status.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _status.contains('fail')
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
