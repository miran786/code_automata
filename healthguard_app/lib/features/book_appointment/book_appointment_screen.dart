// Step 1: Update lib/features/book_appointment/book_appointment_screen.dart
// (Replace the entire file with this)

import 'package:flutter/material.dart';
import 'doctor_detail_screen.dart'; // we'll create this next

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedSpecialty;

  // Fake doctor data (will come from backend later)
  final List<Map<String, dynamic>> _doctors = [
    {
      'name': 'Dr. Alice Johnson',
      'specialty': 'General Physician',
      'education': 'MBBS',
      'hospital': 'Wellness Clinic, Pimpri',
      'address': '789 Oak St, Pimpri, Maharashtra',
      'contact': '+91-7654321098',
      'distance': 1.2,
      'rating': 4.7,
    },
    {
      'name': 'Dr. John Smith',
      'specialty': 'Cardiologist',
      'education': 'MBBS, MD Cardiology',
      'hospital': 'City Hospital, Pimpri',
      'address': '123 Main St, Pimpri, Maharashtra',
      'contact': '+91-9876543210',
      'distance': 2.5,
      'rating': 4.8,
    },
    {
      'name': 'Dr. Bob Brown',
      'specialty': 'Cardiologist',
      'education': 'MBBS, MD Cardiology',
      'hospital': 'Heart Care, Pune',
      'address': '101 Pine St, Pune, Maharashtra',
      'contact': '+91-6543210987',
      'distance': 3.8,
      'rating': 4.9,
    },
    {
      'name': 'Dr. Carol Davis',
      'specialty': 'Diabetologist',
      'education': 'MBBS, DM Endocrinology',
      'hospital': 'Sugar Control Clinic, Pimpri',
      'address': '202 Maple St, Pimpri, Maharashtra',
      'contact': '+91-5432109876',
      'distance': 4.1,
      'rating': 4.6,
    },
    {
      'name': 'Dr. Jane Doe',
      'specialty': 'Diabetologist',
      'education': 'MBBS, DM Endocrinology',
      'hospital': 'Health Center, Pune',
      'address': '456 Elm St, Pune, Maharashtra',
      'contact': '+91-8765432109',
      'distance': 5.0,
      'rating': 4.5,
    },
  ];

  // Get unique specialties for filter
  List<String> get _specialties {
    return ['All', ..._doctors.map((d) => d['specialty'] as String).toSet()];
  }

  // Filtered and sorted doctors
  List<Map<String, dynamic>> get _filteredDoctors {
    var filtered = _doctors.where((doc) {
      final matchesSearch = doc['name'].toString().toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesSpecialty =
          _selectedSpecialty == null ||
          _selectedSpecialty == 'All' ||
          doc['specialty'] == _selectedSpecialty;
      return matchesSearch && matchesSpecialty;
    }).toList();

    // Sort by distance (ascending)
    filtered.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );
    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      // appBar: AppBar(
      //   //title: Text('Book Appointment', style: TextStyle(fontSize: isSmallScreen ? 18 : 20)),
      // ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search doctors by name...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),

          // Specialty filter
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
            child: DropdownButtonFormField<String>(
              initialValue: _selectedSpecialty,
              hint: const Text('Filter by Specialty'),
              items: _specialties.map((spec) {
                return DropdownMenuItem<String>(
                  value: spec,
                  child: Text(
                    spec,
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedSpecialty = value),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Doctor list
          Expanded(
            child: _filteredDoctors.isEmpty
                ? const Center(child: Text('No doctors found'))
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8 : 12,
                    ),
                    itemCount: _filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doc = _filteredDoctors[index];
                      return DoctorCard(
                        doctor: doc,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DoctorDetailScreen(doctor: doc),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Reusable Doctor Card
class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final VoidCallback onTap;

  const DoctorCard({super.key, required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(Icons.person, size: isSmallScreen ? 24 : 28),
        ),
        title: Text(
          doctor['name'] as String,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              doctor['specialty'] as String,
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text(
              doctor['education'] as String,
              style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
            ),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey),
                Text(
                  '${doctor['distance']} km away',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < (doctor['rating'] as double).floor()
                      ? Icons.star
                      : Icons.star_border,
                  size: 14,
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
