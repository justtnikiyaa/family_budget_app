import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;
  final String? familyId;
  final String? iconName;

  GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0.0,
    required this.targetDate,
    this.familyId,
    this.iconName = 'savings',
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': Timestamp.fromDate(targetDate),
      'familyId': familyId,
      'iconName': iconName,
    };
  }

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return GoalModel(
      id: doc.id,
      title: data['title'] ?? '',
      targetAmount: (data['targetAmount'] as num?)?.toDouble() ?? 0.0,
      savedAmount: (data['savedAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: (data['targetDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      familyId: data['familyId'],
      iconName: data['iconName'] ?? 'savings',
    );
  }
}
