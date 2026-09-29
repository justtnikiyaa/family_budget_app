import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/family_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';

class ManageMembersScreen extends StatelessWidget {
  final UserModel currentUser;

  const ManageMembersScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    if (currentUser.familyId == null || currentUser.familyId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Family Members')),
        body: const Center(
          child: Text(
            'You have not joined or created a family group yet.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Family Members')),
      body: StreamBuilder<FamilyModel?>(
        stream: firestoreService.getFamilyStream(currentUser.familyId!),
        builder: (context, snapshot) {
          final family = snapshot.data;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (family == null) {
            return const Center(child: Text('Family group not found.'));
          }

          return StreamBuilder<List<UserModel>>(
            stream: firestoreService.getFamilyMembers(family.memberIds),
            builder: (context, membersSnapshot) {
              final members = membersSnapshot.data ?? [];

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Invite code banner
                  Card(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Family Invitation Code',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                family.inviteCode,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(Icons.copy, color: AppColors.primary),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: family.inviteCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Invite code copied to clipboard!')),
                                  );
                                },
                              ),
                            ],
                          ),
                          const Text(
                            'Share this code with other members to join.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Active Members (${members.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),

                  ...members.map((member) {
                    final isAdmin = member.uid == family.adminId;
                    final isCurrent = member.uid == currentUser.uid;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                          child: Text(
                            member.displayName.isNotEmpty
                                ? member.displayName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        title: Text(
                          '${member.displayName}${isCurrent ? ' (You)' : ''}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(member.email),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAdmin
                                ? AppColors.accent.withValues(alpha: 0.2)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAdmin ? 'Admin' : 'Member',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isAdmin ? AppColors.accent : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
