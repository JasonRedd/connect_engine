import 'package:flutter/material.dart';
import '../../../core/services/connect_brain_service.dart';
import 'widgets/solution_graph_visualizer.dart';

class SolutionsScreen extends StatefulWidget {
  final String originalProblem;
  final String aiDiagnosis;
  final String locationContext;
  final String urgencyLevel;
  final List<String> selectedClarifications;

  const SolutionsScreen({
    super.key,
    required this.originalProblem,
    required this.aiDiagnosis,
    required this.locationContext,
    required this.urgencyLevel,
    required this.selectedClarifications,
  });

  @override
  State<SolutionsScreen> createState() => _SolutionsScreenState();
}

class _SolutionsScreenState extends State<SolutionsScreen> {
  final ConnectBrainService _brainService = ConnectBrainService();
  late Future<OrchestratedSolutionResult> _solutionFuture;

  bool? _isSolved;
  bool _feedbackSubmitted = false;

  @override
  void initState() {
    super.initState();
    _solutionFuture = _brainService.getOrchestratedSolutions(
      widget.originalProblem,
      widget.selectedClarifications,
    );
  }

  void _submitFeedback(bool solved) {
    setState(() {
      _isSolved = solved;
      _feedbackSubmitted = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          solved
              ? "Great! Glad CONNECT could assist you."
              : "Feedback received. We'll improve these routing paths.",
        ),
        backgroundColor: solved ? Colors.green.shade700 : Colors.grey.shade800,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CONNECT Solution Engine"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<OrchestratedSolutionResult>(
        future: _solutionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Synthesizing diagnostic causes & solution paths..."),
                ],
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Unable to generate solutions. Please try again."));
          }

          final result = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Context Banner
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Diagnostic Solution Plan",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "For: ${widget.originalProblem}",
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        "URGENCY: ${widget.urgencyLevel}",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 1. AI DIAGNOSTIC EVALUATION & CAUSES CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.psychology, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "DIAGNOSTIC SUMMARY & POTENTIAL CAUSES",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.aiDiagnosis,
                        style: TextStyle(fontSize: 13, color: Colors.blue.shade900, height: 1.3),
                      ),
                      const Divider(height: 20),
                      Text(
                        "Likely Underlying Causes:",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Column(
                        children: result.possibleCauses.map((cause) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.error_outline, size: 14, color: Colors.blue.shade700),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    cause,
                                    style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. IMMEDIATE ACTIONS TO TAKE RIGHT NOW
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.medical_services_outlined, color: Colors.amber.shade900, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "IMMEDIATE ACTIONS TO TAKE RIGHT NOW",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: result.immediateActions.map((action) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_outline, size: 16, color: Colors.amber.shade800),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    action,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. ACTIONABLE ROUTING PATHS
                const Text(
                  "External Real-World Help & Services",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                SolutionGraphVisualizer(solutionPaths: result.solutionPaths),

                const SizedBox(height: 24),

                // 4. FEEDBACK LOOP CARD
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _feedbackSubmitted
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isSolved == true ? Icons.check_circle : Icons.info,
                              color: _isSolved == true ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Thank you for helping CONNECT learn!",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Did this solve your problem?",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Your feedback trains our diagnostic models for accuracy.",
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _submitFeedback(true),
                                    icon: const Icon(Icons.thumb_up_alt_outlined, size: 16),
                                    label: const Text("Yes, Solved"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green.shade700,
                                      side: BorderSide(color: Colors.green.shade300),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _submitFeedback(false),
                                    icon: const Icon(Icons.thumb_down_alt_outlined, size: 16),
                                    label: const Text("No, Need Help"),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red.shade700,
                                      side: BorderSide(color: Colors.red.shade300),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}