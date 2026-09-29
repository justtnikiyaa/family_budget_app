import 'package:cloud_firestore/cloud_firestore.dart';

class LimitModel {
  final String id;
  final String category;
  final double limitAmount;
  final double spentAmount;
  final String monthYear; // e.g., '2026-09'
  final String? familyId;

  LimitModel({
    required this.id,
    required this.category,
    required this.limitAmount,
    this.spentAmount = 0.0,
    required this.monthYear,
    this.familyId,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limitAmount': limitAmount,
      'spentAmount': spentAmount,
      'monthYear': monthYear,
      'familyId': familyId,
    };
  }

  factory LimitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LimitModel(
      id: doc.id,
      category: data['category'] ?? '',
      limitAmount: (data['limitAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: (data['spentAmount'] as num?)?.toDouble() ?? 0.0,
      monthYear: data['monthYear'] ?? '',
      familyId: data['familyId'],
    );
  }
}
