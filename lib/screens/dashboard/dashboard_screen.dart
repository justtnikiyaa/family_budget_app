import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../models/family_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../widgets/quick_add_bottom_sheet.dart';
import '../../widgets/summary_card.dart';
import 'create_family_screen.dart';
import '../auth/join_family_screen.dart';

class DashboardScreen extends StatelessWidget {
  final UserModel? currentUser;

  const DashboardScreen({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final effectiveUser = currentUser ?? UserModel(
      uid: authService.currentUser?.uid ?? '',
      email: authService.currentUser?.email ?? '',
      displayName: authService.currentUser?.displayName ?? 'User',
    );

    final currencyFormat = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${effectiveUser.displayName} 👋',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Family Budget Overview',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 28),
            tooltip: 'Quick Add',
            onPressed: () => QuickAddBottomSheet.show(context, effectiveUser),
          ),
        ],
      ),
      body: StreamBuilder<FamilyModel?>(
        stream: effectiveUser.familyId != null && effectiveUser.familyId!.isNotEmpty
            ? firestoreService.getFamilyStream(effectiveUser.familyId!)
            : Stream.value(null),
        builder: (context, familySnapshot) {
          final family = familySnapshot.data;

          return StreamBuilder<List<ExpenseModel>>(
            stream: firestoreService.getExpenses(
              familyId: effectiveUser.familyId,
              userId: effectiveUser.familyId == null ? effectiveUser.uid : null,
            ),
            builder: (context, expenseSnapshot) {
              final expenses = expenseSnapshot.data ?? [];

              double totalIncome = 0;
              double totalExpense = 0;

              for (final e in expenses) {
                if (e.type == ExpenseType.income) {
                  totalIncome += e.amount;
                } else {
                  totalExpense += e.amount;
                }
              }

              final totalBalance = totalIncome - totalExpense;

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Family Status Card
                  if (family == null)
                    Card(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.family_restroom, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text(
                                  'Shared Family Wallet',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Create or join a family to pool budgets, share bills, and monitor expenses together.',
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CreateFamilyScreen(currentUser: effectiveUser),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('Create Family'),
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(40),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => JoinFamilyScreen(currentUser: effectiveUser),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.group_add, size: 16),
                                    label: const Text('Join Code'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(40),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.home_work_outlined, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Text(
                                family.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Code: ${family.inviteCode}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Overall Balance Card
                  SummaryCard(
                    title: 'Family Net Balance',
                    amount: totalBalance,
                    icon: Icons.account_balance_wallet,
                    iconColor: AppColors.primary,
                  ),

                  const SizedBox(height: 12),

                  // Income vs Expense
                  Row(
                    children: [
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Income',
                          amount: totalIncome,
                          icon: Icons.arrow_downward,
                          iconColor: AppColors.income,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SummaryCard(
                          title: 'Total Expense',
                          amount: totalExpense,
                          icon: Icons.arrow_upward,
                          iconColor: AppColors.expense,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Recent Transactions Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      TextButton.icon(
                        onPressed: () => QuickAddBottomSheet.show(context, effectiveUser),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Quick Add'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (expenseSnapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (expenses.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 10),
                          Text(
                            'No transactions recorded yet.\nTap "Quick Add" to add your first expense or income.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  else
                    ...expenses.map((item) {
                      final isExpense = item.type == ExpenseType.expense;
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red.shade400,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => firestoreService.deleteExpense(item.id),
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: (isExpense ? AppColors.expense : AppColors.income)
                                  .withValues(alpha: 0.15),
                              child: Icon(
                                isExpense ? Icons.arrow_upward : Icons.arrow_downward,
                                color: isExpense ? AppColors.expense : AppColors.income,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${item.category} • ${dateFormat.format(item.date)}'
                              '${item.userName != null ? ' • by ${item.userName}' : ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Text(
                              '${isExpense ? '-' : '+'}${currencyFormat.format(item.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isExpense ? AppColors.expense : AppColors.income,
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
