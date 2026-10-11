import '../main.dart';
import 'constants.dart';

class AppStrings {
  static AppLanguage get currentLanguage => appSettings.appLanguage;

  static bool get isSinhala => currentLanguage == AppLanguage.sinhala;
  static bool get isTamil => currentLanguage == AppLanguage.tamil;
  static bool get isEnglish => currentLanguage == AppLanguage.english;

  // Translation lookup helper
  static String tr(String key) {
    final entry = _translations[key];
    if (entry == null) return key;
    return entry[currentLanguage] ?? entry[AppLanguage.english] ?? key;
  }

  // App Identity & Navigation
  static String get appName => tr('appName');
  static String get appTagline => tr('appTagline');
  static String get overview => tr('overview');
  static String get bills => tr('bills');
  static String get reports => tr('reports');
  static String get preferences => tr('preferences');
  static String get add => tr('add');

  // Common Actions
  static String get continueBtn => tr('continue');
  static String get save => tr('save');
  static String get cancel => tr('cancel');
  static String get delete => tr('delete');
  static String get edit => tr('edit');
  static String get viewAll => tr('viewAll');
  static String get search => tr('search');

  // Auth & Onboarding
  static String get chooseLanguage => tr('chooseLanguage');
  static String get languageSubtitle => tr('languageSubtitle');
  static String get welcomeBack => tr('welcomeBack');
  static String get signInSubtitle => tr('signInSubtitle');
  static String get signIn => tr('signIn');
  static String get signUp => tr('signUp');
  static String get email => tr('email');
  static String get password => tr('password');
  static String get forgotPassword => tr('forgotPassword');
  static String get dontHaveAccount => tr('dontHaveAccount');
  static String get alreadyHaveAccount => tr('alreadyHaveAccount');
  static String get continueWithGoogle => tr('continueWithGoogle');
  static String get joinFamily => tr('joinFamily');
  static String get createFamily => tr('createFamily');

  // Dashboard & Finances
  static String get available => tr('available');
  static String get familySharedVault => tr('familySharedVault');
  static String get totalSpent => tr('totalSpent');
  static String get spendingDistribution => tr('spendingDistribution');
  static String get familyBreakdown => tr('familyBreakdown');
  static String get monthlyCaps => tr('monthlyCaps');
  static String get recentActivities => tr('recentActivities');
  static String get noTransactions => tr('noTransactions');
  static String get category => tr('category');
  static String get member => tr('member');
  static String get limits => tr('limits');
  static String get goals => tr('goals');
  static String get income => tr('income');
  static String get addIncome => tr('addIncome');
  static String get addExpense => tr('addExpense');
  static String get daysLeft => tr('daysLeft');

  // Limits & Budgets
  static String get limitsAndBudgets => tr('limitsAndBudgets');
  static String get atRiskCategories => tr('atRiskCategories');
  static String get allBudgets => tr('allBudgets');
  static String get setBudgetLimit => tr('setBudgetLimit');
  static String get closed => tr('closed');
  static String get atRisk => tr('atRisk');
  static String get healthy => tr('healthy');
  static String get remaining => tr('remaining');
  static String get spent => tr('spent');
  static String get limit => tr('limit');
  static String get limitCapped => tr('limitCapped');
  static String get expenseAmount => tr('expenseAmount');
  static String get noteDescription => tr('noteDescription');

  // Bills & Goals
  static String get dueSoon => tr('dueSoon');
  static String get paid => tr('paid');
  static String get unpaid => tr('unpaid');
  static String get addBill => tr('addBill');
  static String get savingsGoals => tr('savingsGoals');
  static String get addGoal => tr('addGoal');
  static String get target => tr('target');
  static String get saved => tr('saved');

  // Profile & Settings
  static String get profileAndHousehold => tr('profileAndHousehold');
  static String get settings => tr('settings');
  static String get language => tr('language');
  static String get chooseLanguagePref => tr('chooseLanguagePref');
  static String get fontSize => tr('fontSize');
  static String get adjustTextSize => tr('adjustTextSize');
  static String get householdMembers => tr('householdMembers');
  static String get inviteMember => tr('inviteMember');
  static String get logout => tr('logout');

