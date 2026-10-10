import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/family_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import 'invite_member_screen.dart';

class ManageMembersScreen extends StatefulWidget {
  final UserModel currentUser;

  const ManageMembersScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<ManageMembersScreen> createState() =>
      _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  UserModel get currentUser => widget.currentUser;

  final Set<String> _removedMemberIds = {};
  final Map<String, String> _localRoles = {};

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final authService = AuthService();

    /*
     * First use the currentUser passed to this screen.
     *
     * If familyId is missing, try to get the latest UserModel
     * from Firebase using the currently logged-in Firebase user.
     *
     * This does NOT modify Firebase data.
     */
    if (currentUser.familyId == null ||
        currentUser.familyId!.isEmpty) {
      return StreamBuilder<UserModel?>(
        stream: authService.getUserModelStream(currentUser.uid),
        builder: (context, userSnapshot) {
          final latestUser = userSnapshot.data;

          final familyId = latestUser?.familyId;

          if (familyId == null || familyId.isEmpty) {
            return _buildManageMembersScreen(
              context: context,
              members: _demoMembers(),
              inviteCode: null,
              family: null,
            );
          }

          return _buildFamilyMembers(
            context: context,
            familyId: familyId,
            firestoreService: firestoreService,
          );
        },
      );
    }

    return _buildFamilyMembers(
      context: context,
      familyId: currentUser.familyId!,
      firestoreService: firestoreService,
    );
  }

  Widget _buildFamilyMembers({
    required BuildContext context,
    required String familyId,
    required FirestoreService firestoreService,
  }) {
    return StreamBuilder<FamilyModel?>(
      stream: firestoreService.getFamilyStream(familyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8FAFC),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final family = snapshot.data;

        if (family == null) {
          return _buildManageMembersScreen(
            context: context,
            members: _demoMembers(),
            inviteCode: null,
            family: null,
          );
        }

        return StreamBuilder<List<UserModel>>(
          stream: firestoreService.getFamilyMembers(
            family.memberIds,
          ),
          builder: (context, membersSnapshot) {
            final members = membersSnapshot.data ?? [];

            return _buildManageMembersScreen(
              context: context,
              members: members,
              inviteCode: family.inviteCode,
              family: family,
            );
          },
        );
      },
    );
  }

  Widget _buildManageMembersScreen({
    required BuildContext context,
    required List<UserModel> members,
    String? inviteCode,
    FamilyModel? family,
  }) {
    final visibleMembers = members
        .where(
          (member) =>
              !_removedMemberIds.contains(member.uid),
        )
        .toList();

    /*
     * Only the family admin/owner can manage members.
     *
     * If Firebase family data is not available, demo mode
     * allows management so the UI can still be tested.
     */
    final canManageMembers = family != null
        ? currentUser.uid == family.adminId
        : true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Color(0xFF334155),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'MANAGE MEMBERS',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Color(0xFF172033),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: const Icon(
                Icons.info_outline,
                size: 21,
                color: Color(0xFF8FA0B8),
              ),
              onPressed: () {
                _showInfoDialog(context);
              },
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE8EDF3),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  20,
                ),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'CURRENT PLAN MEMBERS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Color(0xFF8DA0BA),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9FFF7),
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFFB5F1D9),
                          ),
                        ),
                        child: Text(
                          '${visibleMembers.length} Active',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: 0.035),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ...List.generate(
                          visibleMembers.length,
                          (index) {
                            final member =
                                visibleMembers[index];

                            final isCurrentUser =
                                member.uid ==
                                    currentUser.uid;

                            final isOwner =
                                family != null &&
                                member.uid ==
                                    family.adminId;

                            final demoOwner =
                                family == null &&
                                    index == 0;

                            return Column(
                              children: [
                                _memberTile(
                                  context: context,
                                  member: member,
                                  isCurrentUser:
                                      isCurrentUser,
                                  isOwner:
                                      isOwner || demoOwner,
                                  inviteCode: inviteCode,
                                  canManageMembers:
                                      canManageMembers,
                                ),
                                if (index !=
                                    visibleMembers.length -
                                        1)
                                  const Divider(
                                    height: 1,
                                    indent: 76,
                                    endIndent: 20,
                                    color:
                                        Color(0xFFE9EEF4),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FFF9),
                      borderRadius:
                          BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFD2F5E7),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFD9F9EE),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            size: 19,
                            color: Color(0xFF059669),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Family Sharing Enabled',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w700,
                                  color:
                                      Color(0xFF334155),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'All invited members have access to shared vaults, subscriptions, and synchronized settings.',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  height: 1.45,
                                  color:
                                      Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /*
             * ADD / INVITE MEMBER button is visible only
             * for the family admin/owner.
             */
            if (canManageMembers)
              Container(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  20,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Color(0xFFE8EDF3),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      if (inviteCode == null ||
                          inviteCode.isEmpty) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Create or join a family first to invite members.',
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              InviteMemberScreen(
                            inviteCode: inviteCode,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF0DB58A),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0xFF0DB58A)
                          .withValues(alpha: 0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'ADD/INVITE MEMBER',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _memberTile({
    required BuildContext context,
    required UserModel member,
    required bool isCurrentUser,
    required bool isOwner,
    required bool canManageMembers,
    String? inviteCode,
  }) {
    String initials = '?';

    if (member.displayName.isNotEmpty) {
      final parts =
          member.displayName.trim().split(' ');

      if (parts.length >= 2) {
        initials =
            '${parts[0][0]}${parts[1][0]}'
                .toUpperCase();
      } else {
        initials =
            member.displayName[0].toUpperCase();
      }
    }

    final displayName =
        isCurrentUser ? 'Me' : member.displayName;

    final subtitle = isCurrentUser
        ? 'Primary Account • Active'
        : 'Family Member • Full Access';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF172033),
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10C58A),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF172033),
                        ),
                      ),
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDF8EE),
                          borderRadius:
                              BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'OWNER',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 7),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius:
                              BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'Family',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF718096),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showMemberOptions(
                context,
                member,
                isCurrentUser,
                canManageMembers,
              );
            },
            icon: const Icon(
              Icons.more_horiz,
              size: 20,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  List<UserModel> _demoMembers() {
    return [
      UserModel(
        uid: currentUser.uid,
        displayName: 'Me',
        email: currentUser.email,
        familyId: null,
        role: 'admin',
      ),
      UserModel(
        uid: 'demo-sister',
        displayName: 'Sister',
        email: 'sister@example.com',
        familyId: null,
        role: 'member',
      ),
    ];
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Family Members'),
          content: const Text(
            'Manage the members of your family plan and invite new members to share your family budget.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showMemberOptions(
    BuildContext context,
    UserModel member,
    bool isCurrentUser,
    bool canManageMembers,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  member.displayName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 15),

                // Everyone can view profile.
                ListTile(
                  leading: const Icon(
                    Icons.person_outline,
                  ),
                  title: const Text('View Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    _showMemberProfile(
                      context,
                      member,
                    );
                  },
                ),

                // Only admin/owner can change role.
                if (canManageMembers &&
                    !isCurrentUser)
                  ListTile(
                    leading: const Icon(
                      Icons.manage_accounts_outlined,
                    ),
                    title: const Text('Change Role'),
                    onTap: () {
                      Navigator.pop(context);
                      _showChangeRoleDialog(
                        context,
                        member,
                      );
                    },
                  ),

                // Only admin/owner can remove members.
                if (canManageMembers &&
                    !isCurrentUser)
                  ListTile(
                    leading: const Icon(
                      Icons.person_remove_outlined,
                      color: Colors.redAccent,
                    ),
                    title: const Text(
                      'Remove Member',
                      style: TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showRemoveMemberDialog(
                        context,
                        member,
                      );
                    },
                  ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMemberProfile(
    BuildContext context,
    UserModel member,
  ) {
    final displayedRole =
        _localRoles[member.uid] ?? member.role;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Member Profile',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF172033),
                ),
                child: Center(
                  child: Text(
                    _getInitials(member.displayName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                member.displayName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _profileDetail(
                Icons.email_outlined,
                'Email',
                member.email,
              ),
              const SizedBox(height: 10),
              _profileDetail(
                Icons.badge_outlined,
                'Role',
                displayedRole == 'admin'
                    ? 'Admin'
                    : 'Member',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _profileDetail(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty
                    ? 'Not available'
                    : value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) {
      return '?';
    }

    final parts = name.trim().split(' ');

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'
          .toUpperCase();
    }

    return parts[0][0].toUpperCase();
  }

  void _showChangeRoleDialog(
    BuildContext context,
    UserModel member,
  ) {
    String selectedRole =
        _localRoles[member.uid] ?? member.role;

    if (selectedRole != 'admin' &&
        selectedRole != 'member') {
      selectedRole = 'member';
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Change Role',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: 'member',
                    groupValue: selectedRole,
                    title: const Text('Member'),
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        selectedRole = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    value: 'admin',
                    groupValue: selectedRole,
                    title: const Text('Admin'),
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        selectedRole = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    /*
                     * UI ONLY.
                     *
                     * This does NOT update Firebase.
                     */
                    setState(() {
                      _localRoles[member.uid] =
                          selectedRole;
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRemoveMemberDialog(
    BuildContext context,
    UserModel member,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Remove Member?',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            'Are you sure you want to remove ${member.displayName} from this list?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                /*
                 * UI ONLY.
                 *
                 * This does NOT remove the member
                 * from Firebase.
                 */
                setState(() {
                  _removedMemberIds.add(member.uid);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      '${member.displayName} removed from the UI.',
                    ),
                  ),
                );
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _showInviteOptions(
    BuildContext context,
    String? inviteCode,
  ) {
    if (inviteCode == null ||
        inviteCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Create or join a family first to invite members.',
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Invite a Family Member',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  inviteCode,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: Color(0xFF059669),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text(
                    'Copy Invite Code',
                  ),
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: inviteCode,
                      ),
                    );

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Invite code copied!',
                        ),
                      ),
                    );
                  },
                ),
                const ListTile(
                  leading: Icon(
                    Icons.share_outlined,
                  ),
                  title: Text(
                    'Share Invite Code',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}