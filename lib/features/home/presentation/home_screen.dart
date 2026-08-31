import 'package:flutter/material.dart';

import '../../../core/widgets/primary_button.dart';
import '../../analyze_problem/presentation/analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _problemController = TextEditingController(
    text: "My car broke down and I don't know what to do.",
  );

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final problem = _problemController.text.trim();

    if (problem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your problem first.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisScreen(problem: problem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                'CONNECT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'How can we help you?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Tell us what is happening. We will help you find the next best step.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _problemController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Tell us what happened...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Find Help',
                onPressed: _handleSubmit,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
