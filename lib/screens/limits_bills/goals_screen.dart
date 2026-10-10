import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/goal_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class GoalsScreen extends StatefulWidget {
  final UserModel? currentUser;

  const GoalsScreen({super.key, this.currentUser});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // Seed goals matching prototype screenshot if Firestore collection is fresh
  final List<GoalModel> _defaultSharedGoals = [
    GoalModel(
      id: 'default_shared_1',
      title: 'HOUSE DEPOSIT',
      category: 'PRIORITY',
      targetAmount: 200000,
      savedAmount: 150000,
      targetDate: DateTime(2027, 12, 31),
      isShared: true,
    ),
    GoalModel(
      id: 'default_shared_2',
      title: 'KIDS COLLEGE',
      category: 'EDUCATION',
      targetAmount: 200000,
      savedAmount: 150000,
      targetDate: DateTime(2028, 6, 30),
      isShared: true,
    ),
  ];

  final List<GoalModel> _defaultPersonalGoals = [
    GoalModel(
      id: 'default_personal_1',
      title: 'NEW LAPTOP',
      category: 'TECH & GEAR',
      targetAmount: 200000,
      savedAmount: 150000,
      targetDate: DateTime(2026, 11, 30),
      isShared: false,
    ),
  ];

  void _showAddGoalDialog({required bool isShared}) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final categoryController =
        TextEditingController(text: isShared ? 'PRIORITY' : 'TECH & GEAR');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isShared ? 'Add Shared Goal' : 'Add Personal Goal',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Goal Title (e.g. House Deposit)',
                prefixIcon: Icon(Icons.flag_outlined, color: Color(0xFF10B981)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category (e.g. PRIORITY, EDUCATION)',
                prefixIcon: Icon(Icons.category_outlined, color: Color(0xFF10B981)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: targetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Target Amount (Rs)',
                prefixIcon: Icon(Icons.attach_money, color: Color(0xFF10B981)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final title = titleController.text.trim();
              final cat = categoryController.text.trim().toUpperCase();
              final target = double.tryParse(targetController.text.trim()) ?? 0.0;

              if (title.isNotEmpty && target > 0) {
                await _firestoreService.addGoal(
                  GoalModel(
                    id: '',
                    title: title.toUpperCase(),
                    category: cat.isNotEmpty ? cat : (isShared ? 'SHARED' : 'PERSONAL'),
                    targetAmount: target,
                    savedAmount: 0.0,
                    targetDate: DateTime.now().add(const Duration(days: 180)),
                    familyId: isShared ? widget.currentUser?.familyId : null,
                    isShared: isShared,
                  ),
                );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Save Goal', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddSavingsDialog(GoalModel goal) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Contribute to ${goal.title}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Deposit Amount (Rs)',
            prefixIcon: Icon(Icons.savings_outlined, color: Color(0xFF10B981)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
              if (amt > 0) {
                if (goal.id.startsWith('default_')) {
                  setState(() {
                    final target = goal.isShared
                        ? _defaultSharedGoals.firstWhere((g) => g.id == goal.id)
                        : _defaultPersonalGoals.firstWhere((g) => g.id == goal.id);
                    target.toMap(); // update in-memory
                  });
                } else {
                  await _firestoreService.addSavingsToGoal(goal.id, amt);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Contribute', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    final currencyFormat = NumberFormat('#,###');
    final ratio = goal.targetAmount > 0
        ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final percentage = (ratio * 100).toInt();

    return GestureDetector(
      onTap: () => _showAddSavingsDialog(goal),
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
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goal.category.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF0D9488),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    goal.isShared ? Icons.groups_rounded : Icons.person_rounded,
                    color: const Color(0xFF10B981),
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              goal.title.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: ratio,
                backgroundColor: const Color(0xFFF1F5F9),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Rs. ${currencyFormat.format(goal.savedAmount.toInt())}',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      TextSpan(
                        text: ' / Rs. ${currencyFormat.format(goal.targetAmount.toInt())}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F7ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedAddButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF10B981),
            width: 1.2,
            style: BorderStyle.solid,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF059669),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
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
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ),
        title: const Text(
          'GOAL TRACKER',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: StreamBuilder<List<GoalModel>>(
        stream: _firestoreService.getGoals(familyId: widget.currentUser?.familyId),
        builder: (context, snapshot) {
          final firestoreGoals = snapshot.data ?? [];
          final sharedGoals = firestoreGoals.where((g) => g.isShared).toList();
          final personalGoals = firestoreGoals.where((g) => !g.isShared).toList();

          final effectiveShared =
              sharedGoals.isNotEmpty ? sharedGoals : _defaultSharedGoals;
          final effectivePersonal =
              personalGoals.isNotEmpty ? personalGoals : _defaultPersonalGoals;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              // 1. Family Shared Goals Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                      SizedBox(width: 8),
                      Text(
                        'FAMILY SHARED GOALS',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${effectiveShared.length} Active',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Shared goals cards
              ...effectiveShared.map(_buildGoalCard),
              const SizedBox(height: 6),

              // Add Shared Goal Button
              _buildDashedAddButton(
                label: 'ADD SHARED GOAL',
                onTap: () => _showAddGoalDialog(isShared: true),
              ),
              const SizedBox(height: 24),

              // 2. My Personal Goals Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
                      SizedBox(width: 8),
                      Text(
                        'MY PERSONAL GOALS',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${effectivePersonal.length} Active',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Personal goals cards
              ...effectivePersonal.map(_buildGoalCard),
              const SizedBox(height: 6),

              // Add Personal Goal Button
              _buildDashedAddButton(
                label: 'ADD PERSONAL GOAL',
                onTap: () => _showAddGoalDialog(isShared: false),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}
