import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import 'manage_members_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedCurrency = 'LKR (Rs)';
  bool _billNotifications = true;
  bool _limitAlerts = true;
  bool _openingManageFamily = false;

  Future<void> _openManageFamily() async {
    if (_openingManageFamily) return;

    setState(() {
      _openingManageFamily = true;
    });

    try {
      final authService = AuthService();
      final firebaseUser = authService.currentUser;

      if (firebaseUser == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in first.'),
          ),
        );
        return;
      }

      final UserModel? userModel =
          await authService.getUserModel(firebaseUser.uid);

      if (!mounted) return;

      if (userModel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User profile not found.'),
          ),
        );
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ManageMembersScreen(
            currentUser: userModel,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open Manage Family. Please try again.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingManageFamily = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Regional & Display',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          // Currency Format
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.currency_exchange,
                color: AppColors.primary,
              ),
              title: const Text('Currency Format'),
              trailing: DropdownButton<String>(
                value: _selectedCurrency,
                underline: const SizedBox(),
                items: ['LKR (Rs)', 'USD (\$)']
                    .map(
                      (currency) => DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCurrency = value;
                    });
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Language and Font Size
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.language,
                    color: AppColors.primary,
                  ),
                  title: const Text('Language'),
                  subtitle: const Text(
                    'Choose your preferred language',
                  ),
                  trailing: DropdownButton<String>(
                    value: appSettings.language,
                    underline: const SizedBox(),
                    items: ['English', 'Sinhala', 'Tamil']
                        .map(
                          (language) => DropdownMenuItem<String>(
                            value: language,
                            child: Text(language),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        appSettings.changeLanguage(value);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(
                    Icons.text_fields,
                    color: AppColors.primary,
                  ),
                  title: const Text('Font Size'),
                  subtitle: const Text('Adjust text size'),
                  trailing: DropdownButton<String>(
                    value: appSettings.textSize,
                    underline: const SizedBox(),
                    items: ['Small', 'Medium', 'Large']
                        .map(
                          (size) => DropdownMenuItem<String>(
                            value: size,
                            child: Text(size),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        appSettings.changeTextSize(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Family Management
          const Text(
            'Family Management',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F0FE),
                child: Icon(
                  Icons.groups_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: const Text(
                'Manage Family',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Manage family members and their roles',
              ),
              trailing: _openingManageFamily
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _openingManageFamily
                  ? null
                  : _openManageFamily,
            ),
          ),

          const SizedBox(height: 24),

          // Notifications & Alerts
          const Text(
            'Notifications & Alerts',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(
                    Icons.notifications_active_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text('Bill Due Reminders'),
                  subtitle: const Text(
                    'Receive alerts before bills expire',
                  ),
                  value: _billNotifications,
                  onChanged: (value) {
                    setState(() {
                      _billNotifications = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                  ),
                  title: const Text('Budget Limit Alerts'),
                  subtitle: const Text(
                    'Notify when spending reaches 85% of limit',
                  ),
                  value: _limitAlerts,
                  onChanged: (value) {
                    setState(() {
                      _limitAlerts = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About Project
          const Text(
            'About Project',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.school_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text('Campus Project Version'),
                  subtitle: Text(
                    'Family Budget Sharing v1.0.0',
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.security,
                    color: AppColors.income,
                  ),
                  title: Text('Data Security'),
                  subtitle: Text(
                    'Powered by Google Firebase Cloud Firestore',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

