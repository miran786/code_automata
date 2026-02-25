import 'package:flutter/material.dart';
import 'package:mobile/services/api_service.dart';

// ─────────────────────────────────────────────
// Health categories available for selection
// ─────────────────────────────────────────────
class _HealthCategory {
  final String id;
  final String label;
  final IconData icon;
  const _HealthCategory(this.id, this.label, this.icon);
}

const _kCategories = [
  _HealthCategory('general', 'General Wellness', Icons.favorite),
  _HealthCategory('pregnancy', 'Pregnancy', Icons.child_care),
  _HealthCategory('epilepsy', 'Epilepsy / Seizures', Icons.electric_bolt),
  _HealthCategory('autism', 'Autism Spectrum (ASD)', Icons.psychology),
  _HealthCategory('diabetes1', 'Type 1 Diabetes', Icons.water_drop),
  _HealthCategory('diabetes2', 'Type 2 Diabetes', Icons.monitor_heart),
  _HealthCategory('hypertension', 'Hypertension (High BP)', Icons.speed),
  _HealthCategory('heart', 'Heart Condition', Icons.favorite_border),
  _HealthCategory('asthma', 'Asthma / Respiratory', Icons.air),
  _HealthCategory('anxiety', 'Anxiety / Mental Health', Icons.self_improvement),
  _HealthCategory('disability', 'Physical Disability', Icons.accessible),
  _HealthCategory('surgery', 'Post-Surgery Recovery', Icons.healing),
  _HealthCategory('elderly', 'Elderly / Senior Care', Icons.elderly),
];

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _emergencyCtrl = TextEditingController();
  final _cycleLenCtrl = TextEditingController(text: '28');
  final _periodDurCtrl = TextEditingController(text: '5');

  final _apiService = ApiService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  String _gender = 'Male'; // 'Male' | 'Female' | 'Other'
  final Set<String> _selectedCategories = {'general'};
  DateTime? _lastPeriodDate;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _emergencyCtrl.dispose();
    _cycleLenCtrl.dispose();
    _periodDurCtrl.dispose();
    super.dispose();
  }

  bool get _isFemale => _gender == 'Female';

  Future<void> _pickLastPeriodDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      helpText: 'Select last period start date',
    );
    if (picked != null) setState(() => _lastPeriodDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isFemale && _lastPeriodDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your last period start date.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await _apiService.signUp(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
      _nameCtrl.text.trim(),
    );

    if (success) {
      // Save profile data into ApiService static fields
      ApiService.currentGender = _gender;
      ApiService.healthCategories = _selectedCategories.toList();
      ApiService.emergencyContact = _emergencyCtrl.text.trim();
      if (_isFemale) {
        ApiService.lastPeriodDate = _lastPeriodDate;
        ApiService.menstrualCycleLength =
            int.tryParse(_cycleLenCtrl.text) ?? 28;
        ApiService.menstrualPeriodDuration =
            int.tryParse(_periodDurCtrl.text) ?? 5;
      }

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please log in.')),
        );
        Navigator.pop(context); // back to login
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up failed. Username may already be taken.'),
          ),
        );
      }
    }
  }

  // ─── UI helpers ───────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.teal,
          ),
        ),
      );

  Widget _genderChip(String label, IconData icon) {
    final selected = _gender == label;
    return ChoiceChip(
      avatar: Icon(icon, size: 18, color: selected ? Colors.white : Colors.teal),
      label: Text(label),
      selected: selected,
      selectedColor: Colors.teal,
      labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
      onSelected: (_) => setState(() => _gender = label),
    );
  }

  Widget _categoryTile(_HealthCategory cat) {
    final selected = _selectedCategories.contains(cat.id);
    return CheckboxListTile(
      value: selected,
      onChanged: (val) {
        setState(() {
          if (val == true) {
            _selectedCategories.add(cat.id);
          } else {
            _selectedCategories.remove(cat.id);
          }
        });
      },
      secondary: CircleAvatar(
        radius: 18,
        backgroundColor: selected ? Colors.teal : Colors.grey[200],
        child: Icon(cat.icon, size: 18, color: selected ? Colors.white : Colors.teal),
      ),
      title: Text(cat.label, style: const TextStyle(fontSize: 14)),
      controlAffinity: ListTileControlAffinity.trailing,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section 1: Basic Info ──────────────────────────────────
                _sectionHeader('Basic Information'),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a username' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordCtrl,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (v) => (v == null || v.length < 6)
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: (v) => v != _passwordCtrl.text
                      ? 'Passwords do not match'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emergencyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Emergency Contact Number',
                    hintText: 'e.g. +919876543210',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.emergency, color: Colors.red),
                    helperText:
                        'Receives SMS with your GPS location during a heart rate spike',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null; // optional
                    final digits = v.trim().replaceAll(RegExp(r'[\s\-()]'), '');
                    if (!RegExp(r'^\+?\d{7,15}$').hasMatch(digits)) {
                      return 'Enter a valid phone number (e.g. +919876543210)';
                    }
                    return null;
                  },
                ),

                // ── Section 2: Gender ──────────────────────────────────────
                _sectionHeader('Gender'),
                Wrap(
                  spacing: 10,
                  children: [
                    _genderChip('Male', Icons.male),
                    _genderChip('Female', Icons.female),
                    _genderChip('Other', Icons.transgender),
                  ],
                ),

                // ── Section 3: Health Categories ───────────────────────────
                _sectionHeader('Health Profile  (select all that apply)'),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: _kCategories.map(_categoryTile).toList(),
                  ),
                ),

                // ── Section 4: Menstrual Cycle (Female only) ───────────────
                if (_isFemale) ...[
                  _sectionHeader('Menstrual Cycle Tracking'),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.pinkAccent, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Last period date
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_today,
                                color: Colors.pinkAccent),
                            title: const Text('Last Period Start Date'),
                            subtitle: Text(
                              _lastPeriodDate == null
                                  ? 'Tap to select'
                                  : '${_lastPeriodDate!.day}/${_lastPeriodDate!.month}/${_lastPeriodDate!.year}',
                              style: TextStyle(
                                color: _lastPeriodDate == null
                                    ? Colors.grey
                                    : Colors.pinkAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: _pickLastPeriodDate,
                          ),
                          const Divider(),
                          // Cycle length
                          Row(
                            children: [
                              const Icon(Icons.loop, color: Colors.pinkAccent, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(child: Text('Average Cycle Length')),
                              SizedBox(
                                width: 64,
                                child: TextFormField(
                                  controller: _cycleLenCtrl,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    suffixText: 'days',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Period duration
                          Row(
                            children: [
                              const Icon(Icons.water_drop,
                                  color: Colors.pinkAccent, size: 20),
                              const SizedBox(width: 8),
                              const Expanded(child: Text('Average Period Duration')),
                              SizedBox(
                                width: 64,
                                child: TextFormField(
                                  controller: _periodDurCtrl,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    suffixText: 'days',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // ── Submit ─────────────────────────────────────────────────
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Already have an account? Log in'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
