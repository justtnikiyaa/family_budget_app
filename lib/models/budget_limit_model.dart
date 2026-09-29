import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetLimitModel {
  final String id;
  final String category;
  final double limitAmount;
  final double spentAmount;
  final String monthYear; // e.g. '2026-09'

  BudgetLimitModel({
    required this.id,
    required this.category,
    required this.limitAmount,
    this.spentAmount = 0.0,
    required this.monthYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limitAmount': limitAmount,
      'spentAmount': spentAmount,
      'monthYear': monthYear,
    };
  }

  factory BudgetLimitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BudgetLimitModel(
      id: doc.id,
      category: data['category'] ?? '',
      limitAmount: (data['limitAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (data['spentAmount'] as num?)?.toDouble() ?? 0.0,
      monthYear: data['monthYear'] ?? '',
    );
  }
}

class BillModel {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String? notes;

  BillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
      'notes': notes,
    };
  }

  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BillModel(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPaid: data['isPaid'] ?? false,
      notes: data['notes'],
    );
  }
}
