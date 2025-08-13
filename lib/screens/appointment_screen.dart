import 'package:flutter/material.dart';
import 'schedule_appointment_screen.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_drawer.dart';
import 'profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';
import '../providers/appointment_provider.dart';

class AppointmentScreen extends ConsumerStatefulWidget {
  const AppointmentScreen({super.key});

  @override
  ConsumerState<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends ConsumerState<AppointmentScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Handle navigation based on selected tab
    if (index == 1) {
      Navigator.pushReplacementNamed(context, '/inbox');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/askai');
    }
  }

  Future<void> _addAppointment() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ScheduleAppointmentScreen()),
    );
    // The appointment will be automatically added to the list via the provider
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final appointmentsAsync = ref.watch(appointmentsProvider);

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
          'Appointment',
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient stats card
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F8FC),
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 100,
                                height: 50,
                                child: CustomPaint(
                                  painter: _ThreeColorPiePainter(
                                    values: [0.7, 0.2, 0.1], // Example: 40%, 20%, 40%
                                    colors: [
                                      Color(0xFF7C3AED), // Purple
                                      Color(0xFF22C55E), // Green
                                      Color(0xFFEC4899), // Orange (example third color)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        appointmentsAsync.when(
                          data: (appointments) => Text(
                            '${appointments.length}',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          loading: () => const Text(
                            '...',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          error: (_, __) => const Text(
                            '0',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'ALL PATIENTS',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      width: 1.2,
                      height: 140,
                      color: Colors.black12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final stats = ref.watch(appointmentStatsProvider);
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '${stats['upcoming']}',
                                        style: const TextStyle(
                                          color: Color(0xFF7C3AED),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'UPCOMING',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        '${stats['completed']}',
                                        style: const TextStyle(
                                          color: Color(0xFF22C55E),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'COMPLETED',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        '${stats['missed']}',
                                        style: const TextStyle(
                                          color: Color(0xFFEC4899),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'MISSED',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: _addAppointment,
                      icon: const Icon(
                        Icons.add,
                        size: 20,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Add Appointment',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        side: const BorderSide(color: Color(0xFF1976D2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      icon: const Icon(
                        Icons.video_call,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'Video Consultation',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Date and filter row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Today, 10 Jan 2024',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('All Records', style: TextStyle(fontSize: 14)),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Appointment cards
            Expanded(
              child: appointmentsAsync.when(
                data: (appointments) => appointments.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No appointments yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Schedule your first appointment',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        color: Colors.white,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          itemCount: appointments.length,
                          itemBuilder: (context, index) {
                            final appt = appointments[index];
                            return _appointmentCard(
                              avatar: appt['avatar'],
                              time: appt['time'],
                              status: appt['status'],
                              statusColor: appt['statusColor'],
                              name: appt['name'],
                              id: appt['id'],
                              age: appt['age'],
                              gender: appt['gender'],
                              visited: appt['visited'],
                              statusTimeColor: appt['statusTimeColor'],
                            );
                          },
                        ),
                      ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading appointments',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected,
      ),
    );
  }
}

Widget _appointmentCard({
  required String avatar,
  required String time,
  required String status,
  required Color statusColor,
  required String name,
  required String id,
  required int age,
  required String gender,
  required String visited,
  required Color statusTimeColor,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black26, width: 1),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              avatar,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: 28,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        color: statusTimeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• $status',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Icon(Icons.groups, size: 13, color: Colors.black54),
                      const SizedBox(width: 2),
                      Text(
                        id,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.person, size: 13, color: Colors.black54),
                      const SizedBox(width: 2),
                      Text(
                        '$age, $gender',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.access_time,
                        size: 13,
                        color: Colors.black54,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        'Visited $visited',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.more_vert, color: Colors.black54),
        ],
      ),
    ),
  );
}

class _ThreeColorPiePainter extends CustomPainter {
  final List<double> values; // Should sum to 1.0
  final List<Color> colors;

  _ThreeColorPiePainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.width / 2) - 3.5; // 7 strokeWidth/2
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    double startAngle = -90 * 3.1415926535 / 180; // Start at top
    for (int i = 0; i < values.length; i++) {
      final sweep = values[i] * 2 * 3.1415926535;
      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
