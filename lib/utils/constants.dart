import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette from Figma/UI Design
  static const Color primary = Color(0xFF0F766E); // Deep Emerald Green
  static const Color primaryDark = Color(0xFF065F46); // Dark Forest
  static const Color secondary = Color(0xFF14B8A6); // Emerald Teal
  static const Color accent = Color(0xFF0D9488);
  static const Color background = Color(0xFFF8FAFC); // Slate background
  static const Color surface = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Dark Slate
  static const Color textSecondary = Color(0xFF64748B); // Slate Muted
  static const Color textTertiary = Color(0xFF94A3B8);

  // Status & Transaction Colors
  static const Color expense = Color(0xFFEF4444);
  static const Color income = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Design Accents & Badges
  static const Color badgeLavender = Color(0xFFEEF2FF);
  static const Color badgeLavenderText = Color(0xFF4F46E5);
  static const Color badgeMint = Color(0xFFCCFBF1);
  static const Color badgeMintText = Color(0xFF0F766E);
  static const Color cardSelectedBg = Color(0xFFE6F4F1);
  static const Color cardShadow = Color(0x0A0F766E);
}

class AppConstants {
  static const String appName = 'Smart Family Budget';
  static const String countryBadge = 'Sri Lanka 🇱🇰';

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

enum AppLanguage { sinhala, english, tamil }

class LanguageItem {
  final AppLanguage code;
  final String title;
  final String subtitle;
  final String greeting;

  const LanguageItem({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.greeting,
  });
}

class AppLanguages {
  static const List<LanguageItem> list = [
    LanguageItem(
      code: AppLanguage.sinhala,
      title: 'සිංහල (Sinhala)',
      subtitle: 'Default local language',
      greeting: 'ආයුබෝවන්',
    ),
    LanguageItem(
      code: AppLanguage.english,
      title: 'English (Global)',
      subtitle: 'Default international format',
      greeting: 'Hello',
    ),
    LanguageItem(
      code: AppLanguage.tamil,
      title: 'தமிழ் (Tamil)',
      subtitle: 'இලங்கை தமிழ்',
      greeting: 'வணக்கம்',
    ),
  ];
}
