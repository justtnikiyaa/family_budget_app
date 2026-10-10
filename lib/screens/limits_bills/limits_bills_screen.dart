import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/bill_model.dart';
import '../../models/limit_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import 'bills_screen.dart';
import 'goals_screen.dart';
import 'reports_screen.dart';
import 'set_budget_limit_screen.dart';

class LimitsBillsScreen extends StatefulWidget {
  final UserModel? currentUser;
  final int initialIndex;

  const LimitsBillsScreen({
    super.key,
    this.currentUser,
    this.initialIndex = 0,
  });

  static void showAddLimitDialog(BuildContext context, UserModel? currentUser) {
    final amountController = TextEditingController();
    String selectedCategory = AppConstants.expenseCategories.first;
    final firestoreService = FirestoreService();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Set Category Limit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: AppConstants.expenseCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedCategory = val);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monthly Limit (Rs)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final limit = double.tryParse(amountController.text.trim()) ?? 0.0;
                final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());

                if (limit > 0) {
                  await firestoreService.setLimit(
                    LimitModel(
                      id: '',
                      category: selectedCategory,
                      limitAmount: limit,
                      spentAmount: 0.0,
                      monthYear: currentMonth,
                      familyId: currentUser?.familyId,
                    ),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Save Limit'),
            ),
          ],
        ),
      ),
    );
  }

  static void showAddBillDialog(BuildContext context, UserModel? currentUser) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    final firestoreService = FirestoreService();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Upcoming Bill'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Bill Name (e.g. Electricity, WiFi)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount (Rs)'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Due Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final amount = double.tryParse(amountController.text.trim()) ?? 0.0;

                if (title.isNotEmpty && amount > 0) {
                  await firestoreService.addBill(
                    BillModel(
                      id: '',
                      title: title,
                      amount: amount,
                      dueDate: selectedDate,
                      familyId: currentUser?.familyId,
                    ),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Save Bill'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<LimitsBillsScreen> createState() => _LimitsBillsScreenState();
}

class _LimitsBillsScreenState extends State<LimitsBillsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  int _selectedTabIndex = 0;
  final String _selectedMonth = 'FEB 2026';

  // Benchmark default categories matching prototype screenshot 1
  final List<Map<String, dynamic>> _benchmarkBudgets = [
    {
      'category': 'Food',
      'icon': Icons.grid_view_rounded,
      'spent': 450.0,
      'limit': 500.0,
      'iconBg': const Color(0xFFE6F4EA),
      'iconColor': const Color(0xFF059669),
    },
    {
      'category': 'Entertainment',
      'icon': Icons.movie_filter_outlined,
      'spent': 200.0,
      'limit': 500.0,
      'iconBg': const Color(0xFFE6F4EA),
      'iconColor': const Color(0xFF059669),
    },
    {
      'category': 'Fitness',
      'icon': Icons.fitness_center_rounded,
      'spent': 200.0,
      'limit': 500.0,
      'iconBg': const Color(0xFFF7FEE7),
      'iconColor': const Color(0xFF65A30D),
    },
    {
      'category': 'Gifts',
      'icon': Icons.card_giftcard_rounded,
      'spent': 220.0,
      'limit': 300.0,
      'iconBg': const Color(0xFFF3F4F6),
      'iconColor': const Color(0xFF4B5563),
    },
    {
      'category': 'Fuel',
      'icon': Icons.local_gas_station_outlined,
      'spent': 0.0,
      'limit': 500.0,
      'iconBg': const Color(0xFFE0F2FE),
      'iconColor': const Color(0xFF0284C7),
    },
  ];

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

  Widget _buildLimitsView() {
    final currentMonthKey = DateFormat('yyyy-MM').format(DateTime.now());

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
              icon: const Icon(Icons.arrow_back_ios_new,
                  size: 16, color: Color(0xFF0F172A)),
              onPressed: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
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
      body: StreamBuilder<List<LimitModel>>(
        stream: _firestoreService.getLimits(
          monthYear: currentMonthKey,
          familyId: widget.currentUser?.familyId,
        ),
        builder: (context, snapshot) {
          final firestoreLimits = snapshot.data ?? [];

          List<Map<String, dynamic>> displayedBudgets =
              List.from(_benchmarkBudgets);
          if (firestoreLimits.isNotEmpty) {
            final mapped = firestoreLimits.map((l) {
              return {
                'category': l.category,
                'icon': Icons.grid_view_rounded,
                'spent': l.spentAmount,
                'limit': l.limitAmount,
                'iconBg': const Color(0xFFE6F4EA),
                'iconColor': const Color(0xFF059669),
              };
            }).toList();
            displayedBudgets = mapped;
          }

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
              SizedBox(
                height: 185,
                child: Row(
                  children: [
                    // Card 1: Food (Critical / Dark Theme)
                    Expanded(
                      child: Container(
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
                                  color: const Color(0xFFF59E0B)
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Icon(Icons.warning_amber_rounded,
                                  color: Color(0xFFFBBF24), size: 18),
                            ),
                            const Spacer(),
                            const Text(
                              'Food',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text(
                                  '95% Used',
                                  style: TextStyle(
                                    color: Color(0xFFFBBF24),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
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
                                value: 0.95,
                                backgroundColor: const Color(0xFF1E3A2F),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFFF59E0B)),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Card 2: Gift (Light Theme)
                    Expanded(
                      child: Container(
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
                              child: const Icon(Icons.card_giftcard_rounded,
                                  color: Color(0xFF10B981), size: 18),
                            ),
                            const Spacer(),
                            const Text(
                              'Gift',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '82% Used',
                              style: TextStyle(
                                color: Color(0xFF059669),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: 0.82,
                                backgroundColor: const Color(0xFFF1F5F9),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF10B981)),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: Color(0xFF059669)),
                        const SizedBox(width: 6),
                        Text(
                          _selectedMonth,
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
              ...displayedBudgets.map((b) {
                final double spent = (b['spent'] as num).toDouble();
                final double limit = (b['limit'] as num).toDouble();
                final double ratio =
                    limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;

                return Container(
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
                              color: b['iconBg'] as Color,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              b['icon'] as IconData,
                              color: b['iconColor'] as Color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              b['category'] as String,
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
                            ratio >= 0.8
                                ? const Color(0xFF059669)
                                : const Color(0xFF10B981),
                          ),
                          minHeight: 7,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 70),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildLimitsView(),
      GoalsScreen(currentUser: widget.currentUser),
      ReportsScreen(currentUser: widget.currentUser),
      BillsScreen(currentUser: widget.currentUser),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedTabIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedTabIndex = index);
        },
        indicatorColor: const Color(0xFFD1FAE5),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.speed_outlined),
            selectedIcon: Icon(Icons.speed, color: Color(0xFF059669)),
            label: 'Limits',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag, color: Color(0xFF059669)),
            label: 'Goal Tracker',
          ),
          NavigationDestination(
            icon: Icon(Icons.donut_large_outlined),
            selectedIcon: Icon(Icons.donut_large, color: Color(0xFF059669)),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF059669)),
            label: 'Bills',
          ),
        ],
      ),
    );
  }
}
