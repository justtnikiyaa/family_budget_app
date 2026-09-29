import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpenseType { income, expense }

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final ExpenseType type;
  final String category;
  final DateTime date;
  final String userId;
  final String? familyId;
  final String? userName;
  final String? note;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.userId,
    this.familyId,
    this.userName,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type.name,
      'category': category,
      'date': Timestamp.fromDate(date),
      'userId': userId,
      'familyId': familyId,
      'userName': userName,
      'note': note,
    };
  }

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ExpenseModel(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      type: data['type'] == 'income' ? ExpenseType.income : ExpenseType.expense,
      category: data['category'] ?? 'General',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
      familyId: data['familyId'],
      userName: data['userName'],
      note: data['note'],
    );
  }
}
