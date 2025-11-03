import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'config/theme.dart';
import 'screens/auth/login_screen.dart';
import 'providers/auth_provider.dart';

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const ElectrocomApp(),
    ),
  );
}

class ElectrocomApp extends StatelessWidget {
  const ElectrocomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electrocom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
