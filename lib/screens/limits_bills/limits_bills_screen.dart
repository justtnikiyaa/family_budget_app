import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../models/limit_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../main_navigation.dart';
import 'bills_screen.dart';
import 'goals_screen.dart';
import 'reports_screen.dart';
import 'set_budget_limit_screen.dart';

class LimitsBillsScreen extends StatefulWidget {
  final UserModel? currentUser;
  final int initialIndex;
  final VoidCallback? onBackToOverview;

  const LimitsBillsScreen({
    super.key,
    this.currentUser,
    this.initialIndex = 0,
    this.onBackToOverview,
  });

  static void showAddLimitDialog(BuildContext context, UserModel? currentUser) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetBudgetLimitScreen(currentUser: currentUser),
      ),
    );
  }

  @override
  State<LimitsBillsScreen> createState() => _LimitsBillsScreenState();
}

class _LimitsBillsScreenState extends State<LimitsBillsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  void _openSetBudgetLimitScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SetBudgetLimitScreen(currentUser: widget.currentUser),
      ),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  void _navigateToOverview() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (widget.onBackToOverview != null) {
      widget.onBackToOverview!();
    } else if (widget.currentUser != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(
            currentUser: widget.currentUser!,
          ),
        ),
      );
    }
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('food') || lower.contains('grocer') || lower.contains('dining')) {
      return Icons.restaurant_outlined;
    } else if (lower.contains('fuel') || lower.contains('transport')) {
      return Icons.local_gas_station_outlined;
    } else if (lower.contains('entertain') || lower.contains('movie')) {
      return Icons.movie_filter_outlined;
    } else if (lower.contains('fit') || lower.contains('gym')) {
      return Icons.fitness_center_rounded;
    } else if (lower.contains('gift')) {
      return Icons.card_giftcard_rounded;
    } else if (lower.contains('bill') || lower.contains('util')) {
      return Icons.receipt_long_outlined;
    } else if (lower.contains('shop')) {
      return Icons.shopping_bag_outlined;
    }
    return Icons.grid_view_rounded;
  }

  void _showLimitActions(LimitModel limit, double spent, double ratio) {
    final currencyFormat = NumberFormat('#,###');
    final remaining = (limit.limitAmount - spent).clamp(0.0, double.infinity);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    limit.category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ratio >= 0.9
                          ? const Color(0xFFFEE2E2)
                          : (ratio >= 0.8 ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${(ratio * 100).toInt()}% Used',
                      style: TextStyle(
                        color: ratio >= 0.9
                            ? const Color(0xFFDC2626)
                            : (ratio >= 0.8 ? const Color(0xFFD97706) : const Color(0xFF16A34A)),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Spent: Rs. ${currencyFormat.format(spent.toInt())} • Limit: Rs. ${currencyFormat.format(limit.limitAmount.toInt())} • Remaining: Rs. ${currencyFormat.format(remaining.toInt())}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                label: const Text('Delete Limit', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _firestoreService.deleteLimit(limit.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Budget limit for ${limit.category} deleted.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLimitsView() {
    final now = DateTime.now();
    final currentMonthKey = DateFormat('yyyy-MM').format(now);
    final monthBadge = DateFormat('MMM yyyy').format(now).toUpperCase();

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _navigateToOverview();
        }
      },
      child: Scaffold(
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
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 16, color: Color(0xFF0F172A)),
                onPressed: _navigateToOverview,
              ),
            ),
          ),
          title: const Text(
            'Limits',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 0.3,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'limits_fab',
          onPressed: _openSetBudgetLimitScreen,
          backgroundColor: const Color(0xFF065F46),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
        body: StreamBuilder<List<ExpenseModel>>(
          stream: _firestoreService.getExpenses(
            familyId: widget.currentUser?.familyId,
            userId: widget.currentUser?.familyId == null ? widget.currentUser?.uid : null,
          ),
          builder: (context, expSnapshot) {
            final allExpenses = expSnapshot.data ?? [];

            return StreamBuilder<List<LimitModel>>(
              stream: _firestoreService.getLimits(
                monthYear: currentMonthKey,
                familyId: widget.currentUser?.familyId,
              ),
              builder: (context, snapshot) {
                final firestoreLimits = snapshot.data ?? [];

                // Calculate actual spent for each limit
                final List<Map<String, dynamic>> calculatedLimits = [];
                for (final limit in firestoreLimits) {
                  double spent = 0.0;
                  for (final e in allExpenses) {
                    if (e.type == ExpenseType.expense &&
                        e.category.toLowerCase().trim() == limit.category.toLowerCase().trim()) {
                      spent += e.amount;
                    }
                  }
                  if (spent == 0.0 && limit.spentAmount > 0) {
                    spent = limit.spentAmount;
                  }

                  final double ratio = limit.limitAmount > 0
                      ? (spent / limit.limitAmount).clamp(0.0, 1.0)
                      : 0.0;

                  calculatedLimits.add({
                    'model': limit,
                    'category': limit.category,
                    'spent': spent,
                    'limit': limit.limitAmount,
                    'ratio': ratio,
                  });
                }

                // Sort at-risk limits descending by ratio
                calculatedLimits.sort((a, b) => (b['ratio'] as double).compareTo(a['ratio'] as double));
                final atRiskLimits = calculatedLimits.where((item) => (item['ratio'] as double) >= 0.8).toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // 1. AT-RISK CATEGORIES Header
                    Row(
                      children: const [
                        Icon(Icons.circle, color: Color(0xFFF59E0B), size: 8),
                        SizedBox(width: 8),
                        Text(
                          'AT-RISK CATEGORIES',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Horizontal At-Risk Cards Row
                    if (atRiskLimits.isNotEmpty)
                      SizedBox(
                        height: 185,
                        child: Row(
                          children: [
                            // Card 1: Top At-Risk (Dark Theme / Critical)
                            Expanded(
                              child: _buildAtRiskDarkCard(atRiskLimits.first),
                            ),
                            const SizedBox(width: 14),

                            // Card 2: 2nd At-Risk if exists, else Light Status Card
                            Expanded(
                              child: atRiskLimits.length > 1
                                  ? _buildAtRiskLightCard(atRiskLimits[1])
                                  : _buildAtRiskSafeNoticeCard(),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'All categories within healthy limits (under 80% used). Great job keeping spending on track!',
                                style: TextStyle(color: Color(0xFF166534), fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // 2. ALL BUDGETS Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'ALL BUDGETS',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.circle, color: Color(0xFF10B981), size: 7),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF059669)),
                              const SizedBox(width: 6),
                              Text(
                                monthBadge,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Budget Category List Items
                    if (calculatedLimits.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.speed_outlined, size: 36, color: Color(0xFFCBD5E1)),
                            const SizedBox(height: 10),
                            const Text(
                              'No budget caps set for this month.',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap the "+" button below to set limits for Groceries, Fuel, or Dining.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      )
                    else
                      ...calculatedLimits.map((b) {
                        final LimitModel model = b['model'] as LimitModel;
                        final double spent = b['spent'] as double;
                        final double limit = b['limit'] as double;
                        final double ratio = b['ratio'] as double;

                        return InkWell(
                          onTap: () => _showLimitActions(model, spent, ratio),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE6F4EA),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(model.category),
                                        color: const Color(0xFF059669),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        model.category,
                                        style: const TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Rs. ${spent.toInt()}',
                                            style: const TextStyle(
                                              color: Color(0xFF0F172A),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' / Rs. ${limit.toInt()}',
                                            style: const TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ratio >= 0.9
                                          ? const Color(0xFFEF4444)
                                          : (ratio >= 0.8 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                                    ),
                                    minHeight: 7,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 80),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildAtRiskDarkCard(Map<String, dynamic> item) {
    final category = item['category'] as String;
    final ratio = item['ratio'] as double;
    final isCritical = ratio >= 0.9;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1B15), Color(0xFF142E24)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1B15).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF232D23),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFFBBF24), size: 18),
          ),
          const Spacer(),
          Text(
            category,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${(ratio * 100).toInt()}% Used',
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              if (isCritical)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F1D1D),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Critical',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: const Color(0xFF1E3A2F),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtRiskLightCard(Map<String, dynamic> item) {
    final category = item['category'] as String;
    final ratio = item['ratio'] as double;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: Icon(_getCategoryIcon(category), color: const Color(0xFF10B981), size: 18),
          ),
          const Spacer(),
          Text(
            category,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(ratio * 100).toInt()}% Used',
            style: const TextStyle(
              color: Color(0xFF059669),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtRiskSafeNoticeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 24),
          Spacer(),
          Text(
            'Safe Track',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'All other categories are safely within monthly caps.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialIndex == 1) {
      return BillsScreen(currentUser: widget.currentUser);
    } else if (widget.initialIndex == 2) {
      return GoalsScreen(currentUser: widget.currentUser);
    } else if (widget.initialIndex == 3) {
      return ReportsScreen(currentUser: widget.currentUser);
    }

    return _buildLimitsView();
  }
}
