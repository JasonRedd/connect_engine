import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/audio_guidance_service.dart';

class FirstAidScreen extends StatefulWidget {
  const FirstAidScreen({super.key});

  @override
  State<FirstAidScreen> createState() => _FirstAidScreenState();
}

class _FirstAidScreenState extends State<FirstAidScreen> {
  static const String _cacheKey = 'offline_first_aid_guides';
  
  List<Map<String, String>> _guides = [
    {
      'title': 'CPR (Cardiopulmonary Resuscitation)',
      'steps': '1. Push hard and fast on the center of the chest.\n2. 100-120 compressions/min.\n3. Allow chest full recoil.',
      'category': 'Critical Medical'
    },
    {
      'title': 'Severe Bleeding Control',
      'steps': '1. Apply direct pressure with clean cloth.\n2. Elevate limb above heart.\n3. Apply tourniquet 2 inches above wound if uncontrollable.',
      'category': 'Trauma'
    },
    {
      'title': 'Airway Obstruction (Choking)',
      'steps': '1. Perform 5 back blows between shoulder blades.\n2. Perform 5 abdominal thrusts (Heimlich maneuver).\n3. Repeat until clear.',
      'category': 'Airway'
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAndCacheGuides();
  }

  Future<void> _loadAndCacheGuides() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_cacheKey);

    if (cachedData != null) {
      final List decoded = jsonDecode(cachedData);
      setState(() {
        _guides = decoded.map((e) => Map<String, String>.from(e)).toList();
      });
    } else {
      // Warm up offline cache on first launch
      await prefs.setString(_cacheKey, jsonEncode(_guides));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline First-Aid Survival Kit')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _guides.length,
        itemBuilder: (context, index) {
          final guide = _guides[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(guide['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(guide['steps']!),
              trailing: IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.blue),
                onPressed: () => AudioGuidanceService.speak('${guide['title']}. ${guide['steps']}'),
              ),
            ),
          );
        },
      ),
    );
  }
}