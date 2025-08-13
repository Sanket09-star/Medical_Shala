import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  const BottomNavBar({super.key, required this.selectedIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBar.background,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 6, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navBarItem(
            icon: Icon(Icons.calendar_month, color: selectedIndex == 0 ? AppColors.navBar.selected : AppColors.navBar.unselected),
            label: 'Home',
            index: 0,
          ),
          _navBarItem(
            icon: Icon(Icons.mail_outline, color: selectedIndex == 1 ? AppColors.navBar.selected : AppColors.navBar.unselected),
            label: 'Inbox',
            index: 1,
          ),
          _navBarItem(
            icon: Image.asset(
              'assets/ask_ai_icon.png',
              width: 24,
              height: 24,
              color: selectedIndex == 2 ? AppColors.navBar.selected : AppColors.navBar.unselected,
            ),
            label: 'Ask AI',
            index: 2,
          ),
        ],
      ),
    );
  }
  Widget _navBarItem({required Widget icon, required String label, required int index}) {
    final bool isActive = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.navBar.selected : AppColors.navBar.unselected,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
} 