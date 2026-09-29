import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyModel {
  final String id;
  final String name;
  final String inviteCode;
  final String adminId;
  final List<String> memberIds;
  final DateTime createdAt;

  FamilyModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.adminId,
    required this.memberIds,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'inviteCode': inviteCode,
      'adminId': adminId,
      'members': memberIds,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory FamilyModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawMembers = data['members'] ?? data['memberIds'] ?? [];
    return FamilyModel(
      id: doc.id,
      name: data['name'] ?? '',
      inviteCode: data['inviteCode'] ?? '',
      adminId: data['adminId'] ?? '',
      memberIds: List<String>.from(rawMembers),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
