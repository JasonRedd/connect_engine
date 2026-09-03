import 'package:flutter/material.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ConnectApp());
}

class ConnectApp extends StatelessWidget {
  const ConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CONNECT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}