import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class ReportsScreen extends StatefulWidget {
  final UserModel? currentUser;

  const ReportsScreen({super.key, this.currentUser});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  DateTime _selectedMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy').format(_selectedMonth).toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF0F172A)),
              onPressed: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
            ),
          ),
        ),
        title: const Text(
          'REPORT',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ExpenseModel>>(
          stream: _firestoreService.getExpenses(
            familyId: widget.currentUser?.familyId,
            userId: widget.currentUser?.familyId == null ? widget.currentUser?.uid : null,
          ),
          builder: (context, snapshot) {
            final allExpenses = snapshot.data ?? [];

            final monthExpenses = allExpenses.where((e) {
              return e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month;
            }).toList();

            double income = 0.0;
            double expenses = 0.0;

            for (final e in monthExpenses) {
              if (e.type == ExpenseType.income) {
                income += e.amount;
              } else {
                expenses += e.amount;
              }
            }

            final double saved = income - expenses;
            final double savedPct = income > 0 ? (saved / income) * 100 : 0.0;

            final currencyFormat = NumberFormat('#,###');

            // Category Breakdown for Donut Chart
            final Map<String, double> categoryTotals = {};
            for (final e in monthExpenses.where((e) => e.type == ExpenseType.expense)) {
              categoryTotals[e.category] = (categoryTotals[e.category] ?? 0.0) + e.amount;
            }

            final sortedCategories = categoryTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final categoryColors = [
              const Color(0xFF0F766E),
              const Color(0xFF16A34A),
              const Color(0xFF4ADE80),
              const Color(0xFFF59E0B),
              const Color(0xFF8B5CF6),
              const Color(0xFFEC4899),
            ];

            final List<DonutSegment> segments = [];
            if (expenses > 0) {
              for (int i = 0; i < sortedCategories.length; i++) {
                final pct = sortedCategories[i].value / expenses;
                final col = categoryColors[i % categoryColors.length];
                segments.add(DonutSegment(color: col, percentage: pct));
              }
            } else {
              segments.add(DonutSegment(color: const Color(0xFFE2E8F0), percentage: 1.0));
            }

            // Member Breakdown
            final Map<String, double> memberSpend = {};
            for (final e in monthExpenses.where((e) => e.type == ExpenseType.expense)) {
              final String name = e.userName != null && e.userName!.trim().isNotEmpty
                  ? e.userName!.trim()
                  : (e.userId == widget.currentUser?.uid
                      ? (widget.currentUser?.displayName.isNotEmpty == true
                          ? widget.currentUser!.displayName
                          : 'You')
                      : 'Family Member');
              memberSpend[name] = (memberSpend[name] ?? 0.0) + e.amount;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Month Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Color(0xFF64748B)),
                        onPressed: _previousMonth,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Text(
                          monthName,
                          style: const TextStyle(
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 2. Financial Summary Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        children: [
                          Container(
                            height: 4,
                            color: const Color(0xFF10B981),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'INCOME',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      'Rs. ${currencyFormat.format(income.toInt())}',
                                      style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'EXPENSES',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      'Rs. ${currencyFormat.format(expenses.toInt())}',
                                      style: const TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 28, color: Color(0xFFF1F5F9)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'SAVED',
                                          style: TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: saved >= 0
                                                ? const Color(0xFFD1FAE5)
                                                : const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '${saved >= 0 ? '+' : ''}${savedPct.toStringAsFixed(1)}%',
                                            style: TextStyle(
                                              color: saved >= 0
                                                  ? const Color(0xFF059669)
                                                  : const Color(0xFFDC2626),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Rs. ${currencyFormat.format(saved.toInt())}',
                                      style: TextStyle(
                                        color: saved >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. BY CATEGORY Section with Donut Chart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BY CATEGORY',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        'Total: Rs. ${currencyFormat.format(expenses.toInt())}',
                        style: const TextStyle(
                          color: Color(0xFF0D9488),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 170,
                          width: 170,
                          child: CustomPaint(
                            painter: DonutChartPainter(segments: segments),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'TOTAL OUT',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Rs. ${currencyFormat.format(expenses.toInt())}',
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Dynamic Legend
                        if (sortedCategories.isNotEmpty)
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: sortedCategories.take(4).map((entry) {
                              final idx = sortedCategories.indexOf(entry);
                              final col = categoryColors[idx % categoryColors.length];
                              final pct = expenses > 0 ? (entry.value / expenses) * 100 : 0.0;
                              return _buildLegendItem(col, entry.key.toUpperCase(), '${pct.toStringAsFixed(0)}%');
                            }).toList(),
                          )
                        else
                          const Text(
                            'No category expenses recorded for this month.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. BY MEMBER Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BY MEMBER',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        '${memberSpend.length} ${memberSpend.length == 1 ? 'Participant' : 'Participants'}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                    ),
                    child: memberSpend.isNotEmpty
                        ? Column(
                            children: memberSpend.entries.map((entry) {
                              final isLast = entry.key == memberSpend.keys.last;
                              final spend = entry.value;
                              final pct = expenses > 0 ? (spend / expenses) : 0.0;
                              final initial = entry.key.isNotEmpty ? entry.key[0].toUpperCase() : 'M';

                              return Column(
                                children: [
                                  _buildMemberRow(
                                    initial,
                                    entry.key,
                                    'Rs. ${currencyFormat.format(spend.toInt())}',
                                    '${(pct * 100).toInt()}%',
                                    pct,
                                  ),
                                  if (!isLast) const Divider(height: 24, color: Color(0xFFF1F5F9)),
                                ],
                              );
                            }).toList(),
                          )
                        : const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: Text(
                                'No member expenses recorded for this month.',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // 5. EXPORT / SHARE Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Financial report for $monthName exported successfully!'),
                            backgroundColor: const Color(0xFF166534),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF15803D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      icon: const Icon(Icons.file_upload_outlined, color: Colors.white, size: 20),
                      label: const Text(
                        'EXPORT / SHARE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String percentage) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label $percentage',
          style: const TextStyle(
            color: Color(0xFF475569),
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberRow(
      String initial, String name, String amount, String percentage, double progress) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: const TextStyle(
                  color: Color(0xFF15803D),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    percentage,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

class DonutSegment {
  final Color color;
  final double percentage;

  DonutSegment({required this.color, required this.percentage});
}

class DonutChartPainter extends CustomPainter {
  final List<DonutSegment> segments;

  DonutChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 12;
    const strokeWidth = 18.0;

    double startAngle = -pi / 2;

    for (final segment in segments) {
      final sweepAngle = 2 * pi * segment.percentage;

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      if (sweepAngle > 0.05) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle - 0.04,
          false,
          paint,
        );
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
