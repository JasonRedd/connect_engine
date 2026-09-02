import 'package:flutter/material.dart';
import '../../../core/services/connect_brain_service.dart';
import '../../solutions/presentation/solutions_screen.dart';

class AnalysisScreen extends StatefulWidget {
  final String? problem;
  final String? problemText;
  final String? base64Image;

  const AnalysisScreen({
    super.key,
    this.problem,
    this.problemText,
    this.base64Image,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final ConnectBrainService _brainService = ConnectBrainService();
  late Future<ProblemAnalysis> _analysisFuture;
  
  // Maps diagnostic question index -> selected option string
  final Map<int, String> _selectedAnswers = {};
  int _loadingStep = 0;

  String get _userProblem =>
      widget.problemText ?? widget.problem ?? "Unknown Problem";

  @override
  void initState() {
    super.initState();
    _startLoadingPipeline();
    _analysisFuture = _brainService.analyzeProblem(_userProblem);
  }

  void _startLoadingPipeline() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _loadingStep = 1);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _loadingStep = 2);
  }

  void _onOptionSelected(int questionIndex, String option) {
    setState(() {
      _selectedAnswers[questionIndex] = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CONNECT AI Brain"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<ProblemAnalysis>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(strokeWidth: 3),
                    const SizedBox(height: 28),
                    _buildLoadingStepTile(stepIndex: 0, label: "Evaluating Problem Intent..."),
                    const SizedBox(height: 12),
                    _buildLoadingStepTile(stepIndex: 1, label: "Running AI Diagnostic Evaluation..."),
                    const SizedBox(height: 12),
                    _buildLoadingStepTile(stepIndex: 2, label: "Formulating 5-Step Triage..."),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Error processing analysis. Please try again."));
          }

          final analysis = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Problem Analysis Context Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Original Problem", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text(analysis.originalProblem, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text("Problem type: ${analysis.problemType}"),
                      Text("Urgency level: ${analysis.urgencyLevel}"),
                      Text("Location context: ${analysis.locationContext}"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // AI DIAGNOSIS CARD
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
                          Text("AI DIAGNOSTIC EVALUATION", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade900)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        analysis.aiDiagnosis,
                        style: TextStyle(fontSize: 14, color: Colors.blue.shade900, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 5-STEP DIAGNOSTIC TRIAGE SECTION
                const Text(
                  "5-Step Diagnostic Triage",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Select options below to refine solution orchestration:",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: analysis.diagnosticQuestions.length,
                  itemBuilder: (context, index) {
                    final q = analysis.diagnosticQuestions[index];
                    final selectedOption = _selectedAnswers[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.question,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: q.options.map((option) {
                              final isSelected = selectedOption == option;
                              return ChoiceChip(
                                label: Text(option, style: const TextStyle(fontSize: 12)),
                                selected: isSelected,
                                selectedColor: Colors.blue.shade100,
                                onSelected: (_) => _onOptionSelected(index, option),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedClarificationsList = _selectedAnswers.values.toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SolutionsScreen(
                            originalProblem: analysis.originalProblem,
                            aiDiagnosis: analysis.aiDiagnosis,
                            locationContext: analysis.locationContext,
                            urgencyLevel: analysis.urgencyLevel,
                            selectedClarifications: selectedClarificationsList,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                    child: const Text(
                      "Orchestrate Solutions with Diagnostic Data",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingStepTile({required int stepIndex, required String label}) {
    final bool isDone = _loadingStep > stepIndex;
    final bool isCurrent = _loadingStep == stepIndex;

    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle : isCurrent ? Icons.auto_awesome : Icons.radio_button_unchecked,
          color: isDone ? Colors.green : isCurrent ? const Color(0xFF2563EB) : Colors.grey.shade400,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isCurrent || isDone ? FontWeight.bold : FontWeight.normal,
            color: isCurrent || isDone ? const Color(0xFF1E293B) : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}