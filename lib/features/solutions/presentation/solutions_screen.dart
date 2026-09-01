import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/audio_guidance_service.dart';
import '../../../core/services/incident_logger_service.dart';
import '../../../models/problem_analysis.dart';

class SolutionsScreen extends StatelessWidget {
  const SolutionsScreen({
    super.key,
    required this.problem,
    this.analysis,
  });

  final String problem;
  final ProblemAnalysis? analysis;

  Future<void> _handleAction(BuildContext context, String title, String description) async {
    final titleLower = title.toLowerCase();
    final descLower = description.toLowerCase();
    final problemLower = problem.toLowerCase();

    await IncidentLoggerService.logEvent(
      'ACTION_EXECUTED',
      'Title: $title | Description: $description',
    );

    // Trigger audio guidance
    AudioGuidanceService.speak('Executing $title. $description');

    // 1. Direct Emergency Call Handler (tel:112 or tel:108)
    if (titleLower.contains('call') ||
        titleLower.contains('dial') ||
        titleLower.contains('112') ||
        titleLower.contains('108') ||
        titleLower.contains('helpline')) {
      final Uri phoneUri = Uri(scheme: 'tel', path: '112');
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
        return;
      }
    }

    // 2. Direct Emergency SMS Handler
    if (titleLower.contains('sms') || titleLower.contains('text') || titleLower.contains('broadcast')) {
      final Uri smsUri = Uri.parse(
        'sms:112?body=${Uri.encodeComponent("EMERGENCY ALERT: Need urgent assistance for problem: $problem")}',
      );
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return;
      }
    }

    // 3. Smart Google Maps Search Router (Structured Category Search)
    String searchQuery = 'emergency services near me';

    if (problemLower.contains('tree') ||
        problemLower.contains('car') ||
        problemLower.contains('vehicle') ||
        problemLower.contains('breakdown') ||
        problemLower.contains('towing') ||
        descLower.contains('towing')) {
      searchQuery = 'towing service roadside assistance near me';
    } else if (problemLower.contains('bleed') ||
        problemLower.contains('fever') ||
        problemLower.contains('injury') ||
        problemLower.contains('medical') ||
        descLower.contains('hospital')) {
      searchQuery = 'hospitals emergency room near me';
    } else if (problemLower.contains('fire') || descLower.contains('fire')) {
      searchQuery = 'fire station near me';
    } else if (problemLower.contains('crime') || problemLower.contains('threat') || descLower.contains('police')) {
      searchQuery = 'police station near me';
    }

    final Uri mapUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(searchQuery)}',
    );

    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch action intent.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = analysis?.solutionOptions ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('CONNECT Solution Engine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export Audit PDF',
            onPressed: () {
              IncidentLoggerService.exportPdfReport(
                problem,
                analysis?.location ?? 'User Location',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: 'Read Solution Aloud',
            onPressed: () {
              if (options.isNotEmpty) {
                AudioGuidanceService.speak(
                  'Primary recommendation: ${options.first.title}. ${options.first.description}',
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Orchestrated Solution Paths',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text('For: $problem', style: const TextStyle(color: Colors.grey, fontSize: 15)),
              if (analysis != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    'Urgency: ${analysis!.urgency} • Location: ${analysis!.location}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: option.accent.withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: option.accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(child: Text(option.badge, style: const TextStyle(fontSize: 20))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(option.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                    Text(option.subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(option.description),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleAction(context, option.title, option.description),
                              icon: const Icon(Icons.launch, size: 18),
                              label: Text('Execute ${option.title}'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}