import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DoctorPatientVitalsScreen extends StatelessWidget {
  const DoctorPatientVitalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    String? patientId;
    if (routeArg != null) {
      if (routeArg is int) {
        patientId = routeArg.toString();
      } else if (routeArg is String) {
        patientId = routeArg;
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Vitals'),
        actions: [
          if (patientId != null) VitalsReloadButton(patientId: patientId),
        ],
      ),
      body: patientId == null
          ? const Center(child: Text('No patient selected'))
          : VitalsFutureBody(patientId: patientId),
    );
  }
}

// Move helper classes to top-level
class VitalsFutureBody extends StatefulWidget {
  final String patientId;
  const VitalsFutureBody({super.key, required this.patientId});

  @override
  State<VitalsFutureBody> createState() => VitalsFutureBodyState();
}

class VitalsFutureBodyState extends State<VitalsFutureBody> {
  late Future<Map<String, dynamic>?> _vitalsFuture;

  @override
  void initState() {
    super.initState();
    _vitalsFuture = ApiService().getPatientVitals(widget.patientId);
  }

  void reloadVitals() {
    setState(() {
      _vitalsFuture = ApiService().getPatientVitals(widget.patientId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _vitalsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final vitals = snapshot.data;
        if (vitals == null) {
          return const Center(child: Text('Failed to load vitals'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Health Summary Card
              _buildSummaryCard(vitals),
              const SizedBox(height: 24),

              Text(
                'Key Health Indicators',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
              ),
              const SizedBox(height: 16),

              // Vitals Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _vitalBox(
                    'Heart Rate',
                    '${vitals['heart_rate'] ?? '-'}',
                    'BPM',
                    Icons.favorite,
                    Colors.red,
                  ),
                  _vitalBox(
                    'Blood Pressure',
                    '${vitals['bp'] ?? '-'}',
                    'mmHg',
                    Icons.bloodtype,
                    Colors.blue,
                  ),
                  _vitalBox(
                    'Glucose',
                    '${vitals['glucose'] ?? '-'}',
                    'mg/dL',
                    Icons.opacity,
                    Colors.purple,
                  ),
                  _vitalBox(
                    'Today\'s Steps',
                    '${vitals['steps'] ?? '-'}',
                    'steps',
                    Icons.directions_walk,
                    Colors.orange,
                  ),
                  _vitalBox(
                    'Calories',
                    '${vitals['calories'] ?? '-'}',
                    'kcal',
                    Icons.local_fire_department,
                    Colors.deepOrange,
                  ),
                  _vitalBox(
                    'Active Time',
                    '${vitals['active_min'] ?? '-'}',
                    'min',
                    Icons.access_time,
                    Colors.green,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> vitals) {
    // Basic logic for health status
    final int hr = int.tryParse(vitals['heart_rate']?.toString() ?? '0') ?? 0;
    String status = "Normal";
    Color statusColor = Colors.green;
    String message = "All vitals are within normal range.";

    if (hr > 100 || hr < 60 && hr != 0) {
      status = "Attention Required";
      statusColor = Colors.orange;
      message = "Heart rate is outside the optimal range.";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: statusColor),
              const SizedBox(width: 10),
              Text(
                'Health Status: $status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  Widget _vitalBox(String label, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          FittedBox(
            child: Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  static VitalsFutureBodyState? of(BuildContext context) {
    return context.findAncestorStateOfType<VitalsFutureBodyState>();
  }
}

class VitalsReloadButton extends StatelessWidget {
  final String patientId;
  const VitalsReloadButton({super.key, required this.patientId});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.refresh),
      tooltip: 'Reload Vitals',
      onPressed: () {
        final state = VitalsFutureBodyState.of(context);
        state?.reloadVitals();
      },
    );
  }
}
