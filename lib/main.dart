
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/auth/splash_screen.dart';
import 'utils/constants.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

// Temporary app-wide settings.
// These settings are kept in memory only.
class AppSettings extends ChangeNotifier {
  String language = 'English';
  String textSize = 'Medium';

  void changeLanguage(String value) {
    language = value;
    notifyListeners();
  }

  void changeTextSize(String value) {
    textSize = value;
    notifyListeners();
  }

  double get textScale {
    switch (textSize) {
      case 'Small':
        return 0.85;
      case 'Large':
        return 1.15;
      default:
        return 1.0;
    }
  }
}

final appSettings = AppSettings();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appSettings,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppConstants.appName,
          theme: AppTheme.lightTheme,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);

            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: TextScaler.linear(
                  appSettings.textScale,
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}