import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/limit_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class SetBudgetLimitScreen extends StatefulWidget {
  final UserModel? currentUser;

  const SetBudgetLimitScreen({super.key, this.currentUser});

  @override
  State<SetBudgetLimitScreen> createState() => _SetBudgetLimitScreenState();
}

class _SetBudgetLimitScreenState extends State<SetBudgetLimitScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  double _limitAmount = 45000.0;
  String _selectedCategory = 'Groceries & Supermarket';
  late final TextEditingController _categoryController;
  double _warningThreshold = 80.0;
  bool _notifyHousehold = true;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Groceries & Supermarket',
      'shortName': 'Groceries',
      'icon': Icons.shopping_cart_outlined,
      'color': const Color(0xFF0D9488),
    },
    {
      'name': 'Food & Dining',
      'shortName': 'Food & Dining',
      'icon': Icons.restaurant_outlined,
      'color': const Color(0xFFF97316),
    },
    {
      'name': 'Fuel / Transport',
      'shortName': 'Fuel / Transport',
      'icon': Icons.local_gas_station_outlined,
      'color': const Color(0xFF0284C7),
    },
    {
      'name': 'Utility Bills',
      'shortName': 'Utilities',
      'icon': Icons.bolt_outlined,
      'color': const Color(0xFFEAB308),
    },
    {
      'name': 'Entertainment',
      'shortName': 'Entertainment',
      'icon': Icons.movie_filter_outlined,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'name': 'Health & Medical',
      'shortName': 'Health',
      'icon': Icons.medical_services_outlined,
      'color': const Color(0xFFEF4444),
    },
    {
      'name': 'Shopping & Lifestyle',
      'shortName': 'Shopping',
      'icon': Icons.shopping_bag_outlined,
      'color': const Color(0xFFEC4899),
    },
  ];

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: 'Fuel');
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _addAmount(double addVal) {
    setState(() {
      _limitAmount += addVal;
    });
  }

  void _resetAmount() {
    setState(() {
      _limitAmount = 45000.0;
    });
  }

  void _editAmountDirectly() {
    final controller = TextEditingController(text: _limitAmount.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Enter Monthly Limit', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: 'Rs. ',
            labelText: 'Limit Amount',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              if (parsed != null && parsed >= 0) {
                setState(() => _limitAmount = parsed);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Set Amount', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _getCurrentCategoryIcon() {
    final found = _categories.firstWhere(
      (c) => c['name'] == _selectedCategory || c['shortName'] == _selectedCategory,
      orElse: () => {
        'icon': Icons.category_outlined,
      },
    );
    return found['icon'] as IconData;
  }

  Future<void> _saveCategoryLimit() async {
    final cat = _categoryController.text.trim().isNotEmpty
        ? _categoryController.text.trim()
        : _selectedCategory;

    if (_limitAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid monthly limit amount')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      await _firestoreService.setLimit(
        LimitModel(
          id: '',
          category: cat,
          limitAmount: _limitAmount,
          spentAmount: 0.0,
          monthYear: currentMonth,
          familyId: widget.currentUser?.familyId,
          warningThreshold: _warningThreshold / 100.0,
          notifyHousehold: _notifyHousehold,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Budget limit for $cat saved successfully!'),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save limit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final formattedAmount = currencyFormatter.format(_limitAmount.toInt());
    final thresholdAmount = currencyFormatter.format((_limitAmount * (_warningThreshold / 100.0)).toInt());

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
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          children: [
            const Text(
              'SET BUDGET LIMIT',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Expense Cap',
                style: TextStyle(
                  color: Color(0xFF059669),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: IconButton(
                icon: const Icon(Icons.settings_outlined, size: 20, color: Color(0xFF0F172A)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Budget Limit Settings')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // ================= 1. DARK TEAL MONTHLY LIMIT CARD =================
            _buildMonthlyLimitCard(formattedAmount),
            const SizedBox(height: 18),

            // ================= 2. ADD LIMIT SECTION CARD =================
            _buildAddLimitSectionCard(),
            const SizedBox(height: 18),

            // ================= 3. OVERSPEND WARNING THRESHOLD CARD =================
            _buildOverspendWarningCard(thresholdAmount),
            const SizedBox(height: 100), // spacing for bottom sticky button
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomStickyButton(),
    );
  }

  // ================= 1. MONTHLY LIMIT CARD =================
  Widget _buildMonthlyLimitCard(String formattedAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF092925), Color(0xFF0E3831), Color(0xFF07211D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF092925).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF10B981),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'ENTER MONTHLY\nLIMIT',
                    style: TextStyle(
                      color: Color(0xFF6EE7B7),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              // Category Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF031E1B).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF115E59)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getCurrentCategoryIcon(), size: 13, color: const Color(0xFF5EEAD4)),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(
                        _selectedCategory,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Amount display row
          GestureDetector(
            onTap: _editAmountDirectly,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  'Rs. ',
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formattedAmount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const Text(
                  '.00',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                // Blinking cursor visual
                Container(
                  width: 2,
                  height: 28,
                  color: const Color(0xFF2DD4BF),
                ),
                const Spacer(),
                // LKR badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF042F2C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF059669), width: 0.8),
                  ),
                  child: const Text(
                    'LKR',
                    style: TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Quick Increment Chips
          Row(
            children: [
              _buildQuickPill('+2,500', () => _addAmount(2500), isHighlighted: false),
              const SizedBox(width: 8),
              _buildQuickPill('+5,000', () => _addAmount(5000), isHighlighted: true),
              const SizedBox(width: 8),
              _buildQuickPill('+10,000', () => _addAmount(10000), isHighlighted: false),
              const SizedBox(width: 8),
              _buildResetPill(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPill(String text, VoidCallback onTap, {required bool isHighlighted}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isHighlighted ? const Color(0xFF0E5B51) : const Color(0xFF0A2B27),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHighlighted ? const Color(0xFF14B8A6) : const Color(0xFF134E48),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: isHighlighted ? const Color(0xFF2DD4BF) : const Color(0xFFE2E8F0),
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetPill() {
    return Expanded(
      child: InkWell(
        onTap: _resetAmount,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2E121E),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF831843),
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.refresh_rounded, size: 12, color: Color(0xFFF43F5E)),
              SizedBox(width: 3),
              Text(
                'Reset',
                style: TextStyle(
                  color: Color(0xFFF43F5E),
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= 2. ADD LIMIT SECTION CARD =================
  Widget _buildAddLimitSectionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'ADD LIMIT',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'Swipe for more',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Selected Category Box (editable or dynamic display)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(
                  _getCurrentCategoryIcon(),
                  color: const Color(0xFF475569),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'Enter category name',
                    ),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Horizontal Category Chips List
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat['name'] ||
                    _selectedCategory == cat['shortName'] ||
                    _categoryController.text == cat['shortName'] ||
                    _categoryController.text == cat['name'];

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['name'] as String;
                      _categoryController.text = cat['shortName'] as String;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          cat['icon'] as IconData,
                          size: 15,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat['shortName'] as String,
                          style: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= 3. OVERSPEND WARNING THRESHOLD CARD =================
  Widget _buildOverspendWarningCard(String thresholdAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'OVERSPEND WARNING THRESHOLD',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              // Warning percentage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Text(
                  '${_warningThreshold.toInt()}%',
                  style: const TextStyle(
                    color: Color(0xFFD97706),
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Send notification when spending reaches this limit',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 14),

          // Custom styled slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 6,
              activeTrackColor: const Color(0xFF10B981),
              inactiveTrackColor: const Color(0xFFF1F5F9),
              thumbColor: const Color(0xFFF59E0B),
              overlayColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 9,
                elevation: 3,
              ),
            ),
            child: Slider(
              value: _warningThreshold,
              min: 70.0,
              max: 100.0,
              divisions: 30,
              onChanged: (val) {
                setState(() => _warningThreshold = val);
              },
            ),
          ),

          // Slider mark labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '70%',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFDE68A), width: 0.8),
                  ),
                  child: const Text(
                    '80% (Warning)',
                    style: TextStyle(
                      color: Color(0xFFD97706),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  '90% (Critical)',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '100%',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Alert trigger callout box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      text: 'Alert triggers when family spending reaches ',
                      style: const TextStyle(
                        color: Color(0xFF92400E),
                        fontSize: 12,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text: 'Rs. $thresholdAmount',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Color(0xFF78350F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Toggle: Notify All Household Earners
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFF059669),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Notify All Household Earners',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Instant push notification & SMS alerts',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _notifyHousehold,
                onChanged: (val) {
                  setState(() => _notifyHousehold = val);
                },
                activeThumbColor: const Color(0xFF059669),
                activeTrackColor: const Color(0xFFD1FAE5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= 4. BOTTOM STICKY BUTTON =================
  Widget _buildBottomStickyButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _saveCategoryLimit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
            label: Text(
              _isLoading ? 'SAVING...' : 'SAVE CATEGORY LIMIT',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
