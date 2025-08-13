import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/app_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  int _selectedIndex = 1;
  String selectedFilter = 'Internal Patient';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> get _patients => [
    {'name': 'Aarav', 'message': "You: Of course, I'll do...", 'avatar': 'https://randomuser.me/api/portraits/men/1.jpg'},
    {'name': 'Ishita', 'message': "I've been experiencing...", 'avatar': 'https://randomuser.me/api/portraits/women/2.jpg'},
    {'name': 'Vihaan', 'message': "Can you please confirm...", 'avatar': 'https://randomuser.me/api/portraits/men/3.jpg'},
    {'name': 'Meera', 'message': "Is it safe to continue the...", 'avatar': 'https://randomuser.me/api/portraits/women/4.jpg'},
    {'name': 'Aditya', 'message': "The prescribed ointment...", 'avatar': 'https://randomuser.me/api/portraits/men/5.jpg'},
    {'name': 'Kavya', 'message': "I've completed the antib...", 'avatar': 'https://randomuser.me/api/portraits/women/6.jpg'},
    {'name': 'Ananya', 'message': "Thank you for the prescri...", 'avatar': 'https://randomuser.me/api/portraits/women/7.jpg'},
  ];

  List<Map<String, String>> get _filteredPatients {
    List<Map<String, String>> list = List.from(_patients);
    if (selectedFilter == 'External Patient') {
      list.shuffle();
    }
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((p) => p['name']!.toLowerCase().contains(query)).toList();
    }
    return list;
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/main');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/askai');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Inbox',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Colors.black54, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Toggle buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = 'Internal Patient';
                      });
                    },
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: selectedFilter == 'Internal Patient' ? const Color(0xFF1976D2) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1976D2)),
                      ),
                      child: Center(
                        child: Text(
                          'Internal Patient',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: selectedFilter == 'Internal Patient' ? Colors.white : const Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedFilter = 'External Patient';
                      });
                    },
                    child: Container(
                      height: 38,
                      decoration: BoxDecoration(
                        color: selectedFilter == 'External Patient' ? const Color(0xFF1976D2) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF1976D2)),
                      ),
                      child: Center(
                        child: Text(
                          'External Patient',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: selectedFilter == 'External Patient' ? Colors.white : const Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Chat list
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: _filteredPatients.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.black12),
              itemBuilder: (context, index) {
                final patient = _filteredPatients[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(patient['avatar']!),
                  ),
                  title: Text(
                    patient['name']!,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                  ),
                  subtitle: Text(
                    patient['message']!,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}