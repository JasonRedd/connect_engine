import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/connect_brain_service.dart';
import '../../analyze_problem/presentation/analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _problemController = TextEditingController();
  final ConnectBrainService _brainService = ConnectBrainService();
  bool _isLoading = false;

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    try {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 5),
      );
      return await Geolocator.getCurrentPosition(locationSettings: locationSettings);
    } catch (e) {
      return null;
    }
  }

  Future<void> _makeEmergencyCall(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (!await launchUrl(url)) {
      debugPrint("Could not dial $phoneNumber");
    }
  }

  void _showSosDialerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.sos_rounded, color: Colors.red.shade700, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "CONNECT Direct Dispatch Modal",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        "Instant 1-Tap Emergency Hotline Connection",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSosTile(Icons.local_hospital, "Medical Ambulance Dispatch", "112", Colors.red),
              const SizedBox(height: 10),
              _buildSosTile(Icons.local_police, "Police Assistance Hotline", "100", Colors.blue),
              const SizedBox(height: 10),
              _buildSosTile(Icons.minor_crash, "Highway Towing & Breakdown", "1033", Colors.purple),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSosTile(IconData icon, String title, String number, Color color) {
    return ListTile(
      tileColor: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Text("Dial $number", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      onTap: () {
        Navigator.pop(context);
        _makeEmergencyCall(number);
      },
    );
  }

  Future<void> _processProblem() async {
    final text = _problemController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      Position? position = await _getCurrentLocation();
      final ProblemAnalysis analysis = await _brainService.analyzeProblem(
        text,
        latitude: position?.latitude,
        longitude: position?.longitude,
      );

      if (mounted) {
        // Navigate to AnalysisScreen (Diagnosis Screen) first
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnalysisScreen(
              problemAnalysis: analysis,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "CONNECT",
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: InkWell(
              onTap: () => _showSosDialerModal(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "SOS DISPATCH",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CONNECT Engine Active Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, color: Colors.blue.shade700, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      "CONNECT Engine: Active (GPS Sync)",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                "What's your emergency or problem?",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Describe what happened. We'll triage and route you to verified actions.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _problemController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "e.g., My hand is limp and not responding...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processProblem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Run AI Triage & Direct Dispatch",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}