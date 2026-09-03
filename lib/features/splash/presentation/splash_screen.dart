import 'dart:async';
import 'package:flutter/material.dart';
import '../../home/presentation/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2-second display timer before launching HomeScreen
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // CONNECT Logo Image
                Image.asset(
                  'assets/images/connect_logo.png',
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0066FF),
                              width: 8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.connect_without_contact,
                            size: 72,
                            color: Color(0xFF00D09C),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "CONNECT",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            color: Color(0xFF0A192F),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your problem. Our priority.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const Spacer(),

                // Loading Progress Indicator
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09C)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}