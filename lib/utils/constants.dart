import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C5CE7);
  static const Color secondary = Color(0xFFA29BFE);
  static const Color accent = Color(0xFF00CEC9);
  static const Color background = Color(0xFFF8F9FE);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color expense = Color(0xFFFF7675);
  static const Color income = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF0984E3);
  static const Color cardShadow = Color(0x0D000000);
}

class AppConstants {
  static const String appName = 'Family Budget';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String familiesCollection = 'families';
  static const String expensesCollection = 'expenses';
  static const String limitsCollection = 'limits';
  static const String billsCollection = 'bills';
  static const String goalsCollection = 'goals';

  // Default Categories
  static const List<String> expenseCategories = [
    'Food & Dining',
    'Groceries',
    'Transportation',
    'Utilities & Bills',
    'Healthcare',
    'Education',
    'Entertainment',
    'Shopping',
    'Housing & Rent',
    'Other'
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Business',
    'Freelance',
    'Investments',
    'Gift',
    'Other'
  ];
}
