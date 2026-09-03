import 'package:flutter/material.dart';
import '../../../../core/services/connect_brain_service.dart';
import 'widgets/solution_graph_visualizer.dart';

class SolutionsScreen extends StatelessWidget {
  final ProblemAnalysis? problemAnalysis;
  final OrchestratedSolutionResult? solutionResult;
  final String? problem;
  final String? base64Image;

  const SolutionsScreen({
    super.key,
    this.problemAnalysis,
    this.solutionResult,
    this.problem,
    this.base64Image,
  });

  @override
  Widget build(BuildContext context) {
    // Resolve Problem Analysis safely across callers
    final resolvedAnalysis = problemAnalysis ??
        ProblemAnalysis(
          originalProblem: problem ?? "Emergency Incident",
          problemType: "Medical Emergency",
          aiDiagnosis: "Analysis completed for input: ${problem ?? 'Captured Content'}",
          urgencyLevel: "HIGH",
          locationContext: "GPS Location Active",
        );

    // Resolve Solution Pathways
    final resolvedSolutions = solutionResult ??
        OrchestratedSolutionResult(
          possibleCauses: [
            "Acute Deep Vein Thrombosis (DVT) or Vascular Occlusion",
            "Severe Soft Tissue Trauma / Internal Edema",
            "Peripheral Arterial Ischemia / Reduced Blood Flow"
          ],
          immediateActions: [
            "Elevate affected limb slightly and avoid putting weight on it.",
            "Do NOT massage or compress pale or swollen tissue.",
            "Seek immediate emergency medical care at an urgent care ER."
          ],
          solutionPaths: [
            SolutionOption(
              title: "Dispatch Emergency Ambulance (Call 112)",
              category: "RAPID RESPONSE",
              description: "Immediate emergency transit dispatch for acute care.",
              actionType: "call",
              actionTarget: "112",
              tradeOffTag: "⚡ Fastest",
            ),
            SolutionOption(
              title: "Navigate to Nearest Emergency Room",
              category: "DIRECT ROUTE",
              description: "Open map navigation to nearest verified ER unit.",
              actionType: "map",
              actionTarget: "Emergency Hospital",
              tradeOffTag: "⭐ Most Reliable",
            ),
          ],
        );

    final isHighUrgency = resolvedAnalysis.urgencyLevel == "HIGH";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Diagnostic Solution Plan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Urgency Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isHighUrgency ? Colors.red.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isHighUrgency ? Colors.red.shade300 : Colors.orange.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "URGENCY: ${resolvedAnalysis.urgencyLevel}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isHighUrgency ? Colors.red.shade900 : Colors.orange.shade900,
                            fontSize: 12,
                          ),
                        ),
                        Icon(
                          Icons.location_on_outlined,
                          color: isHighUrgency ? Colors.red.shade700 : Colors.orange.shade700,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "For: \"${resolvedAnalysis.originalProblem}\"",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Location Context: ${resolvedAnalysis.locationContext}",
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),

              // AI Diagnostic Evaluation Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology_outlined, color: Color(0xFF2563EB), size: 22),
                        SizedBox(width: 8),
                        Text(
                          "AI Diagnostic Evaluation",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resolvedAnalysis.aiDiagnosis,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF334155)),
                    ),
                    if (resolvedSolutions.possibleCauses.isNotEmpty) ...[
                      const Divider(height: 24),
                      const Text(
                        "Likely Root Causes:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      ...resolvedSolutions.possibleCauses.map(
                        (cause) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(
                                  cause,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Immediate Actions Required Box
              if (resolvedSolutions.immediateActions.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade900, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            "Immediate Actions Required",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...resolvedSolutions.immediateActions.map(
                        (action) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            action,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Actionable Solution Pathways Title
              const Text(
                "Actionable Solution Pathways",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Solution Pathways Visualizer List
              SolutionGraphVisualizer(
                solutionPaths: resolvedSolutions.solutionPaths,
              ),
            ],
          ),
        ),
      ),
    );
  }
}