import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/project_provider.dart';
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Top-level background handler required by firebase_messaging.
/// Must be a top-level function (not inside a class).
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('📩 Background message: ${message.messageId}');
  } catch (e) {
    debugPrint('⚠️ Firebase background handler error: $e');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase safely
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
    // Continue launching app even if Firebase init fails
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const ElectrocomApp(),
    ),
  );
}

class ElectrocomApp extends StatelessWidget {
  const ElectrocomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Electrocom',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
          home: const LoginScreen(),
        );
      },
    );
  }
}
