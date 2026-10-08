import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/auth/splash_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';
// ALOA imports - added for Amarasinghe A.L.O.A implementation
import 'screens/dashboard/create_household_aloa.dart';
import 'screens/dashboard/family_dashboard_aloa.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const SplashScreen(),
      // ALOA routes - added for Amarasinghe A.L.O.A implementation
      routes: {
        '/create-household-aloa': (context) => CreateHouseholdALOA(
              currentUser: ModalRoute.of(context)!.settings.arguments as dynamic,
            ),
        '/family-dashboard-aloa': (context) => FamilyDashboardALOA(
              currentUser: ModalRoute.of(context)!.settings.arguments as dynamic,
            ),
      },
    );
  }
}
