import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_model.dart';
import '../../models/limit_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_strings.dart';
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

  bool _isCategoryMatch(String expenseCategory, String limitCategory) {
    final eCat = expenseCategory.toLowerCase().trim();
    final lCat = limitCategory.toLowerCase().trim();
    if (eCat == lCat) return true;
    if (lCat.contains(eCat) || eCat.contains(lCat)) return true;

    // Fuel and transport
    final fuelKeywords = ['fuel', 'petrol', 'diesel', 'gas', 'transport', 'vehicle'];
    if (fuelKeywords.any((k) => lCat.contains(k)) && fuelKeywords.any((k) => eCat.contains(k))) {
      return true;
    }

    // Food & Dining
    final foodKeywords = ['food', 'dining', 'restaurant', 'lunch', 'dinner', 'coffee', 'cafe'];
    if (foodKeywords.any((k) => lCat.contains(k)) && foodKeywords.any((k) => eCat.contains(k))) {
      return true;
    }

    // Groceries
    final groceryKeywords = ['grocer', 'supermarket', 'market', 'provisions'];
    if (groceryKeywords.any((k) => lCat.contains(k)) && groceryKeywords.any((k) => eCat.contains(k))) {
      return true;
    }

    // Utilities / Bills
    final billKeywords = ['bill', 'util', 'electric', 'water', 'internet', 'wifi'];
    if (billKeywords.any((k) => lCat.contains(k)) && billKeywords.any((k) => eCat.contains(k))) {
      return true;
    }

    return false;
  }

  void _showAddExpenseForLimitSheet(BuildContext context, LimitModel limit, double currentSpent) {
    final remaining = (limit.limitAmount - currentSpent).clamp(0.0, double.infinity);
    final isFuel = limit.category.toLowerCase().contains('fuel') || limit.category.toLowerCase().contains('transport');
    final quickAmounts = isFuel ? [1000, 2000, 5000, 10000] : [500, 1000, 2500, 5000];
    final currencyFormat = NumberFormat('#,###');

    final amountController = TextEditingController();
    final noteController = TextEditingController(text: isFuel ? 'Fuel' : '');
    bool isShared = widget.currentUser?.familyId != null;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final enteredAmount = double.tryParse(amountController.text.trim()) ?? 0.0;
          final projectedSpent = currentSpent + enteredAmount;
          final willCloseLimit = projectedSpent >= limit.limitAmount && limit.limitAmount > 0;
          final projectedRatio = limit.limitAmount > 0
              ? (projectedSpent / limit.limitAmount).clamp(0.0, 1.0)
              : 0.0;

          return Container(
            padding: EdgeInsets.only(
              top: 16,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(limit.category),
                          color: const Color(0xFF0F766E),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppStrings.addExpense}: ${AppStrings.getCategoryName(limit.category)}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Limit: Rs. ${currencyFormat.format(limit.limitAmount.toInt())} • Remaining: Rs. ${currencyFormat.format(remaining.toInt())}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Hero amount container
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0B1922), Color(0xFF162834)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.expenseAmount,
                              style: const TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'LKR / Rs.',
                                style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            const Text(
                              'Rs. ',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: amountController,
                                cursorColor: const Color(0xFF10B981),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                autofocus: true,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                                onChanged: (_) => setSheetState(() {}),
                                decoration: const InputDecoration(
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: '0',
                                  hintStyle: TextStyle(color: Colors.white38, fontSize: 32, fontWeight: FontWeight.bold),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: quickAmounts.map((amt) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  onTap: () {
                                    final current = double.tryParse(amountController.text.trim()) ?? 0.0;
                                    amountController.text = (current + amt).toInt().toString();
                                    setSheetState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                    ),
                                    child: Text(
                                      '+Rs. ${NumberFormat.compact().format(amt)}',
                                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Real-time limit impact preview
                  if (enteredAmount > 0)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: willCloseLimit ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: willCloseLimit ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                willCloseLimit ? Icons.lock_rounded : Icons.trending_up_rounded,
                                size: 16,
                                color: willCloseLimit ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  willCloseLimit
                                      ? '⚠️ Limit will CLOSE (100% Reached: Rs. ${currencyFormat.format(projectedSpent.toInt())} / ${currencyFormat.format(limit.limitAmount.toInt())})'
                                      : 'Limit status: ${(projectedRatio * 100).toInt()}% used • Rs. ${currencyFormat.format((limit.limitAmount - projectedSpent).clamp(0, double.infinity).toInt())} remaining',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: willCloseLimit ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: projectedRatio,
                              backgroundColor: Colors.black.withValues(alpha: 0.06),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                willCloseLimit ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),

                  // Note input
                  Text(
                    AppStrings.noteDescription,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.6),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: noteController,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        hintText: isFuel ? 'e.g. Petrol Octane 95, Lanka IOC, Auto Diesel' : 'e.g. Grocery items, Store name',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF0F766E), size: 22),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Save button
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final nav = Navigator.of(ctx);
                            final messenger = ScaffoldMessenger.of(context);
                            final amt = double.tryParse(amountController.text.trim()) ?? 0.0;
                            if (amt <= 0) {
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Please enter a valid expense amount')),
                              );
                              return;
                            }

                            setSheetState(() => isSaving = true);
                            try {
                              final newExpense = ExpenseModel(
                                id: '',
                                title: noteController.text.trim().isNotEmpty
                                    ? noteController.text.trim()
                                    : '${limit.category} Expense',
                                amount: amt,
                                type: ExpenseType.expense,
                                category: limit.category,
                                date: DateTime.now(),
                                userId: widget.currentUser?.uid ?? '',
                                userName: widget.currentUser?.displayName,
                                familyId: limit.familyId ?? (isShared ? widget.currentUser?.familyId : null),
                                note: noteController.text.trim().isNotEmpty ? noteController.text.trim() : null,
                              );

                              await _firestoreService.addExpense(newExpense);

                              final updatedLimit = LimitModel(
                                id: limit.id,
                                category: limit.category,
                                limitAmount: limit.limitAmount,
                                spentAmount: currentSpent + amt,
                                monthYear: limit.monthYear,
                                familyId: limit.familyId,
                                warningThreshold: limit.warningThreshold,
                                notifyHousehold: limit.notifyHousehold,
                              );
                              await _firestoreService.setLimit(updatedLimit);

                              if (mounted) {
                                nav.pop();
                                final isNowClosed = (currentSpent + amt) >= limit.limitAmount;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isNowClosed
                                          ? 'Rs. ${currencyFormat.format(amt.toInt())} added to ${limit.category}! Limit has CLOSED (100% reached).'
                                          : 'Rs. ${currencyFormat.format(amt.toInt())} added to ${limit.category}!',
                                    ),
                                    backgroundColor: isNowClosed ? const Color(0xFFDC2626) : const Color(0xFF0F766E),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Failed to add expense: $e')),
                                );
                              }
                            } finally {
                              setSheetState(() => isSaving = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: willCloseLimit ? const Color(0xFFDC2626) : const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            willCloseLimit
                                ? 'RECORD EXPENSE & CLOSE LIMIT'
                                : 'RECORD ${limit.category.toUpperCase()} EXPENSE',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, letterSpacing: 0.5),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLimitActions(
    LimitModel limit,
    double spent,
    double ratio,
    List<ExpenseModel> matchingExpenses,
  ) {
    final currencyFormat = NumberFormat('#,###');
    final remaining = (limit.limitAmount - spent).clamp(0.0, double.infinity);
    final isClosed = spent >= limit.limitAmount && limit.limitAmount > 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getCategoryIcon(limit.category), color: const Color(0xFF0F766E), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        limit.category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isClosed
                          ? const Color(0xFFFEE2E2)
                          : (ratio >= 0.8 ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isClosed ? 'CLOSED (100% CAPPED)' : '${(ratio * 100).toInt()}% Used',
                      style: TextStyle(
                        color: isClosed
                            ? const Color(0xFFDC2626)
                            : (ratio >= 0.8 ? const Color(0xFFD97706) : const Color(0xFF16A34A)),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Summary Stats Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Budget Limit:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        Text('Rs. ${currencyFormat.format(limit.limitAmount.toInt())}',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Spent this month:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        Text('Rs. ${currencyFormat.format(spent.toInt())}',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isClosed ? const Color(0xFFDC2626) : const Color(0xFF0F172A))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Remaining:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        Text(
                          isClosed
                              ? (spent > limit.limitAmount ? 'Exceeded by Rs. ${currencyFormat.format((spent - limit.limitAmount).toInt())}' : 'Rs. 0 (Limit Reached)')
                              : 'Rs. ${currencyFormat.format(remaining.toInt())}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isClosed ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Button 1: Add Expense for this limit
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: Text('${AppStrings.addExpense}: ${AppStrings.getCategoryName(limit.category)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showAddExpenseForLimitSheet(context, limit, spent);
                },
              ),
              const SizedBox(height: 10),

              // Recent Matching Expenses
              if (matchingExpenses.isNotEmpty) ...[
                const SizedBox(height: 6),
                const Text(
                  'RECENT EXPENSES UNDER THIS LIMIT',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.6),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 140),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: matchingExpenses.take(3).length,
                    separatorBuilder: (_, _) => const Divider(height: 12, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, idx) {
                      final exp = matchingExpenses[idx];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exp.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(exp.date),
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '-Rs. ${currencyFormat.format(exp.amount.toInt())}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFEF4444)),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Delete button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
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
          title: Text(
            AppStrings.limits,
            style: const TextStyle(
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
                  final List<ExpenseModel> matchingExpenses = [];
                  for (final e in allExpenses) {
                    final expMonth = DateFormat('yyyy-MM').format(e.date);
                    if (e.type == ExpenseType.expense &&
                        expMonth == limit.monthYear &&
                        _isCategoryMatch(e.category, limit.category)) {
                      spent += e.amount;
                      matchingExpenses.add(e);
                    }
                  }
                  if (spent == 0.0 && limit.spentAmount > 0) {
                    spent = limit.spentAmount;
                  }

                  final double ratio = limit.limitAmount > 0
                      ? (spent / limit.limitAmount).clamp(0.0, 1.0)
                      : 0.0;
                  final bool isClosed = spent >= limit.limitAmount && limit.limitAmount > 0;
                  final double remaining = (limit.limitAmount - spent).clamp(0.0, double.infinity);

                  calculatedLimits.add({
                    'model': limit,
                    'category': limit.category,
                    'spent': spent,
                    'limit': limit.limitAmount,
                    'ratio': ratio,
                    'isClosed': isClosed,
                    'remaining': remaining,
                    'expenses': matchingExpenses,
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
                      children: [
                        const Icon(Icons.circle, color: Color(0xFFF59E0B), size: 8),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.atRiskCategories,
                          style: const TextStyle(
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
                              child: GestureDetector(
                                onTap: () => _showAddExpenseForLimitSheet(
                                  context,
                                  atRiskLimits.first['model'] as LimitModel,
                                  atRiskLimits.first['spent'] as double,
                                ),
                                child: _buildAtRiskDarkCard(atRiskLimits.first),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Card 2: 2nd At-Risk if exists, else Light Status Card
                            Expanded(
                              child: atRiskLimits.length > 1
                                  ? GestureDetector(
                                      onTap: () => _showAddExpenseForLimitSheet(
                                        context,
                                        atRiskLimits[1]['model'] as LimitModel,
                                        atRiskLimits[1]['spent'] as double,
                                      ),
                                      child: _buildAtRiskLightCard(atRiskLimits[1]),
                                    )
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
                          children: [
                            Text(
                              AppStrings.allBudgets,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.circle, color: Color(0xFF10B981), size: 7),
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
                        final bool isClosed = b['isClosed'] as bool;
                        final double remaining = b['remaining'] as double;
                        final List<ExpenseModel> expenses = b['expenses'] as List<ExpenseModel>;

                        return InkWell(
                          onTap: () => _showLimitActions(model, spent, ratio, expenses),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isClosed
                                    ? const Color(0xFFFECACA)
                                    : (ratio >= 0.8 ? const Color(0xFFFED7AA) : const Color(0xFFF1F5F9)),
                                width: isClosed ? 1.5 : 1.0,
                              ),
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
                                        color: isClosed
                                            ? const Color(0xFFFEE2E2)
                                            : (ratio >= 0.8 ? const Color(0xFFFEF3C7) : const Color(0xFFE6F4EA)),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(model.category),
                                        color: isClosed
                                            ? const Color(0xFFDC2626)
                                            : (ratio >= 0.8 ? const Color(0xFFD97706) : const Color(0xFF059669)),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  AppStrings.getCategoryName(model.category),
                                                  style: const TextStyle(
                                                    color: Color(0xFF0F172A),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Status Badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                                decoration: BoxDecoration(
                                                  color: isClosed
                                                      ? const Color(0xFFFEE2E2)
                                                      : (ratio >= 0.8 ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7)),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (isClosed)
                                                      const Padding(
                                                        padding: EdgeInsets.only(right: 3),
                                                        child: Icon(Icons.lock_rounded, size: 10, color: Color(0xFFDC2626)),
                                                      ),
                                                    Text(
                                                      isClosed
                                                          ? AppStrings.closed
                                                          : (ratio >= 0.8 ? AppStrings.atRisk : '${(ratio * 100).toInt()}%'),
                                                      style: TextStyle(
                                                        color: isClosed
                                                            ? const Color(0xFFDC2626)
                                                            : (ratio >= 0.8 ? const Color(0xFFD97706) : const Color(0xFF16A34A)),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            isClosed
                                                ? (spent > limit
                                                    ? 'Exceeded by Rs. ${(spent - limit).toInt()}'
                                                    : AppStrings.limitCapped)
                                                : 'Rs. ${remaining.toInt()} ${AppStrings.remaining}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: isClosed ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Direct "+ Expense" action button on card
                                    GestureDetector(
                                      onTap: () => _showAddExpenseForLimitSheet(context, model, spent),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: isClosed
                                              ? const Color(0xFFF8FAFC)
                                              : const Color(0xFF0F766E).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isClosed
                                                ? const Color(0xFFE2E8F0)
                                                : const Color(0xFF0F766E).withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.add_circle_outline_rounded,
                                              size: 14,
                                              color: isClosed ? const Color(0xFF64748B) : const Color(0xFF0F766E),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Expense',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w700,
                                                color: isClosed ? const Color(0xFF64748B) : const Color(0xFF0F766E),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    backgroundColor: const Color(0xFFF1F5F9),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isClosed
                                          ? const Color(0xFFDC2626)
                                          : (ratio >= 0.8 ? const Color(0xFFF59E0B) : const Color(0xFF10B981)),
                                    ),
                                    minHeight: 7,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Rs. ${spent.toInt()} ${AppStrings.spent}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isClosed ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      '${AppStrings.limit}: Rs. ${limit.toInt()}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
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
