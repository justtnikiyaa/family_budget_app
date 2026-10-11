import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/bill_model.dart';
import '../../models/expense_model.dart';
import '../../models/family_model.dart';
import '../../models/goal_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../limits_bills/add_bill_screen.dart';
import '../limits_bills/bills_screen.dart';
import '../limits_bills/goals_screen.dart';
import '../limits_bills/limits_bills_screen.dart';
import '../profile/profile_screen.dart';
import 'add_income_screen.dart';
import 'create_family_screen.dart';
import '../../widgets/quick_add_bottom_sheet.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel? currentUser;

  const DashboardScreen({super.key, this.currentUser});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedTabIndex = 0;

  UserModel get _effectiveUser =>
      widget.currentUser ??
      UserModel(
        uid: _authService.currentUser?.uid ?? '',
        email: _authService.currentUser?.email ?? '',
        displayName: _authService.currentUser?.displayName ?? 'User',
      );

  Widget _buildQuickNavButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2.5),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentTab(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0F766E) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF475569),
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, String percent, Color color, {String? amount}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                amount != null ? '$percent ($amount)' : percent,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard({
    required String name,
    required String amount,
    required double progress,
    required Color progressColor,
    required String budgetUsedText,
    required String limitText,
    required String avatarUrl,
    required IconData fallbackIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar with clean initial letter fallback
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: (avatarUrl.isNotEmpty && avatarUrl.startsWith('http'))
                  ? Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F766E),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Details & Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Amount Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      amount,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Horizontal Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: const Color(0xFFEEF2F6),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      budgetUsedText,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      limitText,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyBreakdownSection({
    required List<ExpenseModel> expenses,
    required NumberFormat currencyFormat,
    required double totalExpenses,
  }) {
    final familyId = _effectiveUser.familyId;

    if (familyId != null && familyId.isNotEmpty) {
      return StreamBuilder<FamilyModel?>(
        stream: _firestoreService.getFamilyStream(familyId),
        builder: (context, familySnap) {
          final family = familySnap.data;
          final memberIds = family?.memberIds ?? [_effectiveUser.uid];

          return StreamBuilder<List<UserModel>>(
            stream: _firestoreService.getFamilyMembers(memberIds),
            builder: (context, membersSnap) {
              final members = (membersSnap.data != null && membersSnap.data!.isNotEmpty)
                  ? membersSnap.data!
                  : [_effectiveUser];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...members.map((member) {
                    final isMe = member.uid == _effectiveUser.uid;
                    final memberName = member.displayName.isNotEmpty
                        ? (isMe ? '${member.displayName} (You)' : member.displayName)
                        : (isMe ? 'You' : 'Family Member');

                    final memberSpent = expenses
                        .where((exp) =>
                            exp.type == ExpenseType.expense &&
                            (exp.userId == member.uid ||
                                (exp.userName != null &&
                                    exp.userName!.isNotEmpty &&
                                    exp.userName == member.displayName)))
                        .fold<double>(0.0, (sum, exp) => sum + exp.amount);

                    final progress = totalExpenses > 0
                        ? (memberSpent / totalExpenses).clamp(0.0, 1.0)
                        : 0.0;
                    final pctText = totalExpenses > 0
                        ? 'Share: ${(progress * 100).round()}%'
                        : 'No expenses';

                    final roleBadge = member.role.isNotEmpty
                        ? (member.role.toLowerCase() == 'admin'
                            ? 'Household Admin'
                            : 'Member')
                        : 'Member';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: _buildMemberCard(
                        name: memberName,
                        amount: currencyFormat.format(memberSpent),
                        progress: progress,
                        progressColor: isMe
                            ? const Color(0xFF0F766E)
                            : const Color(0xFF0284C7),
                        budgetUsedText: pctText,
                        limitText: roleBadge,
                        avatarUrl: member.photoUrl ?? '',
                        fallbackIcon: Icons.person_rounded,
                      ),
                    );
                  }),
                  if (family != null) ...[
                    const SizedBox(height: 4),
                    _buildInviteCodeBox(family.inviteCode),
                  ],
                ],
              );
            },
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMemberCard(
          name: '${_effectiveUser.displayName} (You)',
          amount: currencyFormat.format(totalExpenses),
          progress: totalExpenses > 0 ? 1.0 : 0.0,
          progressColor: const Color(0xFF0F766E),
          budgetUsedText: totalExpenses > 0 ? 'Total spending' : 'No expenses',
          limitText: 'Personal Account',
          avatarUrl: _effectiveUser.photoUrl ?? '',
          fallbackIcon: Icons.person_rounded,
        ),
        const SizedBox(height: 12),
        _buildConnectFamilyBanner(),
      ],
    );
  }

  Widget _buildInviteCodeBox(String? inviteCode) {
    if (inviteCode == null || inviteCode.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF99F6E4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.group_add_rounded, color: Color(0xFF0F766E), size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Household Invite Code',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0F766E),
                    ),
                  ),
                  Text(
                    inviteCode,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: inviteCode));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Invite code $inviteCode copied to clipboard!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF0F766E),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF0F766E)),
            label: Text(
              'Copy',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F766E),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectFamilyBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateFamilyScreen(currentUser: _effectiveUser),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.group_add_rounded, color: Color(0xFF0F766E), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect Family Members',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Create a household or enter an invite code to share your budget.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  void _showNotificationsSheet(double totalExpenses, double totalIncome, int daysLeft, NumberFormat currencyFormat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFCCFBF1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.savings_outlined, color: Color(0xFF0F766E), size: 22),
              ),
              title: Text(
                totalExpenses > 0
                    ? 'Total spent: ${currencyFormat.format(totalExpenses)}'
                    : 'Monthly budget pool is healthy',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Text(
                '$daysLeft days remaining in current month cycle',
                style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 2);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: StreamBuilder<List<ExpenseModel>>(
          stream: _firestoreService.getExpenses(
            familyId: _effectiveUser.familyId,
            userId: (_effectiveUser.familyId == null || _effectiveUser.familyId!.isEmpty)
                ? _effectiveUser.uid
                : null,
          ),
          builder: (context, snapshot) {
            final expenses = snapshot.data ?? [];

            // Aggregate totals from real Firestore data
            double totalExpenses = 0;
            double totalIncome = 0;
            final Map<String, double> categoryTotals = {};
            final Map<String, double> memberTotals = {};

            for (final exp in expenses) {
              if (exp.type == ExpenseType.expense) {
                totalExpenses += exp.amount;
                categoryTotals[exp.category] = (categoryTotals[exp.category] ?? 0) + exp.amount;
                final member = (exp.userName != null && exp.userName!.isNotEmpty)
                    ? exp.userName!
                    : _effectiveUser.displayName;
                memberTotals[member] = (memberTotals[member] ?? 0) + exp.amount;
              } else {
                totalIncome += exp.amount;
              }
            }

            final double availableBalance = (totalIncome > 0 || totalExpenses > 0)
                ? (totalIncome - totalExpenses)
                : 0.0;
            final String availableBalanceString = currencyFormat.format(availableBalance);

            // Dynamic Category Distribution
            final categoryColors = [
              const Color(0xFF0F766E), // Deep Teal
              const Color(0xFF334155), // Dark Slate
              const Color(0xFF10B981), // Emerald
              const Color(0xFF2DD4BF), // Cyan / Mint
              const Color(0xFFF59E0B), // Amber
              const Color(0xFF8B5CF6), // Purple
            ];

            List<DonutSegment> segments = [];
            List<MapEntry<String, double>> topCategories = [];

            if (expenses.isNotEmpty && totalExpenses > 0) {
              final sortedEntries = categoryTotals.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              if (sortedEntries.length <= 4) {
                topCategories = sortedEntries;
              } else {
                topCategories = sortedEntries.take(3).toList();
                final otherTotal = sortedEntries.skip(3).fold<double>(0.0, (sum, e) => sum + e.value);
                if (otherTotal > 0) {
                  topCategories.add(MapEntry('Other', otherTotal));
                }
              }

              for (int i = 0; i < topCategories.length; i++) {
                final entry = topCategories[i];
                final color = categoryColors[i % categoryColors.length];
                segments.add(DonutSegment(value: entry.value, color: color));
              }
            } else {
              segments = const [
                DonutSegment(value: 1, color: Color(0xFFE2E8F0)),
              ];
            }

            final now = DateTime.now();
            final currentMonthString = DateFormat('MMM yyyy').format(now);
            final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
            final daysLeft = (lastDayOfMonth.day - now.day).clamp(0, 31);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Circular Notification Bell Icon
                      GestureDetector(
                        onTap: () => _showNotificationsSheet(totalExpenses, totalIncome, daysLeft, currencyFormat),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0F2FE),
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Icons.notifications_outlined,
                                size: 22,
                                color: Color(0xFF0F172A),
                              ),
                              Positioned(
                                top: 10,
                                right: 12,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0D9488),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Center: Title "Overview"
                      Text(
                        'Overview',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),

                      // Right: Settings Icon & Green Profile Avatar
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileScreen(currentUser: _effectiveUser),
                                ),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.settings_outlined,
                                size: 20,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProfileScreen(currentUser: _effectiveUser),
                                ),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFF065F46),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Available Balance Card (Dark Slate)
                  GestureDetector(
                    onTap: () => QuickAddBottomSheet.show(context, _effectiveUser),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF16202E),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card Top Section
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left: Available & Amount
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AVAILABLE',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF94A3B8),
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      availableBalanceString,
                                      style: GoogleFonts.inter(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.8,
                                      ),
                                    ),
                                  ],
                                ),

                                // Right: Month & Days left
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      currentMonthString,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$daysLeft days left',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Card Bottom Row
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.5),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.lock_outline_rounded,
                                      size: 14,
                                      color: Color(0xFF2DD4BF),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      (_effectiveUser.familyId != null && _effectiveUser.familyId!.isNotEmpty)
                                          ? 'Family Shared Vault'
                                          : 'Personal Budget Vault',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2DD4BF),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Cycle: 1st - ${lastDayOfMonth.day}th',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF94A3B8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Quick Navigation Shortcuts (Limits, Bills, Goals, Reports)
                  Row(
                    children: [
                      _buildQuickNavButton(
                        icon: Icons.speed_rounded,
                        label: 'Limits',
                        color: const Color(0xFF0F766E),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LimitsBillsScreen(
                                currentUser: _effectiveUser,
                                initialIndex: 0,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildQuickNavButton(
                        icon: Icons.receipt_long_rounded,
                        label: 'Bills',
                        color: const Color(0xFF0284C7),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BillsScreen(
                                currentUser: _effectiveUser,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildQuickNavButton(
                        icon: Icons.savings_rounded,
                        label: 'Goals',
                        color: const Color(0xFFD97706),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GoalsScreen(
                                currentUser: _effectiveUser,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildQuickNavButton(
                        icon: Icons.bar_chart_rounded,
                        label: 'Reports',
                        color: const Color(0xFF7C3AED),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LimitsBillsScreen(
                                currentUser: _effectiveUser,
                                initialIndex: 3,
                              ),
                            ),
                          );
                        },
                      ),
                      _buildQuickNavButton(
                        icon: Icons.add_circle_outline_rounded,
                        label: 'Income',
                        color: const Color(0xFF10B981),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddIncomeScreen(
                                currentUser: _effectiveUser,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Segmented Navigation Pills (3 Tabs)
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildSegmentTab(0, 'OVERVIEW'),
                        _buildSegmentTab(1, 'CATEGORY'),
                        _buildSegmentTab(2, 'MEMBER'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Donut Chart & Spending Distribution Card (shown in Overview and Category)
                  if (_selectedTabIndex == 0 || _selectedTabIndex == 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x06000000),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SpendingDonutChart(
                            segments: segments,
                            centerAmount: totalExpenses > 0 ? currencyFormat.format(totalExpenses) : 'Rs. 0.00',
                            centerLabel: totalExpenses > 0 ? 'Total Spent' : 'No Expenses',
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'SPENDING DISTRIBUTION',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Dynamic Category Legend Grid
                          if (topCategories.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  for (int i = 0; i < topCategories.length; i += 2) ...[
                                    if (i > 0) const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildLegendItem(
                                            topCategories[i].key,
                                            '${((topCategories[i].value / totalExpenses) * 100).round()}%',
                                            categoryColors[i % categoryColors.length],
                                            amount: currencyFormat.format(topCategories[i].value),
                                          ),
                                        ),
                                        if (i + 1 < topCategories.length)
                                          Expanded(
                                            child: _buildLegendItem(
                                              topCategories[i + 1].key,
                                              '${((topCategories[i + 1].value / totalExpenses) * 100).round()}%',
                                              categoryColors[(i + 1) % categoryColors.length],
                                              amount: currencyFormat.format(topCategories[i + 1].value),
                                            ),
                                          )
                                        else
                                          const Spacer(),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: () => QuickAddBottomSheet.show(context, _effectiveUser),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF0F766E)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'No expenses yet. Tap + to add.',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF0F766E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                  if (_selectedTabIndex == 0 || _selectedTabIndex == 2) ...[
                    const SizedBox(height: 24),

                    // Section Header: FAMILY BREAKDOWN / Monthly Caps
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FAMILY BREAKDOWN',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 0.6,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LimitsBillsScreen(
                                  currentUser: _effectiveUser,
                                  initialIndex: 0,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Monthly Caps',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F766E),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: Color(0xFF0F766E),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Dynamic Real Family Breakdown
                    _buildFamilyBreakdownSection(
                      expenses: expenses,
                      currencyFormat: currencyFormat,
                      totalExpenses: totalExpenses,
                    ),

                    const SizedBox(height: 24),

                    // UPCOMING BILLS SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'UPCOMING BILLS',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 0.6,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BillsScreen(
                                  currentUser: _effectiveUser,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Manage All',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F766E),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: Color(0xFF0F766E),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<List<BillModel>>(
                      stream: _firestoreService.getBills(familyId: _effectiveUser.familyId),
                      builder: (context, billSnap) {
                        final bills = billSnap.data ?? [];
                        final unpaidBills = bills.where((b) => !b.isPaid).toList();

                        if (unpaidBills.isEmpty) {
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddBillScreen(currentUser: _effectiveUser),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2FE),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF0284C7), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'No bills due right now',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.5),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Tap to set a reminder for rent, utilities, etc.',
                                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.add_circle_outline, color: Color(0xFF0F766E), size: 20),
                                ],
                              ),
                            ),
                          );
                        }

                        final nextBill = unpaidBills.first;
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BillsScreen(currentUser: _effectiveUser),
                            ),
                          ),
                          child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.calendar_today_rounded, color: Color(0xFFD97706), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nextBill.title,
                                      style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Due ${DateFormat('MMM dd, yyyy').format(nextBill.dueDate)}',
                                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                currencyFormat.format(nextBill.amount),
                                style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF0F172A)),
                              ),
                            ],
                          ),
                        ),
                      );
                      },
                    ),

                    const SizedBox(height: 24),

                    // GOAL TRACKER SECTION
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SAVINGS GOALS',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 0.6,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GoalsScreen(
                                  currentUser: _effectiveUser,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Goal Tracker',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0F766E),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: Color(0xFF0F766E),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<List<GoalModel>>(
                      stream: _firestoreService.getGoals(familyId: _effectiveUser.familyId),
                      builder: (context, goalSnap) {
                        final goals = goalSnap.data ?? [];

                        if (goals.isEmpty) {
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GoalsScreen(
                                  currentUser: _effectiveUser,
                                ),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3E8FF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.savings_rounded, color: Color(0xFF7C3AED), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Start a Family Savings Goal',
                                          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13.5),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Track funds for trips, education, or big purchases',
                                          style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.add_circle_outline, color: Color(0xFF0F766E), size: 20),
                                ],
                              ),
                            ),
                          );
                        }

                        final topGoal = goals.first;
                        final progress = topGoal.targetAmount > 0
                            ? (topGoal.savedAmount / topGoal.targetAmount).clamp(0.0, 1.0)
                            : 0.0;
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GoalsScreen(currentUser: _effectiveUser),
                            ),
                          ),
                          child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    topGoal.title,
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                  Text(
                                    '${currencyFormat.format(topGoal.savedAmount)} / ${currencyFormat.format(topGoal.targetAmount)}',
                                    style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF0F766E)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      },
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class DonutSegment {
  final double value;
  final Color color;

  const DonutSegment({required this.value, required this.color});
}

class SpendingDonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final double size;
  final double strokeWidth;
  final String? centerAmount;
  final String centerLabel;

  const SpendingDonutChart({
    super.key,
    required this.segments,
    this.size = 170,
    this.strokeWidth = 24,
    this.centerAmount,
    this.centerLabel = 'Total Spent',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutChartPainter(
              segments: segments,
              strokeWidth: strokeWidth,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (centerAmount != null && centerAmount!.isNotEmpty) ...[
                Text(
                  centerAmount!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  centerLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ] else ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF0F766E), width: 2.2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 18,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  centerLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double strokeWidth;

  _DonutChartPainter({required this.segments, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total == 0) return;

    double startAngle = -pi / 2;

    for (final segment in segments) {
      final sweepAngle = (segment.value / total) * 2 * pi;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}
