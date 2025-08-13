import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';

class PrescriptionScreen extends ConsumerStatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  ConsumerState<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends ConsumerState<PrescriptionScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedGender = 'Male';
  String selectedMealTime = 'After Meal';
  String selectedFollowUp = 'None';

  final List<String> doctors = ['Dr. Arjun', 'Dr. Priyam', 'Dr. Raj'];
  final List<String> clinics = ['Sunshine Healthcare Clinic', 'City Hospital'];
  
  String? selectedDoctor = 'Dr. Arjun';
  String? selectedClinic = 'Sunshine Healthcare Clinic';

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Prescription',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
              child: profileAsync.when(
                data: (profile) {
                  final avatarUrl = profile?['avatarUrl'] as String?;
                  return CircleAvatar(
                    radius: 18,
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : const NetworkImage('https://img.freepik.com/free-icon/user_318-159711.jpg'),
                  );
                },
                loading: () => const CircleAvatar(radius: 18, child: CircularProgressIndicator()),
                error: (_, __) => const CircleAvatar(radius: 18, child: Icon(Icons.error)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Doctor Details'),
              const SizedBox(height: 16),
              _buildDropdown(
                'Select Doctor',
                doctors,
                selectedDoctor,
                (value) => setState(() => selectedDoctor = value),
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                'Select Clinic',
                clinics,
                selectedClinic,
                (value) => setState(() => selectedClinic = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimePicker(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Patient Details'),
              const SizedBox(height: 16),
              TextFormField(
                decoration: _inputDecoration('Patient Name'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      decoration: _inputDecoration('Age'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _buildGenderSelector(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                maxLines: 3,
                decoration: _inputDecoration('Symptoms like fever, localized pain, swelling, or discharge')
                    .copyWith(
                      filled: true,
                      fillColor: const Color(0xFFEAF4FF),
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Medication Details'),
                  _buildAddMedicationButton(),
                ],
              ),
              const SizedBox(height: 16),
              _buildMedicationCard(),
              const SizedBox(height: 24),
              _buildSectionTitle('Follow-up Appointment'),
              const SizedBox(height: 16),
              _buildFollowUpOptions(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    List<String> items,
    String? value,
    void Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: _inputDecoration(hint),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() => selectedDate = picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(fontSize: 14),
            ),
            const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')} ${selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}',
            style: const TextStyle(fontSize: 14),
          ),
          const Icon(Icons.access_time, size: 20, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: RadioListTile<String>(
              title: const Text('Male', style: TextStyle(fontSize: 14)),
              value: 'Male',
              groupValue: selectedGender,
              onChanged: (value) => setState(() => selectedGender = value!),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Expanded(
            child: RadioListTile<String>(
              title: const Text('Female', style: TextStyle(fontSize: 14)),
              value: 'Female',
              groupValue: selectedGender,
              onChanged: (value) => setState(() => selectedGender = value!),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMedicationButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(Icons.add, color: Colors.white),
        onPressed: () {},
      ),
    );
  }

  Widget _buildMedicationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            decoration: _inputDecoration('Medicine Name'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: _inputDecoration('10'),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  decoration: _inputDecoration('3'),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue),
                ),
                child: const Text('1 - 0 - 1'),
              ),
              const SizedBox(width: 12),
              _buildMealTimeToggle(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Moxikind CV 625mg is an antibiotic used to treat bacterial infections like respiratory, urinary, or skin infections',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTimeToggle() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildMealTimeOption('After Meal'),
          _buildMealTimeOption('Before Meal'),
        ],
      ),
    );
  }

  Widget _buildMealTimeOption(String title) {
    final isSelected = selectedMealTime == title;
    return GestureDetector(
      onTap: () => setState(() => selectedMealTime = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUpOptions() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildFollowUpOption('None'),
        _buildFollowUpOption('After 3 days'),
        _buildFollowUpOption('After a week'),
        _buildFollowUpOption('After 2 weeks'),
        _buildFollowUpOption('After a month'),
        _buildFollowUpOption('Customize'),
      ],
    );
  }

  Widget _buildFollowUpOption(String title) {
    final isSelected = selectedFollowUp == title;
    return GestureDetector(
      onTap: () => setState(() => selectedFollowUp = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.blue,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'Save',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: Colors.grey[600],
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.blue,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
    );
  }
} 