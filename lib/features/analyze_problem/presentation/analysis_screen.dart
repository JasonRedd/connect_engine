import 'package:flutter/material.dart';
import '../../../../core/services/connect_brain_service.dart';
import '../../solutions/presentation/solutions_screen.dart';

class AnalysisScreen extends StatefulWidget {
  final ProblemAnalysis problemAnalysis;

  const AnalysisScreen({
    super.key,
    required this.problemAnalysis,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final List<String> _selectedAnswers = [];
  bool _isProcessing = false;

  void _proceedToSolutions() async {
    setState(() => _isProcessing = true);

    try {
      final brainService = ConnectBrainService();
      final solutions = await brainService.getOrchestratedSolutions(
        widget.problemAnalysis.originalProblem,
        _selectedAnswers,
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SolutionsScreen(
              problemAnalysis: widget.problemAnalysis,
              solutionResult: solutions,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Triage Analysis",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Urgency & Problem Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "URGENCY: ${widget.problemAnalysis.urgencyLevel}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                            fontSize: 12,
                          ),
                        ),
                        Icon(Icons.shield_outlined, color: Colors.blue.shade700, size: 18),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.problemAnalysis.aiDiagnosis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Diagnostic Evaluation",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Reviewing real-time context for ${widget.problemAnalysis.originalProblem}.",
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const Spacer(),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _proceedToSolutions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Generate Solution Pathways",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}