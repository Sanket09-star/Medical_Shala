import 'package:flutter/material.dart';
import '../utils/validators.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/appointment_provider.dart';

class ScheduleAppointmentScreen extends StatefulWidget {
  const ScheduleAppointmentScreen({super.key});

  @override
  State<ScheduleAppointmentScreen> createState() => _ScheduleAppointmentScreenState();
}

class _ScheduleAppointmentScreenState extends State<ScheduleAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _gender;
  String? _doctor;
  String? _hospital;
  String? _date;
  String? _slot;
  bool _isSaving = false;

  bool get _isFormValid => _formKey.currentState?.validate() == true && _gender != null && _doctor != null && _hospital != null && _date != null && _slot != null;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _reasonController.dispose();
    _contactController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      final formatted = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {
        _date = formatted;
        _dateController.text = formatted;
      });
    }
  }

  Future<void> _saveAppointment() async {
    if (!_isFormValid) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get doctor's information from Firestore
      final doctorDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final doctorData = doctorDoc.data();
      
      final appointmentData = {
        'patientName': _nameController.text.trim(),
        'patientAge': int.tryParse(_ageController.text.trim()) ?? 0,
        'patientGender': _gender!,
        'reason': _reasonController.text.trim(),
        'doctorName': doctorData?['fullName'] ?? 'Dr. Unknown',
        'hospitalName': _hospital!,
        'appointmentDate': _date!,
        'appointmentTime': _slot!,
        'contactNumber': _contactController.text.trim(),
      };

      // Save to Firebase
      await AppointmentService.createAppointment(appointmentData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment scheduled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error scheduling appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar with back button and title
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12, right: 0, bottom: 0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 1),
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const Icon(Icons.arrow_back, size: 22, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Schedule  Appointment',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Patient Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient Details',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF6FF),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: "Patient's Name",
                            hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: Validators.validateName,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF6FF),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: TextFormField(
                                controller: _ageController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: 'Age',
                                  hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Age is required';
                                  final n = int.tryParse(v);
                                  if (n == null || n < 0 || n > 120) return 'Enter a valid age';
                                  return null;
                                },
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              Radio<String?>(
                                value: 'Male',
                                groupValue: _gender,
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value;
                                  });
                                },
                              ),
                              const Text('Male', style: TextStyle(fontSize: 15)),
                              const SizedBox(width: 8),
                              Radio<String?>(
                                value: 'Female',
                                groupValue: _gender,
                                onChanged: (value) {
                                  setState(() {
                                    _gender = value;
                                  });
                                },
                              ),
                              const Text('Female', style: TextStyle(fontSize: 15)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF6FF),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: TextFormField(
                          controller: _reasonController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Reason for appointment',
                            hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: (v) => Validators.validateRequired(v, 'Reason'),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Doctor Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Doctor Details',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF6FF),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _doctor,
                                  hint: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 14),
                                    child: Text("Doctor's Name", style: TextStyle(fontSize: 15, color: Colors.black54)),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'Dr. John Doe', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('Dr. John Doe'))),
                                    DropdownMenuItem(value: 'Dr. Jane Smith', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('Dr. Jane Smith'))),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _doctor = value;
                                    });
                                  },
                                  validator: (v) => v == null ? "Doctor's Name is required" : null,
                                  icon: const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(Icons.keyboard_arrow_down, size: 22),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF6FF),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _hospital,
                                  hint: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 14),
                                    child: Text("Hospital's Name", style: TextStyle(fontSize: 15, color: Colors.black54)),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: 'City Hospital', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('City Hospital'))),
                                    DropdownMenuItem(value: 'Metro Clinic', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('Metro Clinic'))),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _hospital = value;
                                    });
                                  },
                                  validator: (v) => v == null ? "Hospital's Name is required" : null,
                                  icon: const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(Icons.keyboard_arrow_down, size: 22),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF6FF),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: TextFormField(
                                controller: _dateController,
                                readOnly: true,
                                onTap: _pickDate,
                                decoration: const InputDecoration(
                                  hintText: 'dd/mm/yyyy',
                                  hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  suffixIcon: Icon(Icons.calendar_today, size: 20),
                                ),
                                validator: (v) => v == null || v.isEmpty ? 'Date is required' : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF6FF),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  value: _slot,
                                  hint: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 14),
                                    child: Text('Select Slot', style: TextStyle(fontSize: 15, color: Colors.black54)),
                                  ),
                                  items: const [
                                    DropdownMenuItem(value: '10:00 AM', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('10:00 AM'))),
                                    DropdownMenuItem(value: '10:30 AM', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('10:30 AM'))),
                                    DropdownMenuItem(value: '11:00 AM', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('11:00 AM'))),
                                    DropdownMenuItem(value: '11:30 AM', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('11:30 AM'))),
                                    DropdownMenuItem(value: '12:00 PM', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('12:00 PM'))),
                                    DropdownMenuItem(value: '02:00 PM', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('02:00 PM'))),
                                    DropdownMenuItem(value: '02:30 PM', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('02:30 PM'))),
                                    DropdownMenuItem(value: '03:00 PM', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('03:00 PM'))),
                                    DropdownMenuItem(value: '03:30 PM', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('03:30 PM'))),
                                    DropdownMenuItem(value: '04:00 PM', child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: Text('04:00 PM'))),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _slot = value;
                                    });
                                  },
                                  validator: (v) => v == null ? 'Slot is required' : null,
                                  icon: const Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Icon(Icons.keyboard_arrow_down, size: 22),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Contact Number
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Number',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Enter the number on which you wish to receive appointments related information',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF6FF),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: TextFormField(
                          controller: _contactController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: '+91  00000 00000',
                            hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                          validator: Validators.validatePhone,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Need Assistance box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Need Assistance?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              SizedBox(height: 4),
                              Text(
                                'Our support team is here to help you with appointment scheduling reach out anytime for quick and reliable assistance!',
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: const [
                            Icon(Icons.phone_outlined, size: 22, color: Colors.black54),
                            SizedBox(height: 8),
                            Icon(Icons.chat_bubble_outline, size: 22, color: Colors.black54),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Schedule Appointment button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isFormValid && !_isSaving ? _saveAppointment : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid && !_isSaving ? const Color(0xFF1976D2) : const Color(0xFFEAEAEA),
                        foregroundColor: _isFormValid && !_isSaving ? Colors.white : Colors.black38,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Schedule Appointment',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: _isFormValid && !_isSaving ? Colors.white : Colors.black38,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Bottom navigation bar space
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 