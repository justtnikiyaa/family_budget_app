import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/bill_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import 'add_bill_screen.dart';

class BillsScreen extends StatefulWidget {
  final UserModel? currentUser;
  final VoidCallback? onBackToOverview;

  const BillsScreen({super.key, this.currentUser, this.onBackToOverview});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isDueThisWeekExpanded = true;
  bool _isDueLaterExpanded = false;
  bool _isPaidExpanded = false;

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Utility':
        return Icons.receipt_long_outlined;
      case 'Banking':
        return Icons.credit_card_outlined;
      case 'Internet':
        return Icons.wifi_rounded;
      case 'Rent':
        return Icons.home_work_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  void _openAddBillScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddBillScreen(currentUser: widget.currentUser),
      ),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  void _showBillActions(BillModel bill) {
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
                  Expanded(
                    child: Text(
                      bill.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: bill.isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bill.isPaid ? 'PAID' : 'DUE',
                      style: TextStyle(
                        color: bill.isPaid ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Rs. ${NumberFormat('#,##0.00').format(bill.amount)} • Due ${DateFormat('MMM dd, yyyy').format(bill.dueDate)}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              if (!bill.isPaid)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                  label: const Text('Mark as Paid / Settled', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _firestoreService.updateBillStatus(bill.id, true);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${bill.title} marked as paid!'), backgroundColor: const Color(0xFF059669)),
                      );
                    }
                  },
                )
              else
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: Color(0xFF059669)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.undo_rounded, color: Color(0xFF059669)),
                  label: const Text('Mark as Unpaid', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _firestoreService.updateBillStatus(bill.id, false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${bill.title} marked as unpaid.')),
                      );
                    }
                  },
                ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                label: const Text('Delete Bill', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _firestoreService.deleteBill(bill.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${bill.title} deleted.')),
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BillModel>>(
      stream: _firestoreService.getBills(familyId: widget.currentUser?.familyId),
      builder: (context, snapshot) {
        final firestoreBills = snapshot.data ?? [];

        final now = DateTime.now();
        final oneWeekLater = now.add(const Duration(days: 7));

        final dueThisWeekList = firestoreBills.where((b) {
          return !b.isPaid && b.dueDate.isBefore(oneWeekLater);
        }).toList();

        final dueLaterList = firestoreBills.where((b) {
          return !b.isPaid && !b.dueDate.isBefore(oneWeekLater);
        }).toList();

        final paidList = firestoreBills.where((b) => b.isPaid).toList();

        double totalToPay = 0.0;
        for (final bill in firestoreBills) {
          if (!bill.isPaid) {
            totalToPay += bill.amount;
          }
        }

        final currencyFormat = NumberFormat('#,##0.00');

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
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    } else if (widget.onBackToOverview != null) {
                      widget.onBackToOverview!();
                    }
                  },
                ),
              ),
            ),
            title: const Text(
              'BILLS',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 0.8,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddNewBillButton(),
                const SizedBox(height: 24),

                if (firestoreBills.isEmpty && snapshot.connectionState != ConnectionState.waiting)
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.info_outline_rounded, color: Color(0xFF059669)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No bills scheduled yet. Tap "+ ADD NEW BILL" above to add WiFi, Electricity, or Rent reminders.',
                            style: TextStyle(color: Color(0xFF166534), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                _buildDueThisWeekCard(dueThisWeekList),
                const SizedBox(height: 14),

                _buildDueLaterCard(dueLaterList),
                const SizedBox(height: 14),

                _buildPaidCard(paidList),
                const SizedBox(height: 90),
              ],
            ),
          ),
          bottomSheet: _buildBottomSummaryBar(totalToPay, currencyFormat),
        );
      },
    );
  }

  Widget _buildAddNewBillButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _openAddBillScreen,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF28795A),
          elevation: 2,
          shadowColor: const Color(0xFF0D9488).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'ADD NEW BILL',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueThisWeekCard(List<BillModel> bills) {
    final count = bills.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF86EFAC).withValues(alpha: 0.7),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                _isDueThisWeekExpanded = !_isDueThisWeekExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    'DUE THIS WEEK ($count)',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isDueThisWeekExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isDueThisWeekExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            if (bills.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Center(
                  child: Text(
                    'No bills due this week.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: bills.length,
                separatorBuilder: (_, i) =>
                    const Divider(color: Color(0xFFF1F5F9), height: 24, thickness: 1),
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return _buildBillItemRow(bill);
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDueLaterCard(List<BillModel> bills) {
    final count = bills.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                _isDueLaterExpanded = !_isDueLaterExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    'DUE LATER ($count)',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Next week',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isDueLaterExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isDueLaterExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            if (bills.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Center(
                  child: Text(
                    'No upcoming bills scheduled for later.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: bills.length,
                separatorBuilder: (_, i) =>
                    const Divider(color: Color(0xFFF1F5F9), height: 24, thickness: 1),
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return _buildBillItemRow(bill);
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaidCard(List<BillModel> bills) {
    final count = bills.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() {
                _isPaidExpanded = !_isPaidExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Text(
                    'PAID ($count)',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check, color: Color(0xFF059669), size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Settled',
                          style: TextStyle(
                            color: Color(0xFF059669),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPaidExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isPaidExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            if (bills.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Center(
                  child: Text(
                    'No settled bills yet.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: bills.length,
                separatorBuilder: (_, i) =>
                    const Divider(color: Color(0xFFF1F5F9), height: 24, thickness: 1),
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return Opacity(
                    opacity: 0.75,
                    child: _buildBillItemRow(bill),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillItemRow(BillModel bill) {
    final currencyFormat = NumberFormat('#,###');
    final amountText = currencyFormat.format(bill.amount);
    final categoryText = (bill.category ?? 'UTILITY').toUpperCase();

    final isTomorrow = bill.notes?.toLowerCase().contains('tomorrow') == true ||
        (bill.dueDate.day == DateTime.now().add(const Duration(days: 1)).day &&
            bill.dueDate.month == DateTime.now().month);

    return InkWell(
      onTap: () => _showBillActions(bill),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bill.isPaid ? const Color(0xFFF1F5F9) : const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getCategoryIcon(bill.category),
                color: bill.isPaid ? const Color(0xFF64748B) : const Color(0xFF059669),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bill.title,
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: bill.isPaid ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 5),
                  if (bill.isPaid)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Settled',
                        style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    )
                  else if (isTomorrow)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, color: Color(0xFFF59E0B), size: 6),
                          const SizedBox(width: 5),
                          Text(
                            bill.notes ?? 'Due Tomorrow',
                            style: const TextStyle(
                              color: Color(0xFFB45309),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      bill.notes ?? 'Due ${DateFormat('MMM dd').format(bill.dueDate)}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs. $amountText',
                  style: TextStyle(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: bill.isPaid ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  categoryText,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSummaryBar(double total, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TOTAL TO PAY THIS MONTH:',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'Rs. ${format.format(total)}',
              style: const TextStyle(
                color: Color(0xFF047857),
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
