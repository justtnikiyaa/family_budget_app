import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/user_model.dart';
import 'screens/limits_bills/limits_bills_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // For web: use the web-specific options if configured
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyBLaDX9T9Jb5lPH1P-wFtDkrumWZJQlSDE',
          authDomain: 'family-budget-app-we105.firebaseapp.com',
          projectId: 'family-budget-app-we105',
          storageBucket: 'family-budget-app-we105.firebasestorage.app',
          messagingSenderId: '276027777653',
          appId: '1:276027777653:web:c537b06e5cc8d714adce3c',
        ),
      );
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      home: LimitsBillsScreen(
        currentUser: UserModel(
          uid: 'rakindu_user',
          email: 'rakindu@familybudget.lk',
          displayName: 'Rakindu',
          familyId: 'family_rakindu_1',
        ),
      ),
    );
  }
}