  // Category Names helper
  static String getCategoryName(String rawCategory) {
    final cat = rawCategory.trim().toLowerCase();
    if (cat.contains('fuel') || cat.contains('petrol') || cat.contains('diesel')) {
      return tr('catFuel');
    } else if (cat.contains('grocer')) {
      return tr('catGroceries');
    } else if (cat.contains('transport')) {
      return tr('catTransport');
    } else if (cat.contains('din') || cat.contains('food') || cat.contains('lunch') || cat.contains('coffee')) {
      return tr('catDining');
    } else if (cat.contains('bill') || cat.contains('utilit')) {
      return tr('catBills');
    } else if (cat.contains('shop')) {
      return tr('catShopping');
    } else if (cat.contains('health') || cat.contains('med')) {
      return tr('catHealth');
    } else if (cat.contains('educ')) {
      return tr('catEducation');
    } else if (cat.contains('entert')) {
      return tr('catEntertainment');
    } else if (cat.contains('gift')) {
      return tr('catGift');
    } else if (cat.contains('sal')) {
      return tr('catSalary');
    } else if (cat.contains('busin')) {
      return tr('catBusiness');
    } else if (cat.contains('invest')) {
      return tr('catInvestment');
    }
    return rawCategory;
  }

  // Master translation dictionary
  static final Map<String, Map<AppLanguage, String>> _translations = {
    // Identity
    'appName': {
      AppLanguage.english: 'Smart Family Budget',
      AppLanguage.sinhala: 'Smart Family Budget',
      AppLanguage.tamil: 'Smart Family Budget',
    },
    'appTagline': {
      AppLanguage.english: 'SHARED HOUSEHOLD FINANCES',
      AppLanguage.sinhala: 'පවුලේ පොදු මූල්‍ය කළමනාකරණය',
      AppLanguage.tamil: 'பகிரப்பட்ட குடும்ப நிதி',
    },
    'overview': {
      AppLanguage.english: 'Overview',
      AppLanguage.sinhala: 'දළ විශ්ලේෂණය',
      AppLanguage.tamil: 'மேலோட்டம்',
    },
    'bills': {
      AppLanguage.english: 'Bills',
      AppLanguage.sinhala: 'බිල්පත්',
      AppLanguage.tamil: 'கட்டணங்கள்',
    },
    'reports': {
      AppLanguage.english: 'Reports',
      AppLanguage.sinhala: 'වාර්තා',
      AppLanguage.tamil: 'அறிக்கைகள்',
    },
    'preferences': {
      AppLanguage.english: 'Preferences',
      AppLanguage.sinhala: 'සැකසුම්',
      AppLanguage.tamil: 'அமைப்புகள்',
    },
    'add': {
      AppLanguage.english: 'Add',
      AppLanguage.sinhala: 'එකතු කරන්න',
      AppLanguage.tamil: 'சேர்க்க',
    },

    // Actions
    'continue': {
      AppLanguage.english: 'Continue',
      AppLanguage.sinhala: 'ඉදිරියට යන්න',
      AppLanguage.tamil: 'தொடரவும்',
    },
    'save': {
      AppLanguage.english: 'Save',
      AppLanguage.sinhala: 'සුරකින්න',
      AppLanguage.tamil: 'சேமிக்க',
    },
    'cancel': {
      AppLanguage.english: 'Cancel',
      AppLanguage.sinhala: 'අවලංගු කරන්න',
      AppLanguage.tamil: 'ரத்து செய்',
    },
    'delete': {
      AppLanguage.english: 'Delete',
      AppLanguage.sinhala: 'මකන්න',
      AppLanguage.tamil: 'நீக்கு',
    },
    'edit': {
      AppLanguage.english: 'Edit',
      AppLanguage.sinhala: 'වෙනස් කරන්න',
      AppLanguage.tamil: 'திருத்துக',
    },
    'viewAll': {
      AppLanguage.english: 'View All',
      AppLanguage.sinhala: 'සියල්ල බලන්න',
      AppLanguage.tamil: 'அனைத்தையும் பார்க்க',
    },
    'search': {
      AppLanguage.english: 'Search',
      AppLanguage.sinhala: 'සොයන්න',
      AppLanguage.tamil: 'தேடுக',
    },

    // Auth & Onboarding
    'chooseLanguage': {
      AppLanguage.english: 'Choose Language',
      AppLanguage.sinhala: 'භාෂාව තෝරන්න',
      AppLanguage.tamil: 'மொழியைத் தேர்ந்தெடுக்கவும்',
    },
    'languageSubtitle': {
      AppLanguage.english: 'Select your preferred language for the app',
      AppLanguage.sinhala: 'යෙදුම සඳහා ඔබ කැමති භාෂාව තෝරාගන්න',
      AppLanguage.tamil: 'செயலிக்கு உங்கள் விருப்ப மொழியைத் தேர்ந்தெடுக்கவும்',
    },
    'welcomeBack': {
      AppLanguage.english: 'Welcome Back',
      AppLanguage.sinhala: 'නැවත සාදරයෙන් පිළිගනිමු',
      AppLanguage.tamil: 'மீண்டும் வருக',
    },
    'signInSubtitle': {
      AppLanguage.english: 'Sign in to manage your family budget',
      AppLanguage.sinhala: 'ඔබගේ පවුලේ අයවැය කළමනාකරණයට ඇතුල් වන්න',
      AppLanguage.tamil: 'உங்கள் குடும்ப பட்ஜெட்டை நிர்வகிக்க உள்நுழைக',
    },
    'signIn': {
      AppLanguage.english: 'Sign In',
      AppLanguage.sinhala: 'ඇතුල් වන්න',
      AppLanguage.tamil: 'உள்நுழைக',
    },
    'signUp': {
      AppLanguage.english: 'Sign Up',
      AppLanguage.sinhala: 'ලියාපදිංචි වන්න',
      AppLanguage.tamil: 'பதிவு செய்க',
    },
    'email': {
      AppLanguage.english: 'Email Address',
      AppLanguage.sinhala: 'විද්‍යුත් තැපෑල',
      AppLanguage.tamil: 'மின்னஞ்சல் முகவரி',
    },
    'password': {
      AppLanguage.english: 'Password',
      AppLanguage.sinhala: 'මුරපදය',
      AppLanguage.tamil: 'கடவுச்சொல்',
    },
    'forgotPassword': {
      AppLanguage.english: 'Forgot Password?',
      AppLanguage.sinhala: 'මුරපදය අමතකද?',
      AppLanguage.tamil: 'கடவுச்சொல் மறந்துவிட்டதா?',
    },
    'dontHaveAccount': {
      AppLanguage.english: "Don't have an account? Sign Up",
      AppLanguage.sinhala: 'ගිණුමක් නැද්ද? ලියාපදිංචි වන්න',
      AppLanguage.tamil: 'கணக்கு இல்லையா? பதிவு செய்க',
    },
    'alreadyHaveAccount': {
      AppLanguage.english: 'Already have an account? Sign In',
      AppLanguage.sinhala: 'දැනටමත් ගිණුමක් තිබේද? ඇතුල් වන්න',
      AppLanguage.tamil: 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழைக',
    },
    'continueWithGoogle': {
      AppLanguage.english: 'Continue with Google',
      AppLanguage.sinhala: 'Google මඟින් ඉදිරියට යන්න',
      AppLanguage.tamil: 'Google மூலம் தொடரவும்',
    },
    'joinFamily': {
      AppLanguage.english: 'Join Family',
      AppLanguage.sinhala: 'පවුලකට එකතු වන්න',
      AppLanguage.tamil: 'குடும்பத்தில் இணையுங்கள்',
    },
    'createFamily': {
      AppLanguage.english: 'Create Household',
      AppLanguage.sinhala: 'නව පවුලක් සාදන්න',
      AppLanguage.tamil: 'புதிய குடும்பத்தை உருவாக்குங்கள்',
    },

    // Finances & Dashboard
    'available': {
      AppLanguage.english: 'AVAILABLE',
      AppLanguage.sinhala: 'ඉතිරි ශේෂය (AVAILABLE)',
      AppLanguage.tamil: 'கிடைக்கக்கூடியது (AVAILABLE)',
    },
    'familySharedVault': {
      AppLanguage.english: 'Family Shared Vault',
      AppLanguage.sinhala: 'පවුලේ පොදු අරමුදල',
      AppLanguage.tamil: 'குடும்ப பகிர்வு நிதி',
    },
    'totalSpent': {
      AppLanguage.english: 'Total Spent',
      AppLanguage.sinhala: 'මුළු වියදම',
      AppLanguage.tamil: 'மொத்த செலவு',
    },
    'spendingDistribution': {
      AppLanguage.english: 'SPENDING DISTRIBUTION',
      AppLanguage.sinhala: 'වියදම් බෙදීයාම',
      AppLanguage.tamil: 'செலவு விநியோகம்',
    },
    'familyBreakdown': {
      AppLanguage.english: 'FAMILY BREAKDOWN',
      AppLanguage.sinhala: 'සාමාජිකයින්ගේ වියදම්',
      AppLanguage.tamil: 'குடும்ப உறுப்பினர்கள் செலவு',
    },
    'monthlyCaps': {
      AppLanguage.english: 'Monthly Caps',
      AppLanguage.sinhala: 'මාසික සීමාවන්',
      AppLanguage.tamil: 'மாதாந்திர வரம்புகள்',
    },
    'recentActivities': {
      AppLanguage.english: 'Recent Activity',
      AppLanguage.sinhala: 'මෑත ගනුදෙනු',
      AppLanguage.tamil: 'சமீபத்திய நடவடிக்கைகள்',
    },
    'noTransactions': {
      AppLanguage.english: 'No transactions yet',
      AppLanguage.sinhala: 'තවමත් ගනුදෙනු නැත',
      AppLanguage.tamil: 'இன்னும் பரிவர்த்தனைகள் இல்லை',
    },
    'category': {
      AppLanguage.english: 'CATEGORY',
      AppLanguage.sinhala: 'වර්ගය අනුව',
      AppLanguage.tamil: 'வகை வாரியாக',
    },
    'member': {
      AppLanguage.english: 'MEMBER',
      AppLanguage.sinhala: 'සාමාජිකයා අනුව',
      AppLanguage.tamil: 'உறுப்பினர் வாரியாக',
    },
    'limits': {
      AppLanguage.english: 'Limits',
      AppLanguage.sinhala: 'සීමාවන්',
      AppLanguage.tamil: 'வரம்புகள்',
    },
    'goals': {
      AppLanguage.english: 'Goals',
      AppLanguage.sinhala: 'ඉලක්ක',
      AppLanguage.tamil: 'இலக்குகள்',
    },
    'income': {
      AppLanguage.english: 'Income',
      AppLanguage.sinhala: 'ආදායම්',
      AppLanguage.tamil: 'வருமானம்',
    },
    'addIncome': {
      AppLanguage.english: 'Add Income',
      AppLanguage.sinhala: 'ආදායමක් එක් කරන්න',
      AppLanguage.tamil: 'வருமானம் சேர்க்கவும்',
    },
    'addExpense': {
      AppLanguage.english: 'Add Expense',
      AppLanguage.sinhala: 'වියදමක් එක් කරන්න',
      AppLanguage.tamil: 'செலவு சேர்க்கவும்',
    },
    'daysLeft': {
      AppLanguage.english: 'days left',
      AppLanguage.sinhala: 'දින ඉතිරිව ඇත',
      AppLanguage.tamil: 'நாட்கள் மீதம்',
    },

    // Limits & Budgets
    'limitsAndBudgets': {
      AppLanguage.english: 'Limits & Budgets',
      AppLanguage.sinhala: 'වියදම් සීමා සහ අයවැය',
      AppLanguage.tamil: 'வரம்புகள் & பட்ஜெட்',
    },
    'atRiskCategories': {
      AppLanguage.english: 'AT-RISK CATEGORIES',
      AppLanguage.sinhala: 'අවදානම් සීමාවන් (AT-RISK)',
      AppLanguage.tamil: 'ஆபத்தில் உள்ள வரம்புகள்',
    },
    'allBudgets': {
      AppLanguage.english: 'ALL BUDGETS',
      AppLanguage.sinhala: 'සියලුම සීමාවන් (ALL BUDGETS)',
      AppLanguage.tamil: 'அனைத்து பட்ஜெட்டுகள்',
    },
    'setBudgetLimit': {
      AppLanguage.english: 'Set Budget Limit',
      AppLanguage.sinhala: 'නව සීමාවක් සකසන්න',
      AppLanguage.tamil: 'வரம்பை அமைக்கவும்',
    },
    'closed': {
      AppLanguage.english: 'CLOSED',
      AppLanguage.sinhala: 'සීමාව පිරී ඇත (CLOSED)',
      AppLanguage.tamil: 'முடிந்தது (CLOSED)',
    },
    'atRisk': {
      AppLanguage.english: 'AT RISK',
      AppLanguage.sinhala: 'අවදානම් (AT RISK)',
      AppLanguage.tamil: 'ஆபத்தில் உள்ளது',
    },
    'healthy': {
      AppLanguage.english: 'HEALTHY',
      AppLanguage.sinhala: 'හොඳ මට්ටමේ (HEALTHY)',
      AppLanguage.tamil: 'பாதுகாப்பானது',
    },
    'remaining': {
      AppLanguage.english: 'remaining',
      AppLanguage.sinhala: 'ඉතිරිව ඇත',
      AppLanguage.tamil: 'மீதம் உள்ளது',
    },
    'spent': {
      AppLanguage.english: 'spent',
      AppLanguage.sinhala: 'වියදම් කර ඇත',
      AppLanguage.tamil: 'செலவிடப்பட்டது',
    },
    'limit': {
      AppLanguage.english: 'Limit',
      AppLanguage.sinhala: 'සීමාව',
      AppLanguage.tamil: 'வரம்பு',
    },
    'limitCapped': {
      AppLanguage.english: 'Limit reached (100% Capped)',
      AppLanguage.sinhala: 'සීමාව පිරී ඇත (100% Capped)',
      AppLanguage.tamil: 'வரம்பு முடிந்தது (100% Capped)',
    },
    'expenseAmount': {
      AppLanguage.english: 'EXPENSE AMOUNT',
      AppLanguage.sinhala: 'වියදම් මුදල',
      AppLanguage.tamil: 'செலவு தொகை',
    },
    'noteDescription': {
      AppLanguage.english: 'NOTE / DESCRIPTION',
      AppLanguage.sinhala: 'සටහන / විස්තරය',
      AppLanguage.tamil: 'குறிப்பு / விளக்கம்',
    },

    // Bills & Goals
    'dueSoon': {
      AppLanguage.english: 'Due Soon',
      AppLanguage.sinhala: 'ඉක්මනින් ගෙවිය යුතු',
      AppLanguage.tamil: 'விரைவில் செலுத்த வேண்டியவை',
    },
    'paid': {
      AppLanguage.english: 'Paid',
      AppLanguage.sinhala: 'ගෙවා ඇත',
      AppLanguage.tamil: 'செலுத்தப்பட்டது',
    },
    'unpaid': {
      AppLanguage.english: 'Unpaid',
      AppLanguage.sinhala: 'ගෙවා නැත',
      AppLanguage.tamil: 'செலுத்தப்படவில்லை',
    },
    'addBill': {
      AppLanguage.english: 'Add Bill',
      AppLanguage.sinhala: 'බිල්පතක් එක් කරන්න',
      AppLanguage.tamil: 'கட்டணம் சேர்க்கவும்',
    },
    'savingsGoals': {
      AppLanguage.english: 'Savings Goals',
      AppLanguage.sinhala: 'ඉතිරිකිරීමේ ඉලක්ක',
      AppLanguage.tamil: 'சேமிப்பு இலக்குகள்',
    },
    'addGoal': {
      AppLanguage.english: 'Add Goal',
      AppLanguage.sinhala: 'නව ඉලක්කයක්',
      AppLanguage.tamil: 'புதிய இலக்கு',
    },
    'target': {
      AppLanguage.english: 'Target',
      AppLanguage.sinhala: 'ඉලක්කය',
      AppLanguage.tamil: 'இலக்கு',
    },
    'saved': {
      AppLanguage.english: 'Saved',
      AppLanguage.sinhala: 'ඉතිරි කර ඇති මුදල',
      AppLanguage.tamil: 'சேமிக்கப்பட்டது',
    },

    // Profile & Settings
    'profileAndHousehold': {
      AppLanguage.english: 'Profile & Household',
      AppLanguage.sinhala: 'පැතිකඩ සහ පවුල',
      AppLanguage.tamil: 'சுயவிவரம் மற்றும் குடும்பம்',
    },
    'settings': {
      AppLanguage.english: 'Settings',
      AppLanguage.sinhala: 'සැකසුම්',
      AppLanguage.tamil: 'அமைப்புகள்',
    },
    'language': {
      AppLanguage.english: 'Language',
      AppLanguage.sinhala: 'භාෂාව',
      AppLanguage.tamil: 'மொழி',
    },
    'chooseLanguagePref': {
      AppLanguage.english: 'Choose your preferred language',
      AppLanguage.sinhala: 'ඔබ කැමති භාෂාව තෝරාගන්න',
      AppLanguage.tamil: 'உங்கள் விருப்ப மொழியைத் தேர்ந்தெடுக்கவும்',
    },
    'fontSize': {
      AppLanguage.english: 'Font Size',
      AppLanguage.sinhala: 'අකුරු ප්‍රමාණය',
      AppLanguage.tamil: 'எழுத்து அளவு',
    },
    'adjustTextSize': {
      AppLanguage.english: 'Adjust text size',
      AppLanguage.sinhala: 'අකුරු විශාලත්වය වෙනස් කරන්න',
      AppLanguage.tamil: 'எழுத்து அளவை மாற்றவும்',
    },
    'householdMembers': {
      AppLanguage.english: 'Household Members',
      AppLanguage.sinhala: 'පවුලේ සාමාජිකයන්',
      AppLanguage.tamil: 'குடும்ப உறுப்பினர்கள்',
    },
    'inviteMember': {
      AppLanguage.english: 'Invite Member',
      AppLanguage.sinhala: 'සාමාජිකයෙකුට ආරාධනා කරන්න',
      AppLanguage.tamil: 'உறுப்பினரை அழைக்கவும்',
    },
    'logout': {
      AppLanguage.english: 'Sign Out',
      AppLanguage.sinhala: 'ගිණුමෙන් ඉවත් වන්න',
      AppLanguage.tamil: 'வெளியேறுக',
    },

    // Categories
    'catFuel': {
      AppLanguage.english: 'Fuel',
      AppLanguage.sinhala: 'ඉන්ධන (Fuel)',
      AppLanguage.tamil: 'எரிபொருள் (Fuel)',
    },
    'catGroceries': {
      AppLanguage.english: 'Groceries',
      AppLanguage.sinhala: 'සිල්ලර බඩු (Groceries)',
      AppLanguage.tamil: 'மளிகை (Groceries)',
    },
    'catTransport': {
      AppLanguage.english: 'Transport',
      AppLanguage.sinhala: 'ප්‍රවාහන (Transport)',
      AppLanguage.tamil: 'போக்குவரத்து (Transport)',
    },
    'catDining': {
      AppLanguage.english: 'Dining / Food',
      AppLanguage.sinhala: 'ආහාර (Dining)',
      AppLanguage.tamil: 'உணவு (Dining)',
    },
    'catBills': {
      AppLanguage.english: 'Bills & Utilities',
      AppLanguage.sinhala: 'බිල්පත් (Bills)',
      AppLanguage.tamil: 'கட்டணங்கள் (Bills)',
    },
    'catShopping': {
      AppLanguage.english: 'Shopping',
      AppLanguage.sinhala: 'සාප්පු සවාරි (Shopping)',
      AppLanguage.tamil: 'ஷாப்பிங் (Shopping)',
    },
    'catHealth': {
      AppLanguage.english: 'Healthcare',
      AppLanguage.sinhala: 'සෞඛ්‍ය (Health)',
      AppLanguage.tamil: 'சுகாதாரம் (Health)',
    },
    'catEducation': {
      AppLanguage.english: 'Education',
      AppLanguage.sinhala: 'අධ්‍යාපනය (Education)',
      AppLanguage.tamil: 'கல்வி (Education)',
    },
    'catEntertainment': {
      AppLanguage.english: 'Entertainment',
      AppLanguage.sinhala: 'විනෝදාස්වාදය (Entertainment)',
      AppLanguage.tamil: 'பொழுதுபோக்கு (Entertainment)',
    },
    'catGift': {
      AppLanguage.english: 'Gifts & Donations',
      AppLanguage.sinhala: 'තෑගි (Gifts)',
      AppLanguage.tamil: 'பரிசுகள் (Gifts)',
    },
    'catSalary': {
      AppLanguage.english: 'Salary',
      AppLanguage.sinhala: 'වැටුප් (Salary)',
      AppLanguage.tamil: 'சம்பளம் (Salary)',
    },
    'catBusiness': {
      AppLanguage.english: 'Business',
      AppLanguage.sinhala: 'ව්‍යාපාර (Business)',
      AppLanguage.tamil: 'வணிகம் (Business)',
    },
    'catInvestment': {
      AppLanguage.english: 'Investment',
      AppLanguage.sinhala: 'ආයෝජන (Investment)',
      AppLanguage.tamil: 'முதலீடு (Investment)',
    },
  };
}
