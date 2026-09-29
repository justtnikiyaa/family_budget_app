import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedCurrency = 'LKR (Rs)';
  bool _billNotifications = true;
  bool _limitAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Preferences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Regional & Display',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.currency_exchange, color: AppColors.primary),
                  title: const Text('Currency Format'),
                  trailing: DropdownButton<String>(
                    value: _selectedCurrency,
                    underline: const SizedBox(),
                    items: ['LKR (Rs)', 'USD (\$)']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCurrency = val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Notifications & Alerts',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                  title: const Text('Bill Due Reminders'),
                  subtitle: const Text('Receive alerts before bills expire'),
                  value: _billNotifications,
                  onChanged: (val) => setState(() => _billNotifications = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  title: const Text('Budget Limit Alerts'),
                  subtitle: const Text('Notify when spending reaches 85% of limit'),
                  value: _limitAlerts,
                  onChanged: (val) => setState(() => _limitAlerts = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'About Project',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.school_outlined, color: AppColors.primary),
                  title: Text('Campus Project Version'),
                  subtitle: Text('Family Budget Sharing v1.0.0'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.security, color: AppColors.income),
                  title: Text('Data Security'),
                  subtitle: Text('Powered by Google Firebase Cloud Firestore'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
