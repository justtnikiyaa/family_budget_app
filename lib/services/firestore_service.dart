import 'dart:async';
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
    String? customInviteCode,
    String? adminDisplayName,
  }) async {
    final inviteCode = (customInviteCode != null && customInviteCode.trim().isNotEmpty)
        ? customInviteCode.trim().toUpperCase()
        : _generateInviteCode();
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

    // Update user's familyId and role (and displayName if updated)
    final userUpdates = <String, dynamic>{
      'uid': currentUser.uid,
      'email': currentUser.email,
      'familyId': familyDoc.id,
      'role': 'admin',
    };
    if (adminDisplayName != null && adminDisplayName.trim().isNotEmpty) {
      userUpdates['displayName'] = adminDisplayName.trim();
    } else if (currentUser.displayName.isNotEmpty) {
      userUpdates['displayName'] = currentUser.displayName;
    }

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(currentUser.uid)
        .set(userUpdates, SetOptions(merge: true));

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
          .set({
        'uid': currentUser.uid,
        'email': currentUser.email,
        'familyId': family.id,
        'role': 'member',
      }, SetOptions(merge: true));
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

  Stream<List<ExpenseModel>> getIncomes({String? familyId, String? userId}) {
    Query query = _firestore.collection(AppConstants.incomesCollection);

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

  Stream<List<ExpenseModel>> getAllTransactions({String? familyId, String? userId}) {
    late StreamController<List<ExpenseModel>> controller;
    StreamSubscription? expensesSub;
    StreamSubscription? incomesSub;
    List<ExpenseModel> expensesList = [];
    List<ExpenseModel> incomesList = [];

    void emitCombined() {
      if (!controller.isClosed) {
        final Map<String, ExpenseModel> map = {};
        for (final item in expensesList) {
          map[item.id] = item;
        }
        for (final item in incomesList) {
          map[item.id] = item;
        }
        final combined = map.values.toList();
        combined.sort((a, b) => b.date.compareTo(a.date));
        controller.add(combined);
      }
    }

    controller = StreamController<List<ExpenseModel>>.broadcast(
      onListen: () {
        expensesSub = getExpenses(familyId: familyId, userId: userId).listen(
          (data) {
            expensesList = data;
            emitCombined();
          },
          onError: (err) {
            if (!controller.isClosed) controller.addError(err);
          },
        );

        incomesSub = getIncomes(familyId: familyId, userId: userId).listen(
          (data) {
            incomesList = data;
            emitCombined();
          },
          onError: (_) {
            emitCombined();
          },
        );
      },
      onCancel: () {
        expensesSub?.cancel();
        incomesSub?.cancel();
      },
    );

    return controller.stream;
  }

  Future<void> addExpense(ExpenseModel expense) async {
    await _firestore.collection(AppConstants.expensesCollection).add(expense.toMap());
    if (expense.type == ExpenseType.expense) {
      final monthYear = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      await updateLimitSpentForCategory(
        category: expense.category,
        amount: expense.amount,
        monthYear: monthYear,
        familyId: expense.familyId,
      );
    }
  }

  Future<void> addIncome(ExpenseModel income) async {
    await _firestore.collection(AppConstants.incomesCollection).add(income.toMap());
  }

  Future<void> migrateLegacyIncomes() async {
    try {
      final snap = await _firestore
          .collection(AppConstants.expensesCollection)
          .where('type', isEqualTo: 'income')
          .get();
      for (final doc in snap.docs) {
        await _firestore
            .collection(AppConstants.incomesCollection)
            .doc(doc.id)
            .set(doc.data());
        await doc.reference.delete();
      }
    } catch (_) {}
  }

  Future<void> updateLimitSpentForCategory({
    required String category,
    required double amount,
    required String monthYear,
    String? familyId,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.limitsCollection)
          .where('monthYear', isEqualTo: monthYear);
      if (familyId != null && familyId.isNotEmpty) {
        query = query.where('familyId', isEqualTo: familyId);
      }
      final snapshot = await query.get();
      for (final doc in snapshot.docs) {
        final limit = LimitModel.fromFirestore(doc);
        final a = limit.category.trim().toLowerCase();
        final b = category.trim().toLowerCase();
        final bool isMatch = a == b ||
            a.contains(b) ||
            b.contains(a) ||
            (a.contains('fuel') && (b.contains('petrol') || b.contains('diesel') || b.contains('gas') || b.contains('transport'))) ||
            (b.contains('fuel') && (a.contains('petrol') || a.contains('diesel') || a.contains('gas') || a.contains('transport')));
        if (isMatch) {
          final newSpent = limit.spentAmount + amount;
          await doc.reference.update({'spentAmount': newSpent});
        }
      }
    } catch (_) {}
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

  Future<void> deleteLimit(String limitId) async {
    await _firestore.collection(AppConstants.limitsCollection).doc(limitId).delete();
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
