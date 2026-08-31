import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../analyze_problem/presentation/analysis_screen.dart';
import '../../directory/presentation/offline_directory_screen.dart';
import '../../first_aid/presentation/first_aid_screen.dart';
import '../../profile/presentation/medical_profile_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final TextEditingController _crisisController = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _submitCrisis(String query) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AnalysisScreen(problem: query.trim())),
    );
  }

  Future<void> _toggleVoiceInput() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (val.finalResult && val.recognizedWords.isNotEmpty) {
              setState(() {
                _crisisController.text = val.recognizedWords;
                _isListening = false;
              });
              _submitCrisis(val.recognizedWords);
            }
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CONNECT Safety Engine', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Emergency Crisis AI Input', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _crisisController,
                      onSubmitted: _submitCrisis,
                      decoration: InputDecoration(
                        hintText: 'e.g. Engine fire on highway, severe bleeding...',
                        suffixIcon: IconButton(
                          icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.blue),
                          onPressed: _toggleVoiceInput,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                        onPressed: () => _submitCrisis(_crisisController.text),
                        icon: const Icon(Icons.bolt),
                        label: const Text('Analyze Emergency Crisis'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Quick Emergency Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _DashboardTile(
                  title: 'Offline Helplines',
                  subtitle: 'National emergency directory',
                  icon: Icons.contact_phone,
                  color: Colors.blue.shade800,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OfflineDirectoryScreen())),
                ),
                _DashboardTile(
                  title: 'First-Aid Guides',
                  subtitle: 'Interactive cards with audio',
                  icon: Icons.medical_services,
                  color: Colors.green.shade800,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FirstAidScreen())),
                ),
                _DashboardTile(
                  title: 'Medical Profile',
                  subtitle: 'Personal safety context card',
                  icon: Icons.badge,
                  color: Colors.amber.shade900,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicalProfileScreen())),
                ),
                _DashboardTile(
                  title: 'Instant SOS',
                  subtitle: 'Broadcast emergency coordinates',
                  icon: Icons.sos,
                  color: Colors.red.shade900,
                  onTap: () => _submitCrisis('CRITICAL EMERGENCY SOS BROADCAST'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}