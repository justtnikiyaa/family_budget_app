import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../profile/profile_screen.dart';
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

  Widget _buildLegendItem(String title, String percent, Color color) {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              percent,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
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
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFE2E8F0),
                  child: Icon(fallbackIcon, color: const Color(0xFF64748B), size: 24),
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
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      amount,
                      style: GoogleFonts.inter(
                        fontSize: 16,
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
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
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

  void _showNotificationsSheet() {
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
                'Monthly budget pool is healthy',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              subtitle: Text(
                '14 days remaining in current cycle',
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
                final member = (exp.userName != null && exp.userName!.isNotEmpty) ? exp.userName! : 'Dad';
                memberTotals[member] = (memberTotals[member] ?? 0) + exp.amount;
              } else {
                totalIncome += exp.amount;
              }
            }

            final double availableBalance = expenses.isNotEmpty && totalIncome > 0
                ? (totalIncome - totalExpenses)
                : 1240.0;
            final String availableBalanceString = expenses.isNotEmpty
                ? currencyFormat.format(availableBalance > 0 ? availableBalance : 1240.0)
                : 'Rs. 1,240.00';

            // Category Distribution
            List<DonutSegment> segments;
            String groceriesPercent = '40%';
            String utilitiesPercent = '25%';
            String educationPercent = '20%';
            String leisurePercent = '15%';

            if (expenses.isNotEmpty && totalExpenses > 0) {
              final gAmount = categoryTotals['Groceries'] ?? categoryTotals['Food & Dining'] ?? (totalExpenses * 0.40);
              final uAmount = categoryTotals['Utilities & Bills'] ?? categoryTotals['Utilities'] ?? (totalExpenses * 0.25);
              final eAmount = categoryTotals['Education'] ?? (totalExpenses * 0.20);
              final lAmount = categoryTotals['Entertainment'] ??
                  categoryTotals['Shopping'] ??
                  categoryTotals['Leisure'] ??
                  (totalExpenses * 0.15);

              final gPct = (gAmount / totalExpenses * 100).round().clamp(5, 70);
              final uPct = (uAmount / totalExpenses * 100).round().clamp(5, 50);
              final ePct = (eAmount / totalExpenses * 100).round().clamp(5, 40);
              final lPct = (lAmount / totalExpenses * 100).round().clamp(5, 40);

              groceriesPercent = '$gPct%';
              utilitiesPercent = '$uPct%';
              educationPercent = '$ePct%';
              leisurePercent = '$lPct%';

              segments = [
                DonutSegment(value: gPct.toDouble(), color: const Color(0xFF0F766E)),
                DonutSegment(value: uPct.toDouble(), color: const Color(0xFF334155)),
                DonutSegment(value: ePct.toDouble(), color: const Color(0xFF10B981)),
                DonutSegment(value: lPct.toDouble(), color: const Color(0xFF2DD4BF)),
              ];
            } else {
              segments = const [
                DonutSegment(value: 40, color: Color(0xFF0F766E)), // Groceries (Teal)
                DonutSegment(value: 25, color: Color(0xFF334155)), // Utilities (Dark slate)
                DonutSegment(value: 20, color: Color(0xFF10B981)), // Education (Emerald)
                DonutSegment(value: 15, color: Color(0xFF2DD4BF)), // Leisure (Cyan/Mint)
              ];
            }

            // Member breakdown calculations
            final dadSpent = memberTotals['Dad'] ?? 1450.0;
            final momSpent = memberTotals['Mom'] ?? 1820.0;
            final dadLimit = 3600.0;
            final momLimit = 2400.0;
            final dadProgress = (dadSpent / dadLimit).clamp(0.0, 1.0);
            final momProgress = (momSpent / momLimit).clamp(0.0, 1.0);

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
                        onTap: _showNotificationsSheet,
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
                                      'Feb 2026',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '14 days left',
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
                                      'Family Shared Vault',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2DD4BF),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'Cycle: 15th to 14th',
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

                          // Category Legend Grid (2x2 Box)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildLegendItem('Groceries', groceriesPercent, const Color(0xFF0F766E)),
                                    ),
                                    Expanded(
                                      child: _buildLegendItem('Utilities', utilitiesPercent, const Color(0xFF334155)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildLegendItem('Education', educationPercent, const Color(0xFF10B981)),
                                    ),
                                    Expanded(
                                      child: _buildLegendItem('Leisure', leisurePercent, const Color(0xFF2DD4BF)),
                                    ),
                                  ],
                                ),
                              ],
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
                        Text(
                          'Monthly Caps',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Member Card 1: Dad
                    _buildMemberCard(
                      name: 'Dad',
                      amount: expenses.isNotEmpty ? currencyFormat.format(dadSpent) : 'Rs. 1,450.00',
                      progress: dadProgress,
                      progressColor: const Color(0xFF0F766E),
                      budgetUsedText: 'Budget used: ${(dadProgress * 100).round()}%',
                      limitText: 'Limit Rs. 3,600.00',
                      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
                      fallbackIcon: Icons.person_rounded,
                    ),
                    const SizedBox(height: 10),

                    // Member Card 2: Mom
                    _buildMemberCard(
                      name: 'Mom',
                      amount: expenses.isNotEmpty ? currencyFormat.format(momSpent) : 'Rs. 1,820.00',
                      progress: momProgress,
                      progressColor: const Color(0xFF059669),
                      budgetUsedText: 'Budget used: ${(momProgress * 100).round()}%',
                      limitText: 'Limit Rs. 2,400.00',
                      avatarUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150',
                      fallbackIcon: Icons.person_outline_rounded,
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

  const SpendingDonutChart({
    super.key,
    required this.segments,
    this.size = 170,
    this.strokeWidth = 24,
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
                'Pool Met',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
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
