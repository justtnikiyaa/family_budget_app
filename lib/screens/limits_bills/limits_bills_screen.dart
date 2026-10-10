import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/bill_model.dart';
import '../../models/limit_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import 'goals_screen.dart';
import 'reports_screen.dart';

class LimitsBillsScreen extends StatefulWidget {
  final UserModel? currentUser;
  final int initialIndex;

  const LimitsBillsScreen({
    super.key,
    this.currentUser,
    this.initialIndex = 0,
  });

  @override
  State<LimitsBillsScreen> createState() => _LimitsBillsScreenState();
}

class _LimitsBillsScreenState extends State<LimitsBillsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialIndex.clamp(0, 3),
    );
  }

  @override
  void didUpdateWidget(covariant LimitsBillsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _tabController.animateTo(widget.initialIndex.clamp(0, 3));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddLimitDialog() {
    final amountController = TextEditingController();
    String selectedCategory = AppConstants.expenseCategories.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                  await _firestoreService.setLimit(
                    LimitModel(
                      id: '',
                      category: selectedCategory,
                      limitAmount: limit,
                      spentAmount: 0.0,
                      monthYear: currentMonth,
                      familyId: widget.currentUser?.familyId,
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

  void _showAddBillDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
                  await _firestoreService.addBill(
                    BillModel(
                      id: '',
                      title: title,
                      amount: amount,
                      dueDate: selectedDate,
                      familyId: widget.currentUser?.familyId,
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
  Widget build(BuildContext context) {
    final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
    final currencyFormat = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Limits, Bills & Goals'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Category Limits', icon: Icon(Icons.speed)),
            Tab(text: 'Bill Reminders', icon: Icon(Icons.notifications_active_outlined)),
            Tab(text: 'Goals', icon: Icon(Icons.savings_outlined)),
            Tab(text: 'Reports', icon: Icon(Icons.bar_chart_outlined)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Category Limits Tab
          Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'categoryLimitFab',
              onPressed: _showAddLimitDialog,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('New Limit', style: TextStyle(color: Colors.white)),
            ),
            body: StreamBuilder<List<LimitModel>>(
              stream: _firestoreService.getLimits(
                monthYear: currentMonth,
                familyId: widget.currentUser?.familyId,
              ),
              builder: (context, snapshot) {
                final limits = snapshot.data ?? [];

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (limits.isEmpty) {
                  return Center(
                    child: Text(
                      'No category limits set for this month.\nTap + to set a spending cap!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: limits.length,
                  itemBuilder: (context, index) {
                    final item = limits[index];
                    final ratio = item.limitAmount > 0
                        ? (item.spentAmount / item.limitAmount).clamp(0.0, 1.0)
                        : 0.0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.category,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  '${currencyFormat.format(item.spentAmount)} / ${currencyFormat.format(item.limitAmount)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ratio,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ratio > 0.85 ? AppColors.expense : AppColors.primary,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 2. Bill Reminders Tab
          Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'billReminderFab',
              onPressed: _showAddBillDialog,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('New Bill', style: TextStyle(color: Colors.white)),
            ),
            body: StreamBuilder<List<BillModel>>(
              stream: _firestoreService.getBills(familyId: widget.currentUser?.familyId),
              builder: (context, snapshot) {
                final bills = snapshot.data ?? [];

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (bills.isEmpty) {
                  return Center(
                    child: Text(
                      'No upcoming bills registered.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bills.length,
                  itemBuilder: (context, index) {
                    final bill = bills[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Icon(
                          bill.isPaid ? Icons.check_circle : Icons.pending_actions,
                          color: bill.isPaid ? AppColors.income : AppColors.warning,
                        ),
                        title: Text(
                          bill.title,
                          style: TextStyle(
                            decoration: bill.isPaid ? TextDecoration.lineThrough : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text('Due: ${dateFormat.format(bill.dueDate)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currencyFormat.format(bill.amount),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Checkbox(
                              value: bill.isPaid,
                              onChanged: (val) {
                                if (val != null) {
                                  _firestoreService.updateBillStatus(bill.id, val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 3. Goals Tab
          GoalsScreen(currentUser: widget.currentUser),

          // 4. Reports Tab
          ReportsScreen(currentUser: widget.currentUser),
        ],
      ),
    );
  }
}
