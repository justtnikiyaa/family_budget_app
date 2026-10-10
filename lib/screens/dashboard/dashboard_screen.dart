import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel? currentUser;

  const DashboardScreen({super.key, this.currentUser});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _authService = AuthService();
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
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
              Container(
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
                                'Rs. 1,240.00',
                                style: GoogleFonts.inter(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
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
                                  fontSize: 16,
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

              // Donut Chart & Spending Distribution Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SpendingDonutChart(
                      segments: [
                        DonutSegment(value: 40, color: Color(0xFF0F766E)), // Groceries (Teal)
                        DonutSegment(value: 25, color: Color(0xFF334155)), // Utilities (Dark slate)
                        DonutSegment(value: 20, color: Color(0xFF10B981)), // Education (Emerald)
                        DonutSegment(value: 15, color: Color(0xFF2DD4BF)), // Leisure (Cyan/Mint)
                      ],
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
                  ],
                ),
              ),
            ],
          ),
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
