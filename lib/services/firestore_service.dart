import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill_model.dart';
import '../models/expense_model.dart';
import '../models/family_model.dart';
import '../models/goal_model.dart';
import '../models/limit_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===================== FAMILY OPERATIONS =====================

  // Generate 6-character random alphanumeric code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<FamilyModel> createFamily({
    required String familyName,
    required UserModel currentUser,
  }) async {
    final inviteCode = _generateInviteCode();
    final familyDoc = _firestore.collection(AppConstants.familiesCollection).doc();

    final family = FamilyModel(
      id: familyDoc.id,
      name: familyName,
      inviteCode: inviteCode,
      adminId: currentUser.uid,
      memberIds: [currentUser.uid],
      createdAt: DateTime.now(),
    );

    await familyDoc.set(family.toMap());

    // Update user's familyId and role
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(currentUser.uid)
        .update({
      'familyId': familyDoc.id,
      'role': 'admin',
    });

    return family;
  }

  Future<FamilyModel?> joinFamily({
    required String inviteCode,
    required UserModel currentUser,
  }) async {
    final cleanCode = inviteCode.trim().toUpperCase();
    final query = await _firestore
        .collection(AppConstants.householdsCollection)
        .where('inviteCode', isEqualTo: cleanCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid invitation code. Household not found.');
    }

    final doc = query.docs.first;
    final family = FamilyModel.fromFirestore(doc);

    if (!family.memberIds.contains(currentUser.uid)) {
      await doc.reference.update({
        'members': FieldValue.arrayUnion([currentUser.uid]),
        'memberIds': FieldValue.arrayUnion([currentUser.uid]),
      });

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUser.uid)
          .update({
        'familyId': family.id,
        'role': 'member',
      });
    }

    return family;
  }

  Stream<FamilyModel?> getFamilyStream(String familyId) {
    if (familyId.isEmpty) return Stream.value(null);
    return _firestore
        .collection(AppConstants.familiesCollection)
        .doc(familyId)
        .snapshots()
        .map((doc) => doc.exists ? FamilyModel.fromFirestore(doc) : null);
  }

  Stream<List<UserModel>> getFamilyMembers(List<String> memberIds) {
    if (memberIds.isEmpty) return Stream.value([]);
    return _firestore
        .collection(AppConstants.usersCollection)
        .where(FieldPath.documentId, whereIn: memberIds.take(10).toList())
        .snapshots()
        .map((s) => s.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  // ===================== EXPENSES / INCOMES =====================

  Stream<List<ExpenseModel>> getExpenses({String? familyId, String? userId}) {
    Query query = _firestore.collection(AppConstants.expensesCollection);

    if (familyId != null && familyId.isNotEmpty) {
      query = query.where('familyId', isEqualTo: familyId);
    } else if (userId != null && userId.isNotEmpty) {
      query = query.where('userId', isEqualTo: userId);
    }

    return query.snapshots().map((snapshot) {
      final list =
          snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore.collection(AppConstants.expensesCollection).add(expense.toMap());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection(AppConstants.expensesCollection).doc(expenseId).delete();
  }

  // ===================== CATEGORY LIMITS =====================

  Stream<List<LimitModel>> getLimits({required String monthYear, String? familyId}) {
    Query query = _firestore
        .collection(AppConstants.limitsCollection)
        .where('monthYear', isEqualTo: monthYear);

    if (familyId != null && familyId.isNotEmpty) {
      query = query.where('familyId', isEqualTo: familyId);
    }

    return query.snapshots().map(
          (s) => s.docs.map((d) => LimitModel.fromFirestore(d)).toList(),
        );
  }

  Future<void> setLimit(LimitModel limit) async {
    final docRef = limit.id.isNotEmpty
        ? _firestore.collection(AppConstants.limitsCollection).doc(limit.id)
        : _firestore.collection(AppConstants.limitsCollection).doc();

    await docRef.set(limit.toMap(), SetOptions(merge: true));
  }

  // ===================== BILLS & REMINDERS =====================

  Stream<List<BillModel>> getBills({String? familyId}) {
    Query query = _firestore.collection(AppConstants.billsCollection);
    if (familyId != null && familyId.isNotEmpty) {
      query = query.where('familyId', isEqualTo: familyId);
    }
    return query.snapshots().map((s) {
      final list = s.docs.map((d) => BillModel.fromFirestore(d)).toList();
      list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      return list;
    });
  }

  Future<void> addBill(BillModel bill) async {
    await _firestore.collection(AppConstants.billsCollection).add(bill.toMap());
  }

  Future<void> updateBillStatus(String billId, bool isPaid) async {
    await _firestore
        .collection(AppConstants.billsCollection)
        .doc(billId)
        .update({'isPaid': isPaid});
  }

  Future<void> deleteBill(String billId) async {
    await _firestore.collection(AppConstants.billsCollection).doc(billId).delete();
  }

  // ===================== GOALS =====================

  Stream<List<GoalModel>> getGoals({String? familyId}) {
    Query query = _firestore.collection(AppConstants.goalsCollection);
    if (familyId != null && familyId.isNotEmpty) {
      query = query.where('familyId', isEqualTo: familyId);
    }
    return query.snapshots().map(
          (s) => s.docs.map((d) => GoalModel.fromFirestore(d)).toList(),
        );
  }

  Future<void> addGoal(GoalModel goal) async {
    await _firestore.collection(AppConstants.goalsCollection).add(goal.toMap());
  }

  Future<void> addSavingsToGoal(String goalId, double addAmount) async {
    await _firestore.collection(AppConstants.goalsCollection).doc(goalId).update({
      'savedAmount': FieldValue.increment(addAmount),
    });
  }

  Future<void> deleteGoal(String goalId) async {
    await _firestore.collection(AppConstants.goalsCollection).doc(goalId).delete();
  }
}
