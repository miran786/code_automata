// Step 2: Create new file lib/features/book_appointment/doctor_detail_screen.dart

import 'package:flutter/material.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  final _reasonController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _bookAppointment() {
    if (_selectedDate == null ||
        _selectedTime == null ||
        _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    // Fake booking
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Appointment booked! (fake)')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final doc = widget.doctor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book with ${doc['name']}',
          style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: isSmallScreen ? 30 : 40,
                          child: Icon(
                            Icons.person,
                            size: isSmallScreen ? 40 : 50,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc['name'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 18 : 20,
                                ),
                              ),
                              Text(
                                doc['specialty'] as String,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Education: ${doc['education']}',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hospital: ${doc['hospital']}',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Address: ${doc['address']}',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contact: ${doc['contact']}',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Distance: ${doc['distance']} km',
                      style: TextStyle(fontSize: isSmallScreen ? 14 : 15),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Rating: '),
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < (doc['rating'] as double).floor()
                                ? Icons.star
                                : Icons.star_border,
                            size: isSmallScreen ? 18 : 20,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Booking Form
            Text(
              'Book Appointment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: isSmallScreen ? 20 : 22,
              ),
            ),
            const SizedBox(height: 16),

            // Date picker
            ListTile(
              title: Text(
                _selectedDate == null
                    ? 'Select Date'
                    : _selectedDate!.toString().substring(0, 10),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),

            // Time picker
            ListTile(
              title: Text(
                _selectedTime == null
                    ? 'Select Time'
                    : _selectedTime!.format(context),
              ),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),

            // Reason
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason for Appointment',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _bookAppointment,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 56),
              ),
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}
