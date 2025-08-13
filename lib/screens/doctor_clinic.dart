import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';

class DoctorsAndClinicScreen extends ConsumerStatefulWidget {
  const DoctorsAndClinicScreen({super.key});

  @override
  ConsumerState<DoctorsAndClinicScreen> createState() => _DoctorsAndClinicScreenState();
}

class _DoctorsAndClinicScreenState extends ConsumerState<DoctorsAndClinicScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        title: const Text(
          'Doctor & Clinic',
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
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFEEEEEE),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              indicatorWeight: 3,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              tabs: const [
                Tab(text: 'Doctor'),
                Tab(text: 'Clinic'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Doctor Tab
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search by doctor's name, speciality",
                                  hintStyle: TextStyle(
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
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.tune,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: const [
                          DoctorCard(
                            imageUrl:
                                'https://randomuser.me/api/portraits/women/65.jpg',
                            name: 'Dr. Priyam',
                            specialty: 'Gynecologist',
                            clinic: "Women's Health Clinic - Pune",
                            experience: '11 years Experience',
                            schedule: 'Tue, Thu, Sat, 2 PM - 5 PM',
                            rating: 4.9,
                          ),
                          DoctorCard(
                            imageUrl:
                                'https://randomuser.me/api/portraits/men/32.jpg',
                            name: 'Dr. Arjun',
                            specialty: 'General Medicine',
                            clinic: 'Sunshine Health Clinic - Chennai',
                            experience: '8 years Experience',
                            schedule: 'Mon-Fri, 10 AM - 6 PM',
                            rating: 4.8,
                          ),
                          DoctorCard(
                            imageUrl:
                                'https://randomuser.me/api/portraits/men/45.jpg',
                            name: 'Dr. Raj',
                            specialty: 'Orthopedics',
                            clinic: 'Heal Well Clinic - Bangalore',
                            experience: '10 years Experience',
                            schedule: 'Mon, Wed, Fri, 2 PM - 5 PM',
                            rating: 4.8,
                          ),
                          DoctorCard(
                            imageUrl:
                                'https://randomuser.me/api/portraits/women/68.jpg',
                            name: 'Dr. Meera',
                            specialty: 'Dermatology',
                            clinic: 'Radiance Skin Clinic - Hyderabad',
                            experience: '8 years Experience',
                            schedule: 'Wed, Sat, Sun, 11 AM - 4 PM',
                            rating: 4.6,
                          ),
                          DoctorCard(
                            imageUrl:
                                'https://randomuser.me/api/portraits/men/51.jpg',
                            name: 'Dr. Yash',
                            specialty: 'Neurology',
                            clinic: 'Brain Health Clinic - Kolkata',
                            experience: '9 years Experience',
                            schedule: 'Mon-Fri, 9 AM - 3 PM',
                            rating: 4.7,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Clinic Tab
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: "Search by hospital's name, location",
                                  hintStyle: TextStyle(
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
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.tune,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: const [
                          ClinicCard(
                            imageUrl:
                                'https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&w=800&q=80',
                            name: 'Sunshine Health Clinic',
                            location: 'Connaught Place, Delhi',
                            schedule: 'Mon-Sat, 9 AM - 7 PM',
                            rating: 4.9,
                            reviews: 256,
                          ),
                          ClinicCard(
                            imageUrl:
                                'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?auto=format&fit=crop&w=800&q=80',
                            name: "Women's Wellness Clinic",
                            location: 'Koregaon Park, Pune',
                            schedule: 'Mon-Sun, 8 AM - 4 PM',
                            rating: 4.7,
                            reviews: 198,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String specialty;
  final String clinic;
  final String experience;
  final String schedule;
  final double rating;

  const DoctorCard({
    required this.imageUrl,
    required this.name,
    required this.specialty,
    required this.clinic,
    required this.experience,
    required this.schedule,
    required this.rating,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '($specialty)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    clinic,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    experience,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                  Text(
                    schedule,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'Ratings: ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF666666),
                        ),
                      ),
                      Text(
                        rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFC107),
                        size: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClinicCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String location;
  final String schedule;
  final double rating;
  final int reviews;

  const ClinicCard({
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.schedule,
    required this.rating,
    required this.reviews,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  schedule,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '($reviews reviews)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                    Text(
                      'More',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
