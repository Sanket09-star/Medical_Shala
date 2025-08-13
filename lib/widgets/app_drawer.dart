import 'package:flutter/material.dart';
import '../screens/doctor_clinic.dart';
import '../screens/prescription_screen.dart';
import 'package:medical_shala/screens/bed_allocation_screen.dart';
import 'package:medical_shala/screens/payment_revenue_screen.dart';
import 'package:medical_shala/screens/history_screen.dart';
import 'package:medical_shala/screens/campaign_management_screen.dart';
import '../screens/profile_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_profile_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: profileAsync.when(
                  data: (profile) {
                    final avatarUrl = profile?['avatarUrl'] as String?;
                    return CircleAvatar(
                      radius: 40,
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : const NetworkImage('https://img.freepik.com/free-icon/user_318-159711.jpg'),
                    );
                  },
                  loading: () => const CircleAvatar(radius: 40, child: CircularProgressIndicator()),
                  error: (_, __) => const CircleAvatar(radius: 40, child: Icon(Icons.error)),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.menu),
              title: const Text('Categories'),
              onTap: () {},
            ),
            const Divider(),
            _drawerItem(context, Icons.person, 'My Profile'),
            _drawerItem(context, Icons.link, 'Encounter', onTap: () {
              Navigator.pushNamed(context, '/encounter');
            }),
            _drawerItem(context, Icons.local_hospital, 'Doctor & Clinic', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorsAndClinicScreen(),
                ),
              );
            }),
            _drawerItem(context, Icons.receipt_long, 'Prescription', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrescriptionScreen(),
                ),
              );
            }),
            _drawerItem(context, Icons.bed, 'Bed Allotment', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BedAllocationScreen(),
                ),
              );
            }),
            _drawerItem(context, Icons.payment, 'Payment', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentRevenueScreen(),
                ),
              );
            }),
            _drawerItem(context, Icons.history, 'History', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            }),
            _drawerItem(context, Icons.campaign, 'Campaign', onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CampaignManagementScreen(),
                ),
              );
            }),
            _drawerItem(context, Icons.settings, 'Settings'),
            _drawerItem(context, Icons.help_outline, 'Helps & FAQs'),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      onTap: onTap ?? (title == 'My Profile' ? () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      } : null),
    );
  }
}
