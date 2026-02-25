import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _categoryLabels = {
    'general': 'General Wellness',
    'pregnancy': 'Pregnancy',
    'epilepsy': 'Epilepsy / Seizures',
    'autism': 'Autism Spectrum (ASD)',
    'diabetes1': 'Type 1 Diabetes',
    'diabetes2': 'Type 2 Diabetes',
    'hypertension': 'Hypertension (High BP)',
    'heart': 'Heart Condition',
    'asthma': 'Asthma / Respiratory',
    'anxiety': 'Anxiety / Mental Health',
    'disability': 'Physical Disability',
    'surgery': 'Post-Surgery Recovery',
    'elderly': 'Elderly / Senior Care',
  };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final gender = ApiService.currentGender ?? 'Not set';
    final emergency = ApiService.emergencyContact;
    final categories = ApiService.healthCategories;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar & name ────────────────────────────────────────────
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 52,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  ApiService.currentPatientName ?? 'Patient',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Patient ID: ${ApiService.currentUserId ?? '-'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),

          // ── Personal info ─────────────────────────────────────────────
          _sectionHeader(context, 'Personal Information'),
          _infoTile(Icons.wc, 'Gender', gender),

          // ── Emergency contact ─────────────────────────────────────────
          _sectionHeader(context, 'Emergency Contact'),
          _infoTile(
            Icons.emergency,
            'Contact Number',
            emergency.isEmpty ? 'Not provided' : emergency,
            valueColor:
                emergency.isEmpty ? Colors.grey : Colors.red.shade700,
            iconColor: Colors.red,
          ),

          // ── Health profile ────────────────────────────────────────────
          _sectionHeader(context, 'Health Profile'),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Text(
                'No categories selected',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: categories.map((id) {
                final label = _categoryLabels[id] ?? id;
                return Chip(
                  label: Text(label, style: const TextStyle(fontSize: 12)),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),

          // ── Menstrual cycle (female only) ─────────────────────────────
          if (ApiService.currentGender == 'Female') ...[
            _sectionHeader(context, 'Menstrual Cycle'),
            _infoTile(
              Icons.calendar_today,
              'Last Period',
              ApiService.lastPeriodDate == null
                  ? 'Not set'
                  : '${ApiService.lastPeriodDate!.day}/'
                      '${ApiService.lastPeriodDate!.month}/'
                      '${ApiService.lastPeriodDate!.year}',
            ),
            _infoTile(
              Icons.loop,
              'Cycle Length',
              '${ApiService.menstrualCycleLength} days',
            ),
            _infoTile(
              Icons.water_drop,
              'Period Duration',
              '${ApiService.menstrualPeriodDuration} days',
            ),
          ],

          const SizedBox(height: 32),

          // ── Logout ────────────────────────────────────────────────────
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () {
              ApiService.currentUserId = null;
              ApiService.currentPatientName = null;
              ApiService.currentGender = null;
              ApiService.healthCategories = [];
              ApiService.emergencyContact = '';
              ApiService.lastPeriodDate = null;
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

  Widget _sectionHeader(BuildContext context, String title) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _infoTile(
    IconData icon,
    String label,
    String value, {
    Color? iconColor,
    Color? valueColor,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? Colors.teal),
            const SizedBox(width: 12),
            Text(
              '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
}
