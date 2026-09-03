import 'package:flutter/material.dart';
import '../../../../core/services/connect_brain_service.dart';
import '../../solutions/presentation/solutions_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final TextEditingController _quickProblemController = TextEditingController();

  void _navigateToSolutions(String userProblem) {
    final text = userProblem.trim();
    if (text.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolutionsScreen(
          problemAnalysis: ProblemAnalysis(
            originalProblem: text,
            problemType: "Medical Emergency",
            aiDiagnosis: "Initial triage assessment generated for: \"$text\"",
            urgencyLevel: "HIGH",
            locationContext: "GPS Location Active",
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CONNECT Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Quick Triage",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quickProblemController,
              decoration: InputDecoration(
                hintText: "Enter quick emergency query...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  onPressed: () => _navigateToSolutions(_quickProblemController.text),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}