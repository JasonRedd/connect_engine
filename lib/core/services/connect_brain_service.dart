import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/problem_analysis.dart';
import '../../models/solution_option.dart';
import 'incident_logger_service.dart';
import 'location_service.dart'; 
import 'medical_profile_service.dart';
import 'notification_service.dart';
import 'sos_broadcast_service.dart';

class ConnectBrainService {
  // Replace with your actual Gemini API Key starting with AIza...
  static const String _apiKey = 'AQ.Ab8RN6IXay80iSWtpBjoIutl9_t1ym_ujKKdDXXXyiaZSo-KCQ';
  static const String _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey';

  Future<ProblemAnalysis> analyze(
    String problem, {
    Map<String, String>? answers,
    String targetLanguage = 'English',
  }) async {
    final location = await LocationService.getCurrentLocationString();
    final medicalProfile = await MedicalProfileService.getProfile();

    final systemPrompt = '''
You are the CONNECT Safety & Emergency Resolution Engine.
Analyze the user's emergency/crisis statement and return ONLY a valid raw JSON object matching this structure:
{
  "problem": "$problem",
  "category": "Emergency / Safety / Technical / Medical",
  "problemType": "Short descriptive summary",
  "urgency": "CRITICAL / HIGH / MEDIUM / LOW",
  "location": "$location",
  "locationRequired": false,
  "needs": ["Need 1", "Need 2", "Need 3"],
  "missingInformation": [],
  "questions": [],
  "solutionOptions": [
    {
      "title": "Action Option Title",
      "subtitle": "Short subtitle",
      "description": "Detailed emergency procedure step.",
      "badge": "IMMEDIATE"
    }
  ]
}

Target Language for Response Text: $targetLanguage.
Medical Context: Blood Group: ${medicalProfile.bloodGroup}, Allergies: ${medicalProfile.allergies}, Conditions: ${medicalProfile.medicalConditions}.
Answered Clarifications: ${jsonEncode(answers ?? {})}
''';

    try {
      final response = await http.post(
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
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawText = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        final cleanedJsonText = rawText.replaceAll('```json', '').replaceAll('```', '').trim();
        final map = jsonDecode(cleanedJsonText) as Map<String, dynamic>;

        final analysis = ProblemAnalysis(
          problem: map['problem'] ?? problem,
          category: map['category'] ?? 'Emergency Dispatch',
          problemType: map['problemType'] ?? 'Crisis Input',
          urgency: map['urgency'] ?? 'HIGH',
          location: map['location'] ?? location,
          locationRequired: map['locationRequired'] ?? false,
          needs: List<String>.from(map['needs'] ?? []),
          missingInformation: List<String>.from(map['missingInformation'] ?? []),
          questions: const [],
          solutionOptions: [
            const SolutionOption(
              title: 'Dial Emergency Helpline 112',
              subtitle: 'Direct Emergency Line',
              description: 'Tap to place an immediate emergency call to national dispatch.',
              badge: 'URGENT',
              accent: Colors.red,
            ),
          ],
        );

        await IncidentLoggerService.logEvent(
          'Crisis Analysis Generated',
          'Urgency: ${analysis.urgency}, Category: ${analysis.category}',
        );
        await _handleAutomatedAlerts(analysis);

        return analysis;
      }
    } catch (_) {
      // Fallback response handles network or parse failures smoothly below
    }

    final fallbackAnalysis = ProblemAnalysis(
      problem: problem,
      category: 'Emergency Dispatch',
      problemType: 'Unstructured Crisis Input',
      urgency: 'HIGH',
      location: location,
      locationRequired: true,
      needs: const ['Emergency Assistance', 'Immediate Contact'],
      missingInformation: const [],
      questions: const [],
      solutionOptions: const [
        SolutionOption(
          title: 'Dial Emergency Helpline 112',
          subtitle: 'Direct Emergency Line',
          description: 'Tap to place an immediate emergency call to national dispatch.',
          badge: 'URGENT',
          accent: Colors.red,
        )
      ],
    );

    await IncidentLoggerService.logEvent(
      'Fallback Emergency Dispatch Engaged',
      'Location: $location',
    );
    await _handleAutomatedAlerts(fallbackAnalysis);

    return fallbackAnalysis;
  }

  Future<void> _handleAutomatedAlerts(ProblemAnalysis analysis) async {
    if (analysis.urgency == 'CRITICAL' || analysis.urgency == 'HIGH') {
      final profile = await MedicalProfileService.getProfile();

      await NotificationService.showEmergencyNotification(
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
        await SosBroadcastService.sendDirectSms(
          profile.emergencyContactPhone,
          message,
        );
      }
    }
  }
}