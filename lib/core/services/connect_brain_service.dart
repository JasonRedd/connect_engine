import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProblemAnalysis {
  final String originalProblem;
  final String problemType;
  final String aiDiagnosis;
  final String urgencyLevel;
  final String locationContext;

  ProblemAnalysis({
    required this.originalProblem,
    required this.problemType,
    required this.aiDiagnosis,
    required this.urgencyLevel,
    required this.locationContext,
  });
}

class SolutionOption {
  final String title;
  final String category;
  final String description;
  final String actionType;
  final String actionTarget;
  final String tradeOffTag;

  SolutionOption({
    required this.title,
    required this.category,
    required this.description,
    required this.actionType,
    required this.actionTarget,
    required this.tradeOffTag,
  });

  // Getter aliases to satisfy UI widgets expecting alternative names
  String get searchQuery => actionTarget;
  String get tradeoffBadge => tradeOffTag;
}

class OrchestratedSolutionResult {
  final List<String> possibleCauses;
  final List<String> immediateActions;
  final List<SolutionOption> solutionPaths;

  OrchestratedSolutionResult({
    required this.possibleCauses,
    required this.immediateActions,
    required this.solutionPaths,
  });
}

class ConnectBrainService {
  static const String _apiKey = "YOUR_GEMINI_API_KEY";
  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  Future<ProblemAnalysis> analyzeProblem(
    String userText, {
    double? latitude,
    double? longitude,
  }) async {
    final locationString = (latitude != null && longitude != null)
        ? "Lat: ${latitude.toStringAsFixed(4)}, Long: ${longitude.toStringAsFixed(4)}"
        : "GPS Location Active";

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl?key=$_apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text":
                      "Analyze this emergency/problem: '$userText'. Return JSON with problemType, aiDiagnosis, urgencyLevel."
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawText = data['candidates'][0]['content']['parts'][0]['text'];
        final cleanJson = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
        final parsed = jsonDecode(cleanJson);

        return ProblemAnalysis(
          originalProblem: userText,
          problemType: parsed['problemType'] ?? "Medical Emergency",
          aiDiagnosis: parsed['aiDiagnosis'] ?? "Suspected acute physiological distress.",
          urgencyLevel: parsed['urgencyLevel'] ?? "HIGH",
          locationContext: locationString,
        );
      }
    } catch (e) {
      debugPrint("Gemini API Error: $e");
    }

    // Static Fallback
    return ProblemAnalysis(
      originalProblem: userText,
      problemType: "Medical Emergency",
      aiDiagnosis:
          "Suspected acute physiological distress, vascular occlusion, injury, or systemic health complication.",
      urgencyLevel: "HIGH",
      locationContext: locationString,
    );
  }

  Future<OrchestratedSolutionResult> getOrchestratedSolutions(
    String userText,
    List<String> clarifications,
  ) async {
    return OrchestratedSolutionResult(
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
  }
}