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
  final String? assignedTo;
  final String? notifyFrequency;
  final bool sendReminder;

  BillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    this.category = 'Utility',
    this.familyId,
    this.notes,
    this.assignedTo = 'Shared Household',
    this.notifyFrequency = '1 day before (9:00 AM)',
    this.sendReminder = true,
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
      'assignedTo': assignedTo,
      'notifyFrequency': notifyFrequency,
      'sendReminder': sendReminder,
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
      category: data['category'] ?? 'Utility',
      familyId: data['familyId'],
      notes: data['notes'],
      assignedTo: data['assignedTo'] ?? 'Shared Household',
      notifyFrequency: data['notifyFrequency'] ?? '1 day before (9:00 AM)',
      sendReminder: data['sendReminder'] ?? true,
    );
  }
}
