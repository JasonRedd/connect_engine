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
      aiDiagnosis: json['aiDiagnosis'] ?? 'Initial diagnostic evaluation pending user input.',
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
    if (lower.contains("car") || lower.contains("bike") || lower.contains("vehicle") || lower.contains("towing")) {
      return "towing roadside assistance service near me";
    } else if (lower.contains("wallet") || lower.contains("keys") || lower.contains("lost") || lower.contains("belonging")) {
      return "police station lost and found near me";
    } else if (lower.contains("pet") || lower.contains("dog") || lower.contains("cat") || lower.contains("vet") || lower.contains("animal")) {
      return "24/7 emergency vet clinic hospital near me";
    } else if (lower.contains("leg") || lower.contains("swelling") || lower.contains("pain") || lower.contains("medical") || lower.contains("blood")) {
      return "urgent care emergency hospital near me";
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
  final String _apiKey = "YOUR_GEMINI_API_KEY"; // Replace with your actual API key

  Future<ProblemAnalysis> analyzeProblem(String userProblem) async {
    final String prompt = '''
    You are the AI Diagnostic Brain for CONNECT.
    Analyze the user problem statement: "$userProblem".

    Classify the problem into one of the 3 CORE MVP DOMAINS:
    1. MEDICAL EMERGENCY (Human health or Animal/Veterinary health)
    2. VEHICLE BREAKDOWN (Cars, Motorcycles, Commercial Vehicles - MUST ask for Vehicle Brand, Model, & Type in diagnostic questions)
    3. LOST BELONGINGS (Wallets, Keys, Phone, Documents - MUST ask for Time Period Lost, Item Category, & Location in diagnostic questions)

    Generate 5 targeted diagnostic triage questions relevant to the domain.

    Return a STRICT JSON object without markdown formatting:
    {
      "problemType": "Medical Emergency | Vehicle Breakdown | Lost Belongings",
      "aiDiagnosis": "Detailed 2-sentence clinical or technical diagnostic evaluation analyzing root causes or risks.",
      "urgencyLevel": "HIGH, MEDIUM, or LOW",
      "locationContext": "User Location (GPS)",
      "diagnosticQuestions": [
        {
          "question": "1. [Domain Specific Diagnostic Question]",
          "options": ["Option A", "Option B", "Option C"]
        },
        {
          "question": "2. [Domain Specific Question - e.g. Vehicle Brand/Model OR Time Period Lost]",
          "options": ["Option A", "Option B", "Option C"]
        },
        {
          "question": "3. [Diagnostic Symptom / Detail Question]",
          "options": ["Option A", "Option B", "Option C"]
        },
        {
          "question": "4. [Physical or Environmental Risk Question]",
          "options": ["Option A", "Option B", "Option C"]
        },
        {
          "question": "5. [Resource / Assistance Status Question]",
          "options": ["Option A", "Option B", "Option C"]
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

    return _getCoreThreeFallbackAnalysis(userProblem);
  }

  // Fallback Analysis for the 3 Core Domains
  ProblemAnalysis _getCoreThreeFallbackAnalysis(String userProblem) {
    final lower = userProblem.toLowerCase();

    // DOMAIN 1: VEHICLE BREAKDOWN
    if (lower.contains("car") ||
        lower.contains("bike") ||
        lower.contains("vehicle") ||
        lower.contains("engine") ||
        lower.contains("tire") ||
        lower.contains("towing") ||
        lower.contains("scooter") ||
        lower.contains("truck") ||
        lower.contains("broke down")) {
      return ProblemAnalysis(
        originalProblem: userProblem,
        problemType: "Vehicle Breakdown",
        aiDiagnosis: "Suspected mechanical powertrain stall, electrical battery failure, or severe tire/drivetrain damage.",
        urgencyLevel: "MEDIUM",
        locationContext: "User Location (GPS)",
        diagnosticQuestions: [
          DiagnosticQuestion(
            question: "1. Vehicle Type & Category",
            options: ["Sedan / Hatchback", "SUV / Truck", "Two-Wheeler / Motorcycle"],
          ),
          DiagnosticQuestion(
            question: "2. Vehicle Brand / Manufacturer",
            options: ["Japanese (Toyota/Honda)", "European / Luxury", "American / Other"],
          ),
          DiagnosticQuestion(
            question: "3. Mechanical Symptom State",
            options: ["Engine Won't Start", "Flat Tire / Axle Damage", "Overheating / Smoke"],
          ),
          DiagnosticQuestion(
            question: "4. Ignition / Electrical Status",
            options: ["Complete Electrical Dead", "Rapid Clicking Sound", "Engine Cranks but Fails"],
          ),
          DiagnosticQuestion(
            question: "5. Location & Safety Hazard",
            options: ["Highway Shoulder", "City Road / Parking Lot", "Home Driveway"],
          ),
        ],
      );
    }

    // DOMAIN 2: LOST BELONGINGS
    if (lower.contains("wallet") ||
        lower.contains("keys") ||
        lower.contains("lost") ||
        lower.contains("phone") ||
        lower.contains("bag") ||
        lower.contains("card") ||
        lower.contains("belonging") ||
        lower.contains("document") ||
        lower.contains("passport")) {
      return ProblemAnalysis(
        originalProblem: userProblem,
        problemType: "Lost Belongings",
        aiDiagnosis: "Unintentional displacement of critical personal property requiring rapid recovery and security actions.",
        urgencyLevel: "MEDIUM",
        locationContext: "User Location (GPS)",
        diagnosticQuestions: [
          DiagnosticQuestion(
            question: "1. Time Period Item Was Lost",
            options: ["Within Last 2 Hours", "Earlier Today (2-12 hrs)", "Over 24 Hours Ago"],
          ),
          DiagnosticQuestion(
            question: "2. Specific Item Category",
            options: ["Wallet / Credit Cards", "Keys / Fob", "Phone / Electronic Device"],
          ),
          DiagnosticQuestion(
            question: "3. Last Known Location Context",
            options: ["Public Transit / Cab", "Restaurant / Store", "Outdoor / Street"],
          ),
          DiagnosticQuestion(
            question: "4. Financial / Identity Risk",
            options: ["Contains Active Credit Cards", "Govt ID / Passport Included", "General Property Only"],
          ),
          DiagnosticQuestion(
            question: "5. Immediate Action Status",
            options: ["Cards Blocked via App", "Searched Immediate Area", "No Action Taken Yet"],
          ),
        ],
      );
    }

    // DOMAIN 3: MEDICAL EMERGENCY (Human & Animal)
    return ProblemAnalysis(
      originalProblem: userProblem,
      problemType: lower.contains("pet") || lower.contains("dog") || lower.contains("cat") ? "Medical Emergency (Veterinary)" : "Medical Emergency (Human)",
      aiDiagnosis: lower.contains("pet") || lower.contains("dog") || lower.contains("cat")
          ? "Suspected acute animal physiological distress, potential toxicity exposure, or trauma requiring veterinary attention."
          : "Suspected acute physiological distress, vascular occlusion, injury, or systemic health complication.",
      urgencyLevel: "HIGH",
      locationContext: "User Location (GPS)",
      diagnosticQuestions: [
        DiagnosticQuestion(
          question: "1. Primary Physical State / Patient",
          options: ["Human Adult / Child", "Domestic Pet (Dog/Cat)", "Livestock / Other"],
        ),
        DiagnosticQuestion(
          question: "2. Primary Acute Symptom",
          options: ["Severe Pain / Swelling", "Bleeding / Open Wound", "Unconscious / Lethargic"],
        ),
        DiagnosticQuestion(
          question: "3. Symptom Onset Speed",
          options: ["Sudden Onset (<1 hr)", "Gradual over Hours", "Chronic / Worsening"],
        ),
        DiagnosticQuestion(
          question: "4. Mobility & Transportation Status",
          options: ["Self-Transport Capable", "Requires On-Site Aid", "Requires Ambulance/Rescue"],
        ),
        DiagnosticQuestion(
          question: "5. Secondary Complications",
          options: ["Breathing Difficulty", "Dizziness / Confusion", "None Observed"],
        ),
      ],
    );
  }

  Future<OrchestratedSolutionResult> getOrchestratedSolutions(String userProblem, List<String> selectedClarifications) async {
    final String prompt = '''
    User Problem: "$userProblem".
    Diagnostic Responses Selected: ${selectedClarifications.join(', ')}.

    Provide a complete resolution plan mapped to one of the 3 Core MVP Domains (Medical Emergency, Vehicle Breakdown, or Lost Belongings):
    1. "possibleCauses": List 3 specific potential root causes based on problem type & diagnostic input.
    2. "immediateActions": List 3 immediate first-aid/safety/blocking steps to take right now before help arrives.
    3. "solutionPaths": List 3 actionable external service routes with clean Google Maps search terms.

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

    return _getCoreThreeFallbackSolutions(userProblem);
  }

  // Fallback Solutions for the 3 Core Domains
  OrchestratedSolutionResult _getCoreThreeFallbackSolutions(String userProblem) {
    final lower = userProblem.toLowerCase();

    // DOMAIN 1: VEHICLE BREAKDOWN
    if (lower.contains("car") ||
        lower.contains("bike") ||
        lower.contains("vehicle") ||
        lower.contains("engine") ||
        lower.contains("tire") ||
        lower.contains("towing") ||
        lower.contains("scooter") ||
        lower.contains("broke down")) {
      return OrchestratedSolutionResult(
        possibleCauses: [
          "Starter Motor or Alternator/Battery Failure",
          "Drivetrain / Transmission Fault",
          "Severe Tire Puncture or Axle Damage"
        ],
        immediateActions: [
          "Turn on hazard lights and remain inside if parked on a highway.",
          "Place a reflector warning triangle 50m behind the vehicle if safe.",
          "Contact local towing or emergency roadside repair immediately."
        ],
        solutionPaths: [
          SolutionOption(
            title: "Request Emergency Flatbed Towing",
            category: "Roadside Assistance",
            description: "Locate towing services near your GPS location.",
            searchQuery: "towing roadside assistance service near me",
          ),
          SolutionOption(
            title: "Find Nearby Auto Repair Mechanic",
            category: "Mechanic Support",
            description: "Locate brand-compatible repair garages for diagnostics.",
            searchQuery: "car repair mechanic garage near me",
          ),
          SolutionOption(
            title: "Locate 24/7 Fuel Station / Safe Stop",
            category: "Safety & Rest Area",
            description: "Find well-lit fueling stations while waiting for aid.",
            searchQuery: "gas station rest stop near me",
          ),
        ],
      );
    }

    // DOMAIN 2: LOST BELONGINGS
    if (lower.contains("wallet") ||
        lower.contains("keys") ||
        lower.contains("lost") ||
        lower.contains("phone") ||
        lower.contains("bag") ||
        lower.contains("card") ||
        lower.contains("belonging") ||
        lower.contains("document") ||
        lower.contains("passport")) {
      return OrchestratedSolutionResult(
        possibleCauses: [
          "Left behind at last visited public location",
          "Displaced during public transit commute",
          "Unintentional theft or misplacement"
        ],
        immediateActions: [
          "Immediately freeze or block lost bank cards via mobile app or helpline.",
          "File an online or local police lost property entry for documentation.",
          "Contact transit or venue lost-and-found desks directly."
        ],
        solutionPaths: [
          SolutionOption(
            title: "File Report at Nearest Police Station",
            category: "Official Lost Report",
            description: "Visit nearest station to file official lost property documentation.",
            searchQuery: "police station lost and found near me",
          ),
          SolutionOption(
            title: "Contact Transit Lost Property Desk",
            category: "Transit Recovery",
            description: "Reach out to metro/bus transit lost property offices.",
            searchQuery: "transit lost property office near me",
          ),
          SolutionOption(
            title: "Locate Nearest Bank Branch",
            category: "Financial Security",
            description: "Visit local bank branches to freeze compromised accounts.",
            searchQuery: "bank branch near me",
          ),
        ],
      );
    }

    // DOMAIN 3: MEDICAL EMERGENCY (Human & Animal)
    if (lower.contains("pet") || lower.contains("dog") || lower.contains("cat") || lower.contains("animal") || lower.contains("vet")) {
      return OrchestratedSolutionResult(
        possibleCauses: [
          "Acute Oral Trauma or Foreign Body Ingestion",
          "Periodontal Disease / Mucous Membrane Hemorrhage",
          "Toxic Chemical or Poison Ingestion"
        ],
        immediateActions: [
          "Apply gentle pressure to bleeding areas with clean gauze if safe.",
          "Keep animal in a dark, quiet room to minimize elevated blood pressure.",
          "Do not give human medications without direct veterinary approval."
        ],
        solutionPaths: [
          SolutionOption(
            title: "Route to 24/7 Emergency Vet Hospital",
            category: "Urgent Veterinary Medical",
            description: "Direct navigation to the nearest equipped emergency animal hospital.",
            searchQuery: "24/7 emergency vet clinic hospital near me",
          ),
          SolutionOption(
            title: "Contact Animal Poison & Toxicity Helpline",
            category: "Specialized Helpline",
            description: "Consult specialists for acute ingestion or poison risks.",
            searchQuery: "animal poison control helpline near me",
          ),
          SolutionOption(
            title: "Dispatch Mobile Veterinary Service",
            category: "On-Site Diagnostic",
            description: "Locate technicians capable of emergency home/field visits.",
            searchQuery: "mobile vet house call near me",
          ),
        ],
      );
    }

    // Human Medical Emergency Default
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
          title: "Route to Emergency Hospital / Urgent Care",
          category: "Urgent Medical Triage",
          description: "Direct navigation to the nearest emergency room or hospital.",
          searchQuery: "urgent care emergency hospital near me",
        ),
        SolutionOption(
          title: "Call Emergency Ambulance Services",
          category: "Emergency Transit",
          description: "Contact local emergency health services for rapid dispatch.",
          searchQuery: "ambulance service emergency health near me",
        ),
        SolutionOption(
          title: "Locate 24/7 Pharmacy",
          category: "Medical Supplies",
          description: "Find open pharmacies for basic medical supplies.",
          searchQuery: "24/7 pharmacy medical store near me",
        ),
      ],
    );
  }
}