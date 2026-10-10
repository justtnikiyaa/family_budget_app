import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../widgets/quick_add_bottom_sheet.dart';
import 'dashboard/dashboard_screen.dart';
import 'limits_bills/goals_screen.dart';
import 'limits_bills/limits_bills_screen.dart';
import 'limits_bills/reports_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final UserModel currentUser;

  const MainNavigationScreen({super.key, required this.currentUser});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: _authService.getUserModelStream(widget.currentUser.uid),
      builder: (context, snapshot) {
        final activeUser = snapshot.data ?? widget.currentUser;

        final screens = [
          DashboardScreen(currentUser: activeUser),
          LimitsBillsScreen(currentUser: activeUser, initialIndex: 0),
          ReportsScreen(currentUser: activeUser),
          ProfileScreen(currentUser: activeUser),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: _buildCustomBottomNavBar(context, activeUser),
        );
      },
    );
  }

  Widget _buildCustomBottomNavBar(BuildContext context, UserModel activeUser) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 8.0,
        bottom: bottomPadding > 0 ? bottomPadding : 8.0,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Overview
              _buildNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Overview',
                isSelected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),

              // 2. Limits & Bills
              _buildNavItem(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Limits & Bills',
                isSelected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),

              // 3. Center Add Action Button
              _buildCenterAddButton(context, activeUser),

              // 4. Reports
              _buildNavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Reports',
                isSelected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),

              // 5. Preferences
              _buildNavItem(
                icon: Icons.settings_outlined,
                label: 'Preferences',
                isSelected: _currentIndex == 3,
                onTap: () => setState(() => _currentIndex = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const activeColor = Color(0xFF0F766E);
    const inactiveColor = Color(0xFF64748B);
    final color = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFF0F766E).withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton(BuildContext context, UserModel activeUser) {
    return Expanded(
      child: InkWell(
        onTap: () => _showCreateActionSheet(context, activeUser),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Add',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateActionSheet(BuildContext context, UserModel activeUser) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Quick Create',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            _buildActionSheetOption(
              icon: Icons.payments_outlined,
              color: const Color(0xFF0F766E),
              title: 'Add Expense',
              subtitle: 'Log daily spending for family or yourself',
              onTap: () {
                Navigator.pop(ctx);
                QuickAddBottomSheet.show(context, activeUser);
              },
            ),
            _buildActionSheetOption(
              icon: Icons.receipt_long_outlined,
              color: const Color(0xFF0284C7),
              title: 'Add New Bill',
              subtitle: 'Set a reminder for WiFi, utilities or subscriptions',
              onTap: () {
                Navigator.pop(ctx);
                LimitsBillsScreen.showAddBillDialog(context, activeUser);
              },
            ),
            _buildActionSheetOption(
              icon: Icons.speed_outlined,
              color: const Color(0xFFD97706),
              title: 'Set Category Limit',
              subtitle: 'Set monthly budget cap for food, bills, or leisure',
              onTap: () {
                Navigator.pop(ctx);
                LimitsBillsScreen.showAddLimitDialog(context, activeUser);
              },
            ),
            _buildActionSheetOption(
              icon: Icons.savings_outlined,
              color: const Color(0xFF7C3AED),
              title: 'New Savings Goal',
              subtitle: 'Track family savings for trip, education, or emergency',
              onTap: () {
                Navigator.pop(ctx);
                GoalsScreen.showAddGoalDialog(context, activeUser);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSheetOption({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
      onTap: onTap,
    );
  }
}
