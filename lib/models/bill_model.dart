import 'package:cloud_firestore/cloud_firestore.dart';

class BillModel {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String? category;
  final String? familyId;
  final String? notes;

  BillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    this.category = 'Utilities',
    this.familyId,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
      'category': category,
      'familyId': familyId,
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
      category: data['category'] ?? 'Utilities',
      familyId: data['familyId'],
      notes: data['notes'],
    );
  }
}
