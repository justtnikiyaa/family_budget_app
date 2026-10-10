import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../utils/constants.dart';

class ProfileDetailsScreen extends StatelessWidget {
  final UserModel currentUser;

  const ProfileDetailsScreen({
    super.key,
    required this.currentUser,
  });

  String get roleLabel {
    if (currentUser.role.toLowerCase() == 'admin') {
      return 'Primary Contributor / Admin';
    }
    return 'Family Member / Contributor';
  }

  String get initials {
    final name = currentUser.displayName.trim();

    if (name.isEmpty) return 'U';

    final parts = name.split(RegExp(r'\s+'));

    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }

    return name[0].toUpperCase();
  }

  void showLargePhoto(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(dialogContext),
            child: InteractiveViewer(
              child: CircleAvatar(
                radius: 130,
                backgroundColor:
                    AppColors.primary.withValues(alpha: 0.15),
                backgroundImage:
                    currentUser.photoUrl != null &&
                            currentUser.photoUrl!.isNotEmpty
                        ? NetworkImage(currentUser.photoUrl!)
                        : null,
                child: currentUser.photoUrl == null ||
                        currentUser.photoUrl!.isEmpty
                    ? Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = currentUser.photoUrl != null &&
        currentUser.photoUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 12),

          Center(
            child: GestureDetector(
              onTap: () => showLargePhoto(context),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 58,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.15),
                    backgroundImage:
                        hasPhoto ? NetworkImage(currentUser.photoUrl!) : null,
                    child: !hasPhoto
                        ? Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap photo to view',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentUser.displayName.isNotEmpty
                        ? currentUser.displayName
                        : 'Family Member',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentUser.email,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          _sectionTitle('Personal Information'),
          const SizedBox(height: 12),

          _detailCard(
            icon: Icons.person_outline,
            label: 'Full Name',
            value: currentUser.displayName.isNotEmpty
                ? currentUser.displayName
                : 'Not provided',
          ),

          _detailCard(
            icon: Icons.email_outlined,
            label: 'Email Address',
            value: currentUser.email.isNotEmpty
                ? currentUser.email
                : 'Not provided',
          ),

          _detailCard(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: 'Not available in saved profile',
          ),

          _detailCard(
            icon: Icons.badge_outlined,
            label: 'Role in Household',
            value: roleLabel,
          ),

          const SizedBox(height: 20),

          _sectionTitle('Household Details'),
          const SizedBox(height: 12),

          _detailCard(
            icon: Icons.home_outlined,
            label: 'Household ID',
            value: currentUser.familyId != null &&
                    currentUser.familyId!.isNotEmpty
                ? currentUser.familyId!
                : 'Not linked to a household',
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _detailCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withValues(alpha: 0.25),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.primary,
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

