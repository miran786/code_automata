import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../../../widgets/bottom_nav_bar.dart';
import '../../core/constants/app_constants.dart';
import '../vitals/vitals_screen.dart';
import '../book_appointment/book_appointment_screen.dart';
import '../profile/profile_screen.dart';
import '../chat_assistant/chat_screen.dart';
import '../coaching/coaching_screen.dart';
import '../../services/health_service.dart';
import '../../services/spike_alert_service.dart';
import '../../services/api_service.dart';
import '../../models/user_vitals.dart';
import '../../models/vital_reading.dart';
import '../../models/blood_pressure_reading.dart';
import '../../models/risk_result.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final HealthService _healthService = HealthService();
  final ApiService _apiService = ApiService();
  UserVitals? _vitals;
  RiskResult? _riskResult;
  bool _isLoading = false;

  // Emergency contact comes from signup; doctor contact is future work
  String get _emergencyContact => ApiService.emergencyContact;
  final String _doctorContact = ''; // doctor's mobile (future)
  bool _spikeDialogShown = false;

  /// Manual override — toggleable from the app-bar icon.
  bool _specialNeedsOverride = false;

  /// True when signup categories include a special-needs condition,
  /// OR the user has manually enabled the override via the app-bar icon.
  bool get _isSpecialNeeds {
    if (_specialNeedsOverride) return true;
    final cats = ApiService.healthCategories;
    return cats.contains('autism') ||
        cats.contains('epilepsy') ||
        cats.contains('elderly') ||
        cats.contains('disability');
  }

  String get _patientName => ApiService.currentPatientName ?? 'Patient';

  @override
  void initState() {
    super.initState();
    _fetchVitals();
  }

  // ── Vibration ──────────────────────────────────────────────────────────────
  Future<void> _vibrateAlert() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Pattern: wait 0, buzz 800, pause 300, buzz 800, pause 300, buzz 800
        await Vibration.vibrate(pattern: [0, 800, 300, 800, 300, 800]);
      }
    } catch (_) {}
  }

  // ── Shared spike-alert logic (real + mock) ─────────────────────────────────
  void _runSpikeAlert(int hr, {bool isMock = false}) {
    if (_spikeDialogShown) return;
    setState(() => _spikeDialogShown = true);

    _vibrateAlert();

    SpikeAlertService.checkAndAlert(
      heartRate: hr,
      patientId: ApiService.currentUserId ?? '1',
      emergencyContact: _emergencyContact,
      doctorContact: _doctorContact,
      patientName: _patientName,
    );

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.red.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isMock ? '🚨 [TEST] Emergency Alert' : '🚨 Heart Rate Spike Detected',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          isMock
              ? 'Mock heart rate: $hr BPM\n\n'
                    'This is a test. In a real spike, emergency contacts are '
                    'notified with your GPS location.'
              : 'Heart rate: $hr BPM\n\n'
                    'Emergency contacts and doctor have been notified with your GPS location.',
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        actions: [
          TextButton(
            child: const Text(
              'DISMISS',
              style: TextStyle(color: Colors.yellowAccent, fontSize: 18),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // ── Vitals Simulator bottom sheet ──────────────────────────────────────────
  void _showVitalsSimulator() {
    int mockHr = 75;
    int mockSystolic = 120;
    int mockDiastolic = 80;
    double mockGlucose = 95.0;

    // Pre-fill from signup; user can override for this test run
    final contactCtrl = TextEditingController(
      text: ApiService.emergencyContact,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final hrAlert = mockHr > SpikeAlertService.spikeThreshold;
          final bpAlert = mockSystolic > 140;
          final glucAlert = mockGlucose > 140;
          final anyAlert = hrAlert || bpAlert || glucAlert;

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.science, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      const Text(
                        'Emergency Vitals Simulator',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Slide values above threshold to unlock the trigger button.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Divider(height: 20),

                  // ── Emergency contact (editable override) ───────────────
                  TextField(
                    controller: contactCtrl,
                    decoration: InputDecoration(
                      labelText: 'Emergency Contact Number',
                      hintText: 'e.g. +919876543210',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(
                        Icons.emergency,
                        color: Colors.red,
                      ),
                      helperText: ApiService.emergencyContact.isEmpty
                          ? 'No number set at signup — enter one here'
                          : 'From your profile (editable for this test)',
                      helperStyle: TextStyle(
                        color: ApiService.emergencyContact.isEmpty
                            ? Colors.red.shade700
                            : Colors.grey[600],
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),

                  // ── Heart Rate ──────────────────────────────────────────
                  _simulatorSlider(
                    label: 'Heart Rate',
                    value: mockHr.toDouble(),
                    unit: 'BPM',
                    min: 40,
                    max: 200,
                    threshold: SpikeAlertService.spikeThreshold.toDouble(),
                    alert: hrAlert,
                    onChanged: (v) => setSheet(() => mockHr = v.round()),
                  ),

                  // ── Systolic BP ─────────────────────────────────────────
                  _simulatorSlider(
                    label: 'Systolic Blood Pressure',
                    value: mockSystolic.toDouble(),
                    unit: 'mmHg',
                    min: 80,
                    max: 220,
                    threshold: 140,
                    alert: bpAlert,
                    onChanged: (v) => setSheet(() => mockSystolic = v.round()),
                  ),

                  // ── Blood Glucose ───────────────────────────────────────
                  _simulatorSlider(
                    label: 'Blood Glucose',
                    value: mockGlucose,
                    unit: 'mg/dL',
                    min: 70,
                    max: 300,
                    threshold: 140,
                    alert: glucAlert,
                    onChanged: (v) => setSheet(() => mockGlucose = v),
                  ),

                  const SizedBox(height: 8),

                  // ── Apply button ────────────────────────────────────────
                  OutlinedButton.icon(
                    icon: const Icon(Icons.dashboard_customize),
                    label: const Text('Apply Mock Vitals to Dashboard'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                    onPressed: () {
                      final now = DateTime.now();
                      setState(() {
                        _vitals = UserVitals(
                          heartRates: [VitalReading<int>(now, mockHr)],
                          bloodPressures: [
                            BloodPressureReading(
                              timestamp: now,
                              systolic: mockSystolic,
                              diastolic: mockDiastolic,
                            ),
                          ],
                          bloodGlucose: [
                            VitalReading<double>(now, mockGlucose),
                          ],
                          sleepSessionsMinutes: [],
                          steps: [],
                          caloriesBurned: [],
                          activeMinutes: [],
                        );
                      });
                      Navigator.pop(ctx);
                    },
                  ),

                  const SizedBox(height: 8),

                  // ── Trigger alert button ────────────────────────────────
                  ElevatedButton.icon(
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: Text(
                      anyAlert
                          ? '🚨 Trigger Emergency Alert'
                          : 'Raise a value above threshold first',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: anyAlert
                          ? Colors.red.shade700
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: anyAlert
                        ? () {
                            final now = DateTime.now();
                            setState(() {
                              _vitals = UserVitals(
                                heartRates: [VitalReading<int>(now, mockHr)],
                                bloodPressures: [
                                  BloodPressureReading(
                                    timestamp: now,
                                    systolic: mockSystolic,
                                    diastolic: mockDiastolic,
                                  ),
                                ],
                                bloodGlucose: [
                                  VitalReading<double>(now, mockGlucose),
                                ],
                                sleepSessionsMinutes: [],
                                steps: [],
                                caloriesBurned: [],
                                activeMinutes: [],
                              );
                            });
                            // Persist contact entered in simulator
                            final testContact = contactCtrl.text.trim();
                            if (testContact.isNotEmpty) {
                              ApiService.emergencyContact = testContact;
                            }
                            SpikeAlertService.resetSession();
                            setState(() => _spikeDialogShown = false);
                            Navigator.pop(ctx);
                            _runSpikeAlert(mockHr, isMock: true);
                          }
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).then((_) => contactCtrl.dispose());
  }

  Widget _simulatorSlider({
    required String label,
    required double value,
    required String unit,
    required double min,
    required double max,
    required double threshold,
    required bool alert,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: alert ? Colors.red.shade100 : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: alert ? Colors.red.shade300 : Colors.teal.shade200,
                ),
              ),
              child: Text(
                '${value.round()} $unit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: alert ? Colors.red.shade800 : Colors.teal.shade800,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          activeColor: alert ? Colors.red : Colors.teal,
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            alert
                ? '⚠️ Above ${threshold.round()} $unit — will trigger alert'
                : 'Normal  |  Threshold: ${threshold.round()} $unit',
            style: TextStyle(
              fontSize: 11,
              color: alert ? Colors.red.shade700 : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _fetchVitals() async {
    setState(() => _isLoading = true);
    final now = DateTime.now();
    final vitals = await _healthService.fetchAllVitals(
      startTime: now.subtract(const Duration(days: 1)),
      endTime: now,
    );
    if (mounted) {
      setState(() {
        _vitals = vitals;
        _isLoading = false;
      });

      // Fire-and-forget: sync to backend + evaluate risk
      if (vitals != null) {
        _apiService.syncVitals(vitals);
        final risk = await _apiService.syncAndEvaluateRisk(vitals);
        if (mounted) setState(() => _riskResult = risk);

        // Emergency spike detection — delegates to shared _runSpikeAlert
        if (_isSpecialNeeds && mounted) {
          final hr = vitals.heartRates.isNotEmpty
              ? vitals.heartRates.first.value
              : 0;
          if (hr > SpikeAlertService.spikeThreshold) {
            _runSpikeAlert(hr);
          }
        }
      }
    }
  }

  List<String> get _alertMessages {
    if (_riskResult == null) {
      // Fallback static alerts before first fetch
      return [
        'Blood pressure slightly elevated today',
        'Evening medication due in 30 minutes',
      ];
    }
    if (_riskResult!.isGreen) return [];
    if (_riskResult!.isRed) {
      final factors = _riskResult!.keyFactors.isNotEmpty
          ? _riskResult!.keyFactors.join(', ')
          : 'Abnormal vitals detected';
      return [
        '⚠️ HIGH RISK (Score: ${_riskResult!.riskScore.toStringAsFixed(0)}) — $factors',
        if (_riskResult!.recommendedAction.isNotEmpty)
          _riskResult!.recommendedAction,
      ];
    }
    // Yellow
    return [
      '⚡ Moderate risk (Score: ${_riskResult!.riskScore.toStringAsFixed(0)})',
      if (_riskResult!.recommendedAction.isNotEmpty)
        _riskResult!.recommendedAction,
    ];
  }

  Color get _alertCardColor {
    if (_riskResult == null || _riskResult!.isYellow) {
      return Colors.amber.shade50;
    }
    if (_riskResult!.isRed) return Colors.red.shade50;
    return Colors.green.shade50;
  }

  Color get _alertIconColor {
    if (_riskResult == null || _riskResult!.isYellow) {
      return Colors.amber.shade800;
    }
    if (_riskResult!.isRed) return Colors.red.shade800;
    return Colors.green.shade800;
  }

  List<Widget> get _screens => [
    _buildDashboardHome(),
    const VitalsScreen(),
    const CoachingScreen(), // NEW
    const BookAppointmentScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitleForIndex(_currentIndex),
          style: TextStyle(fontSize: size.width < 360 ? 18 : 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Vitals',
            onPressed: _fetchVitals,
          ),
          IconButton(
            icon: Icon(
              Icons.accessibility_new,
              color: _isSpecialNeeds ? Colors.amber : null,
            ),
            tooltip: _isSpecialNeeds
                ? 'Special Needs Mode: ON (tap to toggle)'
                : 'Special Needs Mode: OFF (tap to toggle)',
            onPressed: () {
              // Categories from signup auto-enable this; override allows manual toggle
              final cats = ApiService.healthCategories;
              final autoEnabled =
                  cats.contains('autism') ||
                  cats.contains('epilepsy') ||
                  cats.contains('elderly') ||
                  cats.contains('disability');
              setState(() => _specialNeedsOverride = !_specialNeedsOverride);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isSpecialNeeds
                        ? '🟡 Special Needs Mode: ON — spike alerts enabled'
                              '${autoEnabled ? ' (from profile categories)' : ' (manual)'}'
                        : '⚪ Special Needs Mode: OFF',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications (fake: No new alerts)'),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              tooltip: 'Chatbot',
              child: const Icon(Icons.chat_bubble),
            )
          : null,
    );
  }

  Widget _buildDashboardHome() {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return RefreshIndicator(
      onRefresh: _fetchVitals,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading) const LinearProgressIndicator(),
            Text(
              'Good morning, ${ApiService.currentPatientName ?? 'Patient'}!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 22 : 26,
              ),
            ),
            SizedBox(height: isSmallScreen ? 4 : 6),
            Text(
              'Your health snapshot • ${DateTime.now().toString().substring(0, 10)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
            SizedBox(height: isSmallScreen ? 20 : 24),

            // Alerts: shown only when not green
            if (_alertMessages.isNotEmpty) ...[
              Card(
                color: _alertCardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _riskResult?.isRed == true
                                ? Icons.error_rounded
                                : Icons.warning_amber_rounded,
                            color: _alertIconColor,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _riskResult?.isRed == true
                                ? 'HIGH RISK — Take action'
                                : 'Health alerts',
                            style: TextStyle(
                              color: _alertIconColor,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 16 : 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      ..._alertMessages.map(
                        (alert) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            '• $alert',
                            style: TextStyle(fontSize: isSmallScreen ? 14 : 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: isSmallScreen ? 20 : 24),
            ],

            // ── Emergency Alert Testing card ────────────────────────
            InkWell(
              onTap: _showVitalsSimulator,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.science, color: Colors.red.shade700, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Test Emergency Alert',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.red.shade800,
                            ),
                          ),
                          Text(
                            'Simulate HR / BP / Glucose to trigger SMS + buzz',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.red.shade400),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Vitals grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.05, // responsive tall cards
              children: [
                _VitalCard(
                  title: 'Heart Rate',
                  value: _vitals?.latestHeartRate ?? 'N/A',
                  icon: Icons.favorite,
                  color: Colors.red,
                ),
                _VitalCard(
                  title: 'BP',
                  value: _vitals?.latestBloodPressure ?? 'N/A',
                  icon: Icons.speed,
                  color: Colors.blue,
                ),
                _VitalCard(
                  title: 'Steps',
                  value: _vitals != null ? '${_vitals!.todaySteps}' : 'N/A',
                  icon: Icons.directions_walk,
                  color: Colors.teal,
                ),
                _VitalCard(
                  title: 'Calories',
                  value: _vitals != null
                      ? _vitals!.todayCalories.toStringAsFixed(0)
                      : 'N/A',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                ),
                _VitalCard(
                  title: 'Active Min',
                  value: _vitals != null
                      ? '${_vitals!.todayActiveMinutes}'
                      : 'N/A',
                  icon: Icons.timer,
                  color: Colors.green,
                ),
                _VitalCard(
                  title: 'Glucose',
                  value: _vitals?.latestGlucose ?? 'N/A',
                  icon: Icons.bloodtype,
                  color: Colors.purple,
                ),
                _VitalCard(
                  title: 'SpO2',
                  value: _vitals?.latestSpo2 ?? 'N/A',
                  icon: Icons.air,
                  color: Colors.cyan,
                ),
                _VitalCard(
                  title: 'Stress',
                  value: _vitals?.latestStress ?? 'N/A',
                  icon: Icons.psychology,
                  color: Colors.amber,
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/classroom'),
                  child: const _VitalCard(
                    title: 'Classroom \nSTT',
                    value: 'Live',
                    icon: Icons.hearing,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            SizedBox(height: size.height * 0.04),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.account_circle, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text(
                  ApiService.currentPatientName ?? 'Patient',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width < 360 ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ID: ${ApiService.currentUserId ?? '-'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit Profile'),
            onTap: () {
              // TODO: Edit profile screen
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('View Prescriptions'),
            onTap: () {
              // TODO: Prescriptions screen
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Prescriptions coming soon')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Help coming soon')));
            },
          ),
          const Divider(),
          // ── Demo / Testing ────────────────────────────────────────
          ListTile(
            leading: const Icon(Icons.science, color: Colors.red),
            title: const Text(
              'Emergency Vitals Simulator',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Set mock HR / BP / Glucose → trigger alert'),
            onTap: () {
              Navigator.pop(context);
              _showVitalsSimulator();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.accessibility_new,
              color: _isSpecialNeeds ? Colors.amber : Colors.grey,
            ),
            title: Text(
              _isSpecialNeeds
                  ? 'Special Needs Mode: ON'
                  : 'Special Needs Mode: OFF',
              style: TextStyle(
                color: _isSpecialNeeds ? Colors.amber.shade800 : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              ApiService.healthCategories.any(
                    (c) => [
                      'autism',
                      'epilepsy',
                      'elderly',
                      'disability',
                    ].contains(c),
                  )
                  ? 'Auto-enabled from your health profile'
                  : 'Tap app-bar icon to toggle manually',
            ),
            onTap: () {
              Navigator.pop(context);
              final cats = ApiService.healthCategories;
              final autoEnabled = cats.any(
                (c) =>
                    ['autism', 'epilepsy', 'elderly', 'disability'].contains(c),
              );
              setState(() => _specialNeedsOverride = !_specialNeedsOverride);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isSpecialNeeds
                        ? '🟡 Special Needs Mode: ON'
                              '${autoEnabled ? ' (profile)' : ' (manual)'}'
                        : '⚪ Special Needs Mode: OFF',
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.pop(context); // close drawer
              ApiService.currentUserId = null;
              ApiService.currentPatientName = null;
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppConstants.roleSelectionRoute,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return AppConstants.appName;
      case 1:
        return 'Vitals';
      case 2:
        return 'Health Coaching';
      case 3:
        return 'Book Appointment';
      case 4:
        return 'Profile';
      default:
        return AppConstants.appName;
    }
  }
}

// VitalCard (responsive)
class _VitalCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _VitalCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isSmallScreen ? 32 : 36, color: color),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Text(
              title,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            FittedBox(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
