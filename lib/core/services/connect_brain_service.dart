import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/clarifying_question.dart';
import '../../models/problem_analysis.dart';
import '../../models/solution_option.dart';
import 'incident_logger_service.dart';
import 'location_service.dart';
import 'medical_profile_service.dart';
import 'notification_service.dart';
import 'sos_broadcast_service.dart';

class ConnectBrainService {
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'YOUR_GEMINI_API_KEY',
  );

  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey';

  Future<ProblemAnalysis> analyze(
    String problem, {
    Map<String, String>? answers,
    String targetLanguage = 'English',
  }) async {
    String location = 'Location Unavailable';
    dynamic profile;

    try {
      final results = await Future.wait([
        LocationService.getCurrentLocationString(),
        MedicalProfileService.getProfile(),
      ]).timeout(const Duration(seconds: 2));

      location = results[0] as String;
      profile = results[1];
    } catch (_) {
      // Quietly continue if local services delay
    }

    final systemPrompt = '''
You are the CONNECT Emergency Resolution Engine.
Analyze the user's crisis: "$problem".
Assess severity, formulate emergency investigation questions to evaluate risks, and provide step-by-step first-aid/rescue guidelines along with specific emergency routing.

Return ONLY a valid raw JSON object matching this structure:
{
  "category": "Child Rescue / Medical / Fire / Vehicle / Crime",
  "problemType": "Descriptive summary of the exact situation",
  "urgency": "CRITICAL / HIGH / MEDIUM / LOW",
  "needs": ["Specific Need 1", "Specific Need 2", "Specific Need 3"],
  "questions": [
    {
      "id": "q1",
      "question": "Crucial investigative question to assess situation depth?",
      "options": ["Option 1", "Option 2", "Option 3"]
    }
  ],
  "solutionOptions": [
    {
      "title": "Immediate Physical Step / First Aid Guide",
      "subtitle": "Critical Action Protocol",
      "description": "Step 1: Do X immediately. Step 2: Ensure Y. Step 3: Do not Z.",
      "badge": "GUIDELINE"
    },
    {
      "title": "Call Specialized Response Unit (e.g., Fire & Rescue / Ambulance 108 / Police)",
      "subtitle": "Targeted Service Dispatch",
      "description": "Contact specific department directly for specialized equipment and personnel.",
      "badge": "DISPATCH"
    }
  ]
}

Target Language: $targetLanguage.
User Answered Questions So Far: ${jsonEncode(answers ?? {})}
User Medical Context: Blood ${profile?.bloodGroup ?? 'Unknown'}, Allergies ${profile?.allergies ?? 'None'}.
''';

    if (_apiKey != 'YOUR_GEMINI_API_KEY' && _apiKey.isNotEmpty) {
      try {
        final response = await http
            .post(
              Uri.parse(_endpoint),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': systemPrompt}
                    ]
                  }
                ]
              }),
            )
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final rawText =
              data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';

          final cleanedJson = rawText
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();

          final map = jsonDecode(cleanedJson) as Map<String, dynamic>;

          final analysis = ProblemAnalysis(
            problem: problem,
            category: map['category'] ?? 'Crisis Incident',
            problemType: map['problemType'] ?? 'Emergency Incident',
            urgency: map['urgency'] ?? 'HIGH',
            location: location,
            locationRequired: false,
            needs: List<String>.from(map['needs'] ?? ['Emergency Assistance']),
            missingInformation: const [],
            questions: (map['questions'] as List? ?? [])
                .map((q) => ClarifyingQuestion(
                      id: q['id'] ?? 'q1',
                      question: q['question'] ?? '',
                      options: List<String>.from(q['options'] ?? []),
                    ))
                .toList(),
            solutionOptions: (map['solutionOptions'] as List? ?? [])
                .map((opt) => SolutionOption(
                      title: opt['title'] ?? 'Emergency Action',
                      subtitle: opt['subtitle'] ?? 'Immediate Step',
                      description: opt['description'] ?? 'Follow emergency safety procedures.',
                      badge: opt['badge'] ?? 'GUIDE',
                      accent: _getBadgeColor(opt['badge']),
                    ))
                .toList(),
          );

          _fireAndForgetAlerts(analysis, profile);
          return analysis;
        }
      } catch (_) {
        // Fall back to context-aware local intelligence engine below
      }
    }

    // Context-Aware Local Intelligence Engine (Fallback when offline/unauthenticated)
    final fallbackAnalysis = _buildSmartContextFallback(problem, location);
    _fireAndForgetAlerts(fallbackAnalysis, profile);
    return fallbackAnalysis;
  }

  static Color _getBadgeColor(String? badge) {
    switch (badge?.toUpperCase()) {
      case 'GUIDELINE':
      case 'FIRST-AID':
        return Colors.green.shade700;
      case 'DISPATCH':
      case 'CRITICAL':
        return Colors.red.shade700;
      default:
        return Colors.orange.shade800;
    }
  }

  ProblemAnalysis _buildSmartContextFallback(String problem, String location) {
    final lower = problem.toLowerCase();

    if (lower.contains('child') || lower.contains('drainage') || lower.contains('fall') || lower.contains('water') || lower.contains('trapped')) {
      return ProblemAnalysis(
        problem: problem,
        category: 'Rescue & Technical Rescue Dispatch',
        problemType: 'Trapped Person / Hazardous Extraction',
        urgency: 'CRITICAL',
        location: location,
        locationRequired: true,
        needs: const ['Drainage Extraction Team', 'Subsurface Ventilation', 'Pediatric Medical Crew'],
        missingInformation: const ['Is the child visible from above?', 'Is water flowing in the drainage?'],
        questions: const [
          ClarifyingQuestion(
            id: 'drainage_depth',
            question: 'Is the child conscious and responding to your voice?',
            options: ['Yes - Conscious & Talking', 'No - Unresponsive', 'Unsure / Cannot See'],
          ),
          ClarifyingQuestion(
            id: 'water_flow',
            question: 'Is water actively flowing or filling the drain?',
            options: ['Dry / Standing Water', 'Fast Flowing Water', 'Fumes / Strong Odor'],
          ),
        ],
        solutionOptions: const [
          SolutionOption(
            title: 'Immediate On-Scene Safety Guidelines',
            subtitle: 'Critical Physical Actions Before Help Arrives',
            description: '1. Do NOT enter the drain without a tether; sewer gases cause loss of consciousness.\n2. Keep verbal contact with the child to keep them calm.\n3. Lower a rope or sturdy cloth if safe, but do not block air flow.',
            badge: 'GUIDELINE',
            accent: Colors.green,
          ),
          SolutionOption(
            title: 'Alert Fire & Special Rescue Services (101 / Disaster Control)',
            subtitle: 'Specialized Hydraulic & Extraction Squad',
            description: 'Directly dispatches Fire & Rescue team equipped with heavy lifting gear and gas detectors.',
            badge: 'DISPATCH',
            accent: Colors.red,
          ),
          SolutionOption(
            title: 'Dispatch Emergency Medical Response (108)',
            subtitle: 'Pediatric Trauma & Oxygen Support',
            description: 'Alerts nearby advanced life support ambulance for immediate trauma assessment upon extraction.',
            badge: 'DISPATCH',
            accent: Colors.amber,
          ),
        ],
      );
    }

    // Default Multi-Option Fallback
    return ProblemAnalysis(
      problem: problem,
      category: 'Emergency Dispatch',
      problemType: 'General Crisis Incident',
      urgency: 'HIGH',
      location: location,
      locationRequired: true,
      needs: const ['On-site Guidance', 'Emergency Response Unit'],
      missingInformation: const [],
      questions: const [
        ClarifyingQuestion(
          id: 'urgency_check',
          question: 'Are there immediate life-threatening injuries on scene?',
          options: ['Yes - Severe Bleeding / Unconscious', 'No - Stable but Trapped', 'Uncertain'],
        ),
      ],
      solutionOptions: const [
        SolutionOption(
          title: 'Immediate On-Site Safety Protocol',
          subtitle: 'Scene Stabilization',
          description: 'Assess scene for hazards (fire, live wires, traffic). Keep victims stationary unless immediate danger exists.',
          badge: 'GUIDELINE',
          accent: Colors.green,
        ),
        SolutionOption(
          title: 'Dispatch National Emergency Control Room (112)',
          subtitle: 'Multi-Agency Unified Dispatch',
          description: 'Triggers combined dispatch of Police, Medical, and Fire services to coordinates.',
          badge: 'DISPATCH',
          accent: Colors.red,
        ),
      ],
    );
  }

  void _fireAndForgetAlerts(ProblemAnalysis analysis, dynamic profile) {
    unawaited(
      IncidentLoggerService.logEvent(
        'Crisis Processed',
        'Urgency: ${analysis.urgency}, Category: ${analysis.category}',
      ),
    );

    if (analysis.urgency == 'CRITICAL' || analysis.urgency == 'HIGH') {
      unawaited(
        NotificationService.showEmergencyNotification(
          title: '🚨 ${analysis.urgency} Alert',
          body: 'Response activated for: ${analysis.problem}',
        ),
      );

      if (profile != null && (profile.emergencyContactPhone?.isNotEmpty ?? false)) {
        final message = SosBroadcastService.buildSosMessage(
          problem: analysis.problem,
          location: analysis.location,
          medicalNotes:
              'Blood Group: ${profile.bloodGroup}, Allergies: ${profile.allergies}',
        );
        unawaited(
          SosBroadcastService.sendDirectSms(
            profile.emergencyContactPhone,
            message,
          ),
        );
      }
    }
  }
}