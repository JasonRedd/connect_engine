import 'package:flutter/material.dart';
import '../../../core/services/audio_guidance_service.dart';

class FirstAidGuide {
  final String title;
  final List<String> steps;

  const FirstAidGuide({required this.title, required this.steps});
}

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({super.key});

  static const List<FirstAidGuide> guides = [
    FirstAidGuide(
      title: 'CPR (Adult)',
      steps: [
        'Call 112 / 108 immediately and get an AED if available.',
        'Place hands in center of chest. Push hard and fast (100-120 bpm).',
        'Keep arms straight. Compress chest at least 2 inches deep.',
        'Repeat compressions continuously until emergency help arrives.',
      ],
    ),
    FirstAidGuide(
      title: 'Severe Bleeding',
      steps: [
        'Apply direct pressure on wound using a clean cloth or bandage.',
        'Maintain firm, continuous pressure without lifting the cloth.',
        'Elevate injured limb above heart level if no fracture is suspected.',
        'Apply a secondary bandage over top if blood soaks through.',
      ],
    ),
    FirstAidGuide(
      title: 'Burns & Scalds',
      steps: [
        'Cool burn under cool running water for 10-20 minutes immediately.',
        'Do not apply ice, butter, or ointment to severe burns.',
        'Cover burn loosely with sterile, non-stick dressing or clean plastic film.',
        'Seek immediate emergency medical assistance for deep or wide burns.',
      ],
    ),
  ];

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen> {
  int _currentGuide = 0;
  int _currentStep = 0;

  void _speakCurrentStep() {
    final stepText = FirstAidScreen.guides[_currentGuide].steps[_currentStep];
    AudioGuidanceService.speak(stepText);
  }

  @override
  Widget build(BuildContext context) {
    final guide = FirstAidScreen.guides[_currentGuide];

    return Scaffold(
      appBar: AppBar(
        title: Text(guide.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _speakCurrentStep,
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: FirstAidScreen.guides.length,
              itemBuilder: (context, index) {
                final isSelected = index == _currentGuide;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: ChoiceChip(
                    label: Text(FirstAidScreen.guides[index].title),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _currentGuide = index;
                          _currentStep = 0;
                        });
                        _speakCurrentStep();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: PageView.builder(
              itemCount: guide.steps.length,
              onPageChanged: (index) {
                setState(() => _currentStep = index);
                _speakCurrentStep();
              },
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(24),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Step ${index + 1} of ${guide.steps.length}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                        const SizedBox(height: 20),
                        Text(
                          guide.steps[index],
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}