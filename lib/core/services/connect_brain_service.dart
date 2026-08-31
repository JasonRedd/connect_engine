import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/clarifying_question.dart';
import '../../models/problem_analysis.dart';
import '../../models/solution_option.dart';
import 'incident_logger_service.dart';
import 'location_service.dart';
import 'medical_profile_service.dart';
import 'notification_service.dart';

class ConnectBrainService {
  static const String _apiKey = 'AQ_PASTE_YOUR_EXACT_KEY_HERE';

  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent';

  Future<ProblemAnalysis> analyze(
    String input, {
    Map<String, String>? answers,
    String targetLanguage = 'English',
  }) async {
    final text = input.trim();
    final selectedAnswers = answers ?? {};
    final cacheKey = 'connect_cache_${targetLanguage}_${text.toLowerCase()}';

    // Log input event to audit trail
    await IncidentLoggerService.logEvent('QUERY_INITIATED', 'Input: "$text"');

    // Fetch Medical Profile for Context Injection
    final medProfile = await MedicalProfileService.getProfile();
    final medicalContext = '''
User Name: ${medProfile.fullName}
Blood Group: ${medProfile.bloodGroup}
Allergies: ${medProfile.allergies}
Medical Conditions: ${medProfile.medicalConditions}
Emergency Contact: ${medProfile.emergencyContactName} (${medProfile.emergencyContactPhone})
''';

    // Response Caching
    if (selectedAnswers.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        return _parseJsonToAnalysis(text, jsonDecode(cachedData));
      }
    }

    final gpsLocation = await LocationService.getCurrentLocationString();

    if (_apiKey.trim().isEmpty || _apiKey == 'PASTE_YOUR_AQ_KEY_HERE') {
      return _fallbackAnalyze(text, selectedAnswers, gpsLocation);
    }

    try {
      final prompt = '''
You are CONNECT, an AI-powered emergency & problem-to-solution engine.
Analyze this human problem: "$text"
User Live GPS Location Context: "$gpsLocation"
User Medical Profile Context: "$medicalContext"
Contextual answers provided so far: ${jsonEncode(selectedAnswers)}
Target Language for Output: "$targetLanguage"

Respond strictly in valid JSON format matching this schema:
{
  "category": "String (One of: 🚨 URGENT HELP, 🛠️ SERVICES, 🤝 PEOPLE, 📦 RESOURCES, 📚 GUIDANCE)",
  "problemType": "String (Concise classification in $targetLanguage)",
  "urgency": "String (LOW, MEDIUM, HIGH, or CRITICAL)",
  "location": "String (Live location context in $targetLanguage)",
  "needs": ["Array of 3 core requirements in $targetLanguage"],
  "questions": [
    {
      "id": "q1",
      "question": "Clarifying question in $targetLanguage?",
      "options": ["Option 1", "Option 2", "Option 3"]
    }
  ],
  "solutionOptions": [
    {
      "title": "Fastest Solution",
      "badge": "⚡",
      "subtitle": "Short subtitle in $targetLanguage",
      "description": "Actionable path description in $targetLanguage"
    },
    {
      "title": "Most Economical",
      "badge": "💰",
      "subtitle": "Short subtitle in $targetLanguage",
      "description": "Actionable path description in $targetLanguage"
    }
  ]
}
''';

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _apiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {'response_mime_type': 'application/json'}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rawJson = data['candidates'][0]['content']['parts'][0]['text'];
        final parsed = jsonDecode(rawJson);

        if (selectedAnswers.isEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(cacheKey, rawJson);
        }

        if (parsed['urgency'] == 'CRITICAL' || parsed['urgency'] == 'HIGH') {
          await NotificationService.showEmergencyNotification(
            title: '🚨 High Urgency Detected',
            body: 'Active route: ${parsed['problemType']}',
          );
        }

        return _parseJsonToAnalysis(text, parsed);
      }
    } catch (e) {
      debugPrint('AI API Exception: $e');
    }

    return _fallbackAnalyze(text, selectedAnswers, gpsLocation);
  }

  ProblemAnalysis _parseJsonToAnalysis(String text, Map<String, dynamic> parsed) {
    return ProblemAnalysis(
      problem: text,
      category: parsed['category'] ?? '📚 GUIDANCE',
      problemType: parsed['problemType'] ?? 'General Issue',
      urgency: parsed['urgency'] ?? 'MEDIUM',
      location: parsed['location'] ?? 'User Location',
      locationRequired: true,
      needs: List<String>.from(parsed['needs'] ?? []),
      missingInformation: const [],
      questions: (parsed['questions'] as List? ?? [])
          .map((q) => ClarifyingQuestion(
                id: q['id'] ?? 'q',
                question: q['question'] ?? '',
                options: List<String>.from(q['options'] ?? []),
              ))
          .toList(),
      solutionOptions: (parsed['solutionOptions'] as List? ?? [])
          .map((s) => SolutionOption(
                title: s['title'] ?? 'Option',
                badge: s['badge'] ?? '💡',
                subtitle: s['subtitle'] ?? '',
                description: s['description'] ?? '',
                accent: const Color(0xFF1E5EFF),
              ))
          .toList(),
    );
  }

  ProblemAnalysis _fallbackAnalyze(String text, Map<String, String> answers, String gpsLocation) {
    return ProblemAnalysis(
      problem: text,
      category: '📚 GUIDANCE / 🛠️ SERVICES',
      problemType: 'General Problem Resolution',
      urgency: 'MEDIUM',
      location: answers['location'] ?? gpsLocation,
      locationRequired: false,
      needs: const [
        'Understand core underlying issue',
        'Identify target solution network',
        'Create actionable step sequence'
      ],
      missingInformation: const [],
      questions: const [
        ClarifyingQuestion(
          id: 'timeframe',
          question: 'How quickly do you need this problem resolved?',
          options: ['Immediately (Within 2 hrs)', 'Today', 'In a few days'],
        ),
      ],
      solutionOptions: const [
        SolutionOption(
          title: 'Direct Action Plan',
          badge: '⚡',
          subtitle: 'Step-by-step resolution path',
          description: 'Follow organized steps tailored to your specific problem.',
          accent: Color(0xFF1E5EFF),
        ),
      ],
    );
  }
}