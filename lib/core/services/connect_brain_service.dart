import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DiagnosticQuestion {
  final String question;
  final List<String> options;

  DiagnosticQuestion({
    required this.question,
    required this.options,
  });

  factory DiagnosticQuestion.fromJson(Map<String, dynamic> json) {
    return DiagnosticQuestion(
      question: json['question'] ?? 'Identify symptom detail:',
      options: List<String>.from(json['options'] ?? ['Yes', 'No', 'Unsure']),
    );
  }
}

class ProblemAnalysis {
  final String originalProblem;
  final String problemType;
  final String aiDiagnosis;
  final String urgencyLevel;
  final String locationContext;
  final List<DiagnosticQuestion> diagnosticQuestions;

  ProblemAnalysis({
    required this.originalProblem,
    required this.problemType,
    required this.aiDiagnosis,
    required this.urgencyLevel,
    required this.locationContext,
    required this.diagnosticQuestions,
  });

  factory ProblemAnalysis.fromJson(Map<String, dynamic> json, String originalProblem) {
    var rawQuestions = json['diagnosticQuestions'] as List? ?? [];
    List<DiagnosticQuestion> parsedQuestions =
        rawQuestions.map((q) => DiagnosticQuestion.fromJson(q)).toList();

    return ProblemAnalysis(
      originalProblem: originalProblem,
      problemType: json['problemType'] ?? 'General Incident',
      aiDiagnosis: json['aiDiagnosis'] ?? 'Initial assessment pending detailed diagnostic input.',
      urgencyLevel: json['urgencyLevel'] ?? 'MEDIUM',
      locationContext: json['locationContext'] ?? 'User Location (GPS)',
      diagnosticQuestions: parsedQuestions,
    );
  }
}

class SolutionOption {
  final String title;
  final String category;
  final String description;
  final String searchQuery;

  SolutionOption({
    required this.title,
    required this.category,
    required this.description,
    required this.searchQuery,
  });

  factory SolutionOption.fromJson(Map<String, dynamic> json, String userProblem) {
    return SolutionOption(
      title: json['title'] ?? 'Locate Help',
      category: json['category'] ?? 'Action Route',
      description: json['description'] ?? 'Execute this route to resolve your problem.',
      searchQuery: json['searchQuery'] ?? _cleanSearchQuery(userProblem),
    );
  }

  static String _cleanSearchQuery(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains("car") || lower.contains("vehicle") || lower.contains("towing")) {
      return "towing roadside assistance service near me";
    } else if (lower.contains("wallet") || lower.contains("keys") || lower.contains("lost")) {
      return "police station lost and found near me";
    } else if (lower.contains("pet") || lower.contains("dog") || lower.contains("cat") || lower.contains("vet") || lower.contains("gum") || lower.contains("bleeding")) {
      return "24/7 emergency vet clinic hospital near me";
    }
    return "$raw assistance near me";
  }
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
  final String _apiKey = "YOUR_GEMINI_API_KEY"; // Replace with your actual key

  Future<ProblemAnalysis> analyzeProblem(String userProblem) async {
    final String prompt = '''
    You are the AI Diagnostic Engine for CONNECT.
    Analyze the problem statement: "$userProblem".

    Generate a 5-step diagnostic triage. 

    Return a STRICT JSON object without markdown formatting:
    {
      "problemType": "Domain Category (e.g., Veterinary Emergency, Mechanical Breakdown, Financial Loss)",
      "aiDiagnosis": "Detailed 2-sentence clinical/technical diagnostic evaluation analyzing possible root causes.",
      "urgencyLevel": "HIGH, MEDIUM, or LOW",
      "locationContext": "User Location (GPS)",
      "diagnosticQuestions": [
        {
          "question": "1. What is the primary physical or physiological state?",
          "options": ["Option A", "Option B", "Option C"]
        },
        {
          "question": "2. How rapidly did the issue onset?",
          "options": ["Sudden Onset", "Gradual Transition", "Intermittent"]
        },
        {
          "question": "3. Are there secondary critical symptoms present?",
          "options": ["Severe Distress", "Mild Anomaly", "None Observed"]
        },
        {
          "question": "4. Is immediate environmental or physical containment required?",
          "options": ["Yes (Immediate Area)", "No (Stable)", "Uncertain"]
        },
        {
          "question": "5. What is the access status to primary resources?",
          "options": ["On-Site Support Needed", "Transport Capable", "Remote Guidance"]
        }
      ]
    }
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String rawText = data['candidates'][0]['content']['parts'][0]['text'];
        final String cleanJson = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
        return ProblemAnalysis.fromJson(jsonDecode(cleanJson), userProblem);
      }
    } catch (e) {
      if (kDebugMode) print("Error in analyzeProblem: $e");
    }

    return _getFiveStepFallbackAnalysis(userProblem);
  }

  ProblemAnalysis _getFiveStepFallbackAnalysis(String userProblem) {
    final lower = userProblem.toLowerCase();

    if (lower.contains("pet") || lower.contains("cat") || lower.contains("dog") || lower.contains("bleeding") || lower.contains("gum")) {
      return ProblemAnalysis(
        originalProblem: userProblem,
        problemType: "Veterinary / Oral & Acute Hemorrhage Triage",
        aiDiagnosis: "Suspected severe gingivitis/periodontitis, acute oral trauma, clotting disorder, or toxic ingestion affecting mucous membranes.",
        urgencyLevel: "HIGH",
        locationContext: "User Location (GPS)",
        diagnosticQuestions: [
          DiagnosticQuestion(
            question: "1. Bleeding Severity",
            options: ["Active Continuous Flow", "Gums Oozing / Spotting", "Bleeding Stopped"],
          ),
          DiagnosticQuestion(
            question: "2. Secondary Symptoms",
            options: ["Pale Gums / Weakness", "Excessive Drooling", "Pawing at Mouth"],
          ),
          DiagnosticQuestion(
            question: "3. Potential Cause / Onset",
            options: ["Chewed Sharp Object / Toy", "Ingested Poison / Chemicals", "Dental Disease History"],
          ),
          DiagnosticQuestion(
            question: "4. Consciousness & Responsiveness",
            options: ["Fully Alert", "Lethargic / Weak", "Unresponsive"],
          ),
          DiagnosticQuestion(
            question: "5. Transport Availability",
            options: ["Can Drive to Vet Hospital", "Need Mobile Emergency Vet", "Require Assistance"],
          ),
        ],
      );
    }

    return ProblemAnalysis(
      originalProblem: userProblem,
      problemType: "General Incident Triage",
      aiDiagnosis: "Unspecified situational emergency requiring multi-variable diagnostic triage.",
      urgencyLevel: "MEDIUM",
      locationContext: "User Location (GPS)",
      diagnosticQuestions: [
        DiagnosticQuestion(
          question: "1. Incident Classification",
          options: ["Health / Safety Risk", "Property / Hardware Failure", "Lost Items / Documents"],
        ),
        DiagnosticQuestion(
          question: "2. Urgency Escalation",
          options: ["Immediate Danger", "Time-Sensitive", "Non-Critical"],
        ),
        DiagnosticQuestion(
          question: "3. Location Vulnerability",
          options: ["Isolated / Remote Area", "Public Urban Area", "Indoor / Secured"],
        ),
        DiagnosticQuestion(
          question: "4. Physical Condition",
          options: ["Self-Sufficient", "Requires Physical Assistance", "Third-Party Involved"],
        ),
        DiagnosticQuestion(
          question: "5. Desired Resolution Outcome",
          options: ["Official Emergency Route", "Professional Service", "Self-Guided Steps"],
        ),
      ],
    );
  }

  Future<OrchestratedSolutionResult> getOrchestratedSolutions(String userProblem, List<String> selectedClarifications) async {
    final String prompt = '''
    User Problem: "$userProblem".
    Diagnostic Responses Selected: ${selectedClarifications.join(', ')}.

    Provide a complete diagnostic resolution payload:
    1. "possibleCauses": List 3 specific potential root causes.
    2. "immediateActions": List 3 immediate first-aid/safety steps to take right now before help arrives.
    3. "solutionPaths": List 3 actionable external service routes with clean Google Maps search queries.

    Format strictly as a JSON object without markdown formatting:
    {
      "possibleCauses": [
        "Cause 1",
        "Cause 2",
        "Cause 3"
      ],
      "immediateActions": [
        "Step 1: Immediate action",
        "Step 2: Immediate action",
        "Step 3: Immediate action"
      ],
      "solutionPaths": [
        {
          "title": "Action Title",
          "category": "Category",
          "description": "Short description",
          "searchQuery": "Google Maps search terms"
        }
      ]
    }
    ''';

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String rawText = data['candidates'][0]['content']['parts'][0]['text'];
        final String cleanJson = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
        final Map<String, dynamic> parsed = jsonDecode(cleanJson);

        final causes = List<String>.from(parsed['possibleCauses'] ?? []);
        final actions = List<String>.from(parsed['immediateActions'] ?? []);
        final rawPaths = parsed['solutionPaths'] as List? ?? [];
        final paths = rawPaths.map((item) => SolutionOption.fromJson(item, userProblem)).toList();

        return OrchestratedSolutionResult(
          possibleCauses: causes,
          immediateActions: actions,
          solutionPaths: paths,
        );
      }
    } catch (e) {
      if (kDebugMode) print("Error in getOrchestratedSolutions: $e");
    }

    return _getFallbackOrchestratedResult(userProblem);
  }

  OrchestratedSolutionResult _getFallbackOrchestratedResult(String userProblem) {
    final lower = userProblem.toLowerCase();

    if (lower.contains("gum") || lower.contains("bleeding") || lower.contains("cat") || lower.contains("pet")) {
      return OrchestratedSolutionResult(
        possibleCauses: [
          "Severe Gingivitis / Advanced Periodontal Disease",
          "Acute Oral Cavity Trauma (Foreign Object / Sharp Toy)",
          "Ingestion of Anticoagulants / Rodenticide Toxin"
        ],
        immediateActions: [
          "Apply gentle pressure to gums with clean, damp gauze if cat allows.",
          "Check mouth carefully for embedded foreign objects; do not force mouth open.",
          "Keep cat calm in a dark, quiet room to prevent elevated blood pressure."
        ],
        solutionPaths: [
          SolutionOption(
            title: "Route to 24/7 Emergency Vet Hospital",
            category: "Urgent Medical Triage",
            description: "Direct navigation to the nearest equipped emergency animal hospital.",
            searchQuery: "24/7 emergency vet clinic hospital near me",
          ),
          SolutionOption(
            title: "Contact Animal Toxicology & Poison Control",
            category: "Specialized Helpline",
            description: "Consult specialists for acute ingestion or poison risks.",
            searchQuery: "animal poison control helpline near me",
          ),
          SolutionOption(
            title: "Dispatch Mobile Veterinary Service",
            category: "On-Site Diagnostic",
            description: "Locate technicians capable of emergency home/field diagnostic visits.",
            searchQuery: "mobile vet house call near me",
          ),
        ],
      );
    }

    return OrchestratedSolutionResult(
      possibleCauses: [
        "Unspecified mechanical or physical malfunction",
        "Environmental interference or safety compromise",
        "Acute operational failure"
      ],
      immediateActions: [
        "Ensure personal safety and move to a secure area.",
        "Document visible symptoms or state changes.",
        "Contact specialized local emergency assistance."
      ],
      solutionPaths: [
        SolutionOption(
          title: "Locate Emergency Support Hub",
          category: "Urgent Action",
          description: "Find local centers relevant to your problem.",
          searchQuery: "$userProblem emergency help near me",
        ),
      ],
    );
  }
}