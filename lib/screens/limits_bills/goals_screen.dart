import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/goal_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_text_field.dart';

class GoalsScreen extends StatelessWidget {
  final UserModel? currentUser;

  const GoalsScreen({super.key, this.currentUser});

  void _showAddGoalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    DateTime targetDate = DateTime.now().add(const Duration(days: 90));
    final firestoreService = FirestoreService();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Savings Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: titleController,
                  label: 'Goal Name (e.g. Family Vacation)',
                  prefixIcon: Icons.flag_outlined,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: targetController,
                  label: 'Target Amount (Rs)',
                  prefixIcon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Target Date'),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(targetDate)),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: targetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) {
                      setDialogState(() => targetDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final target = double.tryParse(targetController.text.trim()) ?? 0.0;

                if (title.isNotEmpty && target > 0) {
                  await firestoreService.addGoal(
                    GoalModel(
                      id: '',
                      title: title,
                      targetAmount: target,
                      savedAmount: 0.0,
                      targetDate: targetDate,
                      familyId: currentUser?.familyId,
                    ),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Create Goal'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFundsDialog(BuildContext context, GoalModel goal) {
    final amountController = TextEditingController();
    final firestoreService = FirestoreService();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Savings to "${goal.title}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: amountController,
              label: 'Deposit Amount (Rs)',
              prefixIcon: Icons.savings_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
              if (amount > 0) {
                await firestoreService.addSavingsToGoal(goal.id, amount);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Add Funds'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final currencyFormat = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 2);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Goal', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<List<GoalModel>>(
        stream: firestoreService.getGoals(familyId: currentUser?.familyId),
        builder: (context, snapshot) {
          final goals = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No savings goals set yet.\nPlan a goal like Emergency Fund, Education, or Trip!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final progress = goal.targetAmount > 0
                  ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0)
                  : 0.0;
              final percent = (progress * 100).toInt();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                                child: const Icon(Icons.savings, color: AppColors.accent),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                goal.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                            onPressed: () => firestoreService.deleteGoal(goal.id),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Saved: ${currencyFormat.format(goal.savedAmount)}',
                            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.income),
                          ),
                          Text(
                            'Target: ${currencyFormat.format(goal.targetAmount)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('$percent% reached', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text('Target: ${dateFormat.format(goal.targetDate)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => _showAddFundsDialog(context, goal),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Deposit Savings'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.accent),
                            foregroundColor: AppColors.accent,
                          ),
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
    );
  }
}
