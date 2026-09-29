import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import 'edit_profile_screen.dart';
import 'manage_members_screen.dart';
import 'settings_screen.dart';
import '../auth/join_family_screen.dart';
import '../dashboard/create_family_screen.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel? currentUser;

  const ProfileScreen({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final effectiveUser = currentUser ?? UserModel(
      uid: authService.currentUser?.uid ?? '',
      email: authService.currentUser?.email ?? '',
      displayName: authService.currentUser?.displayName ?? 'Family Member',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Family'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    effectiveUser.displayName.isNotEmpty
                        ? effectiveUser.displayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  effectiveUser.displayName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  effectiveUser.email,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Account Details Section
          const Text(
            'Account Details',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('Edit Profile'),
              subtitle: const Text('Change display name and details'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(currentUser: effectiveUser),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Family Collaboration
          const Text(
            'Family Collaboration',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.group_outlined, color: AppColors.primary),
                  title: const Text('Manage Family Members'),
                  subtitle: const Text('View members, role & share invite code'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ManageMembersScreen(currentUser: effectiveUser),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.group_add_outlined, color: AppColors.accent),
                  title: const Text('Join Another Family'),
                  subtitle: const Text('Enter invitation code'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JoinFamilyScreen(currentUser: effectiveUser),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.home_outlined, color: AppColors.income),
                  title: const Text('Create New Family'),
                  subtitle: const Text('Start a separate budget wallet'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CreateFamilyScreen(currentUser: effectiveUser),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Settings Section
          const Text(
            'App & System',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
              title: const Text('Settings'),
              subtitle: const Text('Currency, notifications & info'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // Sign out
          CustomButton(
            text: 'Sign Out',
            backgroundColor: Colors.red.shade50,
            textColor: Colors.red,
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out'),
                  content: const Text('Are you sure you want to sign out from your account?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await authService.signOut();
              }
            },
          ),
        ],
      ),
    );
  }
}
