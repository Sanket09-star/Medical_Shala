import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String selectedFilter = 'Internal';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> get _patients => [
    {'name': 'Aarav', 'date': '12 March, 2023', 'image': 'https://randomuser.me/api/portraits/men/1.jpg'},
    {'name': 'Ishita', 'date': '30 December, 2023', 'image': 'https://randomuser.me/api/portraits/women/2.jpg'},
    {'name': 'Vihaan', 'date': '14 April, 2022', 'image': 'https://randomuser.me/api/portraits/men/3.jpg'},
    {'name': 'Meera', 'date': '30 March, 2021', 'image': 'https://randomuser.me/api/portraits/women/4.jpg'},
    {'name': 'Aditya', 'date': '22 June, 2020', 'image': 'https://randomuser.me/api/portraits/men/5.jpg'},
    {'name': 'Kavya', 'date': '07 June, 2019', 'image': 'https://randomuser.me/api/portraits/women/6.jpg'},
    {'name': 'Ananya', 'date': '21 August, 2024', 'image': 'https://randomuser.me/api/portraits/women/7.jpg'},
    {'name': 'Rohan', 'date': '24 October, 2021', 'image': 'https://randomuser.me/api/portraits/men/8.jpg'},
  ];

  List<Map<String, String>> get _filteredPatients {
    List<Map<String, String>> list = List.from(_patients);
    if (selectedFilter == 'External') {
      list.shuffle();
    }
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((p) => p['name']!.toLowerCase().contains(query)).toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        title: Text(
          'History',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
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
                    radius: 16,
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : const NetworkImage('https://img.freepik.com/free-icon/user_318-159711.jpg'),
                  );
                },
                loading: () => const CircleAvatar(radius: 16, child: CircularProgressIndicator()),
                error: (_, __) => const CircleAvatar(radius: 16, child: Icon(Icons.error)),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterButton('Internal'),
                const SizedBox(width: 12),
                _buildFilterButton('External'),
                const SizedBox(width: 12),
                _buildFilterButton('Patient'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Patient List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = _filteredPatients[index];
                return _buildPatientListItem(
                  name: patient['name']!,
                  date: patient['date']!,
                  imageUrl: patient['image']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    final isSelected = selectedFilter == text;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = text;
          });
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF007BFF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF007BFF) : Colors.grey[300]!,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientListItem({
    required String name,
    required String date,
    required String imageUrl,
  }) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Registered: $date',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 30,)
              ],
            ),
          ),
        ],
      ),
    );
  }
} 