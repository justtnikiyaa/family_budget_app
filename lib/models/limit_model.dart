import 'package:cloud_firestore/cloud_firestore.dart';

class LimitModel {
  final String id;
  final String category;
  final double limitAmount;
  final double spentAmount;
  final String monthYear; // e.g., '2026-09'
  final String? familyId;
  final double warningThreshold;
  final bool notifyHousehold;

  LimitModel({
    required this.id,
    required this.category,
    required this.limitAmount,
    this.spentAmount = 0.0,
    required this.monthYear,
    this.familyId,
    this.warningThreshold = 0.80,
    this.notifyHousehold = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limitAmount': limitAmount,
      'spentAmount': spentAmount,
      'monthYear': monthYear,
      'familyId': familyId,
      'warningThreshold': warningThreshold,
      'notifyHousehold': notifyHousehold,
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
      warningThreshold: (data['warningThreshold'] as num?)?.toDouble() ?? 0.80,
      notifyHousehold: data['notifyHousehold'] ?? true,
    );
  }
}
