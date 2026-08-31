import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../../core/services/connect_brain_service.dart';
import '../../../core/services/sos_broadcast_service.dart';
import '../../../models/problem_analysis.dart';
import '../../solutions/presentation/solutions_screen.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key, required this.problem});

  final String problem;

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final ConnectBrainService _brainService = ConnectBrainService();
  final Map<String, String> _selectedAnswers = {};
  late stt.SpeechToText _speech;

  bool _isLoading = true;
  bool _isListening = false;
  String _selectedLanguage = 'English';
  ProblemAnalysis? _analysis;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _fetchAnalysis();
  }

  Future<void> _fetchAnalysis() async {
    setState(() => _isLoading = true);
    final result = await _brainService.analyze(
      widget.problem,
      answers: _selectedAnswers,
      targetLanguage: _selectedLanguage,
    );
    setState(() {
      _analysis = result;
      _isLoading = false;
    });

    // Zero-Tap Auto Dispatch trigger for CRITICAL urgency
    if (result.urgency == 'CRITICAL') {
      _triggerZeroTapSos(result);
    }
  }

  void _triggerZeroTapSos(ProblemAnalysis analysis) {
    final sosMsg = SosBroadcastService.buildSosMessage(
      problem: analysis.problem,
      location: analysis.location,
    );
    SosBroadcastService.shareViaSystem(sosMsg);
  }

  Future<void> _listenVoiceInput() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (val.finalResult && val.recognizedWords.isNotEmpty) {
              setState(() => _isListening = false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AnalysisScreen(problem: val.recognizedWords),
                ),
              );
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
        title: const Text('CONNECT AI Brain'),
        actions: [
          DropdownButton<String>(
            value: _selectedLanguage,
            underline: const SizedBox(),
            icon: const Icon(Icons.language, color: Colors.blue),
            items: const [
              DropdownMenuItem(value: 'English', child: Text('English ')),
              DropdownMenuItem(value: 'Telugu', child: Text('తెలుగు ')),
              DropdownMenuItem(value: 'Hindi', child: Text('हिंदी ')),
              DropdownMenuItem(value: 'Spanish', child: Text('Español ')),
            ],
            onChanged: (lang) {
              if (lang != null) {
                setState(() => _selectedLanguage = lang);
                _fetchAnalysis();
              }
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listenVoiceInput,
        backgroundColor: _isListening ? Colors.red : Colors.blue,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('CONNECT Engine processing crisis graph...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _analysis!.category,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            final msg = SosBroadcastService.buildSosMessage(
                              problem: _analysis!.problem,
                              location: _analysis!.location,
                            );
                            SosBroadcastService.shareViaSystem(msg);
                          },
                          icon: const Icon(Icons.sos, color: Colors.white),
                          label: const Text('Broadcast SOS'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Original Problem', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            _analysis!.problem,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 18),
                          _InfoRow(label: 'Problem type', value: _analysis!.problemType),
                          _InfoRow(label: 'Urgency level', value: _analysis!.urgency),
                          _InfoRow(label: 'Location context', value: _analysis!.location),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Identified Needs',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _analysis!.needs
                          .map(
                            (need) => Chip(
                              avatar: const Icon(Icons.check_circle_outline, size: 18),
                              label: Text(need),
                              backgroundColor: Colors.blue.shade50,
                              side: BorderSide(color: Colors.blue.shade100),
                            ),
                          )
                          .toList(),
                    ),
                    if (_analysis!.questions.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Clarifying Questions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      ..._analysis!.questions.map((q) {
                        final selected = _selectedAnswers[q.id];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(q.question, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                children: q.options.map((opt) {
                                  final isChosen = selected == opt;
                                  return ChoiceChip(
                                    label: Text(opt),
                                    selected: isChosen,
                                    onSelected: (_) {
                                      setState(() => _selectedAnswers[q.id] = opt);
                                      _fetchAnalysis();
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SolutionsScreen(
                                problem: widget.problem,
                                analysis: _analysis,
                              ),
                            ),
                          );
                        },
                        child: const Text('View Solution Engine Options'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}