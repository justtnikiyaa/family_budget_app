import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import 'custom_button.dart';
import 'custom_text_field.dart';

class QuickAddBottomSheet extends StatefulWidget {
  final UserModel currentUser;

  const QuickAddBottomSheet({super.key, required this.currentUser});

  static Future<void> show(BuildContext context, UserModel currentUser) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickAddBottomSheet(currentUser: currentUser),
    );
  }

  @override
  State<QuickAddBottomSheet> createState() => _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends State<QuickAddBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _firestoreService = FirestoreService();

  ExpenseType _selectedType = ExpenseType.expense;
  String _selectedCategory = AppConstants.expenseCategories.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) return;

    setState(() => _isLoading = true);

    try {
      final newExpense = ExpenseModel(
        id: '',
        title: _titleController.text.trim(),
        amount: amount,
        type: _selectedType,
        category: _selectedCategory,
        date: DateTime.now(),
        userId: widget.currentUser.uid,
        userName: widget.currentUser.displayName,
        familyId: widget.currentUser.familyId,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      );

      await _firestoreService.addExpense(newExpense);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding transaction: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == ExpenseType.expense
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;

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
      child: Form(
        key: _formKey,
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
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Quick Add Transaction',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 16),
              // Segmented type selector
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Expense')),
                      selected: _selectedType == ExpenseType.expense,
                      selectedColor: AppColors.expense.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: _selectedType == ExpenseType.expense
                            ? AppColors.expense
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedType = ExpenseType.expense;
                            _selectedCategory = AppConstants.expenseCategories.first;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Income')),
                      selected: _selectedType == ExpenseType.income,
                      selectedColor: AppColors.income.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: _selectedType == ExpenseType.income
                            ? AppColors.income
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedType = ExpenseType.income;
                            _selectedCategory = AppConstants.incomeCategories.first;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _titleController,
                label: 'Title / Description',
                prefixIcon: Icons.description_outlined,
                validator: (val) => val != null && val.isNotEmpty ? null : 'Enter a title',
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _amountController,
                label: 'Amount (Rs / \$)',
                prefixIcon: Icons.attach_money,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) =>
                    val != null && double.tryParse(val) != null && double.parse(val) > 0
                        ? null
                        : 'Enter a valid amount',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _noteController,
                label: 'Note (Optional)',
                prefixIcon: Icons.notes_outlined,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Save Transaction',
                isLoading: _isLoading,
                backgroundColor: _selectedType == ExpenseType.expense
                    ? AppColors.expense
                    : AppColors.income,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
