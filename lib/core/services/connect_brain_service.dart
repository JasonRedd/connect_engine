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
    defaultValue: 'YOUR_GEMINI_API_KEY_HERE',
  );
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey';

  Future<ProblemAnalysis> analyze(
    String problem, {
    Map<String, String>? answers,
    String targetLanguage = 'English',
    String? base64Image,
  }) async {
    // 1. Fetch Location and Medical Profile concurrently
    final results = await Future.wait([
      LocationService.getCurrentLocationString(),
      MedicalProfileService.getProfile(),
    ]);

    final location = results[0] as String;
    final medicalProfile = results[1] as dynamic;

    final systemPrompt = '''
You are the CONNECT Safety & Emergency Resolution Engine.
Analyze the user's emergency statement (and any attached image).
Provide high-priority investigative clarifying questions if details are missing, alongside immediate, actionable solution steps.

Return ONLY a valid raw JSON object matching this structure:
{
  "problem": "$problem",
  "category": "Emergency / Medical / Fire / Safety / Technical",
  "problemType": "Short descriptive summary",
  "urgency": "CRITICAL / HIGH / MEDIUM / LOW",
  "location": "$location",
  "locationRequired": false,
  "needs": ["Immediate need 1", "Immediate need 2"],
  "missingInformation": ["Key detail missing 1"],
  "questions": [
    {
      "id": "q1",
      "question": "Is the person conscious and breathing?",
      "options": ["Yes", "No", "Unsure"]
    }
  ],
  "solutionOptions": [
    {
      "title": "Clear Airway & Position",
      "subtitle": "Immediate Medical Response",
      "description": "Place person on their side in recovery position immediately.",
      "badge": "STEP 1"
    }
  ]
}

Target Language: $targetLanguage.
Medical Context: Blood Group: ${medicalProfile.bloodGroup}, Allergies: ${medicalProfile.allergies}.
Answered Clarifications: ${jsonEncode(answers ?? {})}
''';

    final List<Map<String, dynamic>> parts = [
      {'text': systemPrompt}
    ];

    if (base64Image != null && base64Image.isNotEmpty) {
      parts.add({
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Image,
        }
      });
    }

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {'parts': parts}
              ]
            }),
          )
          .timeout(const Duration(seconds: 7));

      debugPrint('Gemini Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawText =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        
        // Strip markdown code fences if Gemini wraps JSON in backticks
        final cleanedJsonText =
            rawText.replaceAll('```json', '').replaceAll('```', '').trim();
        final map = jsonDecode(cleanedJsonText) as Map<String, dynamic>;

        // Dynamic Parsing of Clarifying Questions
        final List<ClarifyingQuestion> parsedQuestions = [];
        if (map['questions'] != null) {
          for (var q in (map['questions'] as List<dynamic>)) {
            parsedQuestions.add(
              ClarifyingQuestion(
                id: q['id'] ?? 'q_${parsedQuestions.length}',
                question: q['question'] ?? '',
                options: List<String>.from(q['options'] ?? []),
              ),
            );
          }
        }

        // Dynamic Parsing of Solution Options
        final List<SolutionOption> parsedSolutions = [];
        if (map['solutionOptions'] != null) {
          for (var opt in (map['solutionOptions'] as List<dynamic>)) {
            parsedSolutions.add(
              SolutionOption(
                title: opt['title'] ?? 'Action Required',
                subtitle: opt['subtitle'] ?? 'Emergency Protocol',
                description: opt['description'] ?? '',
                badge: opt['badge'] ?? 'ACTION',
                accent: Colors.redAccent,
              ),
            );
          }
        }

        final analysis = ProblemAnalysis(
          problem: map['problem'] ?? problem,
          category: map['category'] ?? 'Emergency Response',
          problemType: map['problemType'] ?? 'Crisis Input',
          urgency: map['urgency'] ?? 'HIGH',
          location: map['location'] ?? location,
          locationRequired: map['locationRequired'] ?? false,
          needs: List<String>.from(map['needs'] ?? []),
          missingInformation:
              List<String>.from(map['missingInformation'] ?? []),
          questions: parsedQuestions,
          solutionOptions: parsedSolutions.isNotEmpty
              ? parsedSolutions
              : const [
                  SolutionOption(
                    title: 'Contact National Emergency Helpline',
                    subtitle: 'Immediate Response',
                    description: 'Place direct call to 112 dispatch center.',
                    badge: 'URGENT',
                    accent: Colors.red,
                  )
                ],
        );

        // Non-blocking background telemetry
        IncidentLoggerService.logEvent(
          'Crisis Analysis Generated',
          'Urgency: ${analysis.urgency}, Category: ${analysis.category}',
        );
        _handleAutomatedAlerts(analysis);

        return analysis;
      }
    } catch (e) {
      debugPrint('Gemini Engine Error: $e');
    }

    // Safety Fallback for offline mode or network timeouts
    final fallbackAnalysis = ProblemAnalysis(
      problem: problem,
      category: 'Emergency Dispatch',
      problemType: 'Offline Emergency Mode',
      urgency: 'HIGH',
      location: location,
      locationRequired: true,
      needs: const ['Emergency Assistance', 'Local Contact'],
      missingInformation: const [],
      questions: const [],
      solutionOptions: const [
        SolutionOption(
          title: 'Dial Emergency Helpline 112',
          subtitle: 'Direct Emergency Line',
          description:
              'Tap to place an immediate emergency call to national dispatch.',
          badge: 'URGENT',
          accent: Colors.red,
        )
      ],
    );

    IncidentLoggerService.logEvent(
      'Fallback Emergency Dispatch Engaged',
      'Location: $location',
    );
    _handleAutomatedAlerts(fallbackAnalysis);

    return fallbackAnalysis;
  }

  Future<void> _handleAutomatedAlerts(ProblemAnalysis analysis) async {
    if (analysis.urgency == 'CRITICAL' || analysis.urgency == 'HIGH') {
      final profile = await MedicalProfileService.getProfile();

      NotificationService.showEmergencyNotification(
        title: '🚨 ${analysis.urgency} Urgency Alert',
        body: 'Emergency response activated for: ${analysis.problem}',
      );

      if (profile.emergencyContactPhone.isNotEmpty) {
        final message = SosBroadcastService.buildSosMessage(
          problem: analysis.problem,
          location: analysis.location,
          medicalNotes:
              'Blood Group: ${profile.bloodGroup}, Allergies: ${profile.allergies}',
        );
        SosBroadcastService.sendDirectSms(
          profile.emergencyContactPhone,
          message,
        );
      }
    }
  }
}