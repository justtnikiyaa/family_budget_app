import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import 'custom_numeric_keypad.dart';

/// Quick Add Expense Bottom Sheet with Custom Keypad
/// Implementation by Amarasinghe A.L.O.A
class QuickAddKeypadALOA extends StatefulWidget {
  final UserModel currentUser;

  const QuickAddKeypadALOA({super.key, required this.currentUser});

  static Future<void> show(BuildContext context, UserModel currentUser) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddKeypadALOA(currentUser: currentUser),
    );
  }

  @override
  State<QuickAddKeypadALOA> createState() => _QuickAddKeypadALOAState();
}

class _QuickAddKeypadALOAState extends State<QuickAddKeypadALOA> {
  final _noteController = TextEditingController();
  final _firestoreService = FirestoreService();

  String _amountDisplay = '0';
  String _selectedCategory = AppConstants.expenseCategories.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _onNumberTap(String number) {
    setState(() {
      if (_amountDisplay == '0' && number != '.') {
        _amountDisplay = number;
      } else if (number == '.') {
        if (!_amountDisplay.contains('.')) {
          _amountDisplay += number;
        }
      } else {
        // Limit to 2 decimal places
        if (_amountDisplay.contains('.')) {
          final parts = _amountDisplay.split('.');
          if (parts[1].length < 2) {
            _amountDisplay += number;
          }
        } else {
          _amountDisplay += number;
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amountDisplay.length > 1) {
        _amountDisplay = _amountDisplay.substring(0, _amountDisplay.length - 1);
      } else {
        _amountDisplay = '0';
      }
    });
  }

  void _onClear() {
    setState(() {
      _amountDisplay = '0';
    });
  }

  Future<void> _handleSave() async {
    final amount = double.tryParse(_amountDisplay) ?? 0.0;
    
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newExpense = ExpenseModel(
        id: '',
        title: _selectedCategory,
        amount: amount,
        type: ExpenseType.expense,
        category: _selectedCategory,
        date: DateTime.now(),
        userId: widget.currentUser.uid,
        userName: widget.currentUser.displayName,
        familyId: widget.currentUser.familyId,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      );

      await _firestoreService.addExpense(newExpense);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully'),
            backgroundColor: AppColors.income,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding expense: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              'Quick Add Expense',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 20),

            // Amount Display
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rs ',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                  ),
                  Text(
                    _amountDisplay,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 40,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Selection
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  items: AppConstants.expenseCategories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                const Icon(Icons.category_outlined, 
                                    size: 20, color: AppColors.primary),
                                const SizedBox(width: 12),
                                Text(category),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Note Field
            TextFormField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Note (Optional)',
                hintText: 'Add a note about this expense',
                prefixIcon: const Icon(Icons.notes_outlined),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Custom Numeric Keypad
            CustomNumericKeypad(
              onNumberTap: _onNumberTap,
              onBackspace: _onBackspace,
              onClear: _onClear,
            ),
            const SizedBox(height: 20),

            // Save Button
            CustomButton(
              text: 'Save Expense',
              isLoading: _isLoading,
              backgroundColor: AppColors.primaryDark,
              onPressed: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
