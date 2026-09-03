import 'package:flutter/material.dart';
import '../../../../core/services/connect_brain_service.dart';
import '../../solutions/presentation/solutions_screen.dart';

class EmergencyCameraScreen extends StatefulWidget {
  const EmergencyCameraScreen({super.key});

  @override
  State<EmergencyCameraScreen> createState() => _EmergencyCameraScreenState();
}

class _EmergencyCameraScreenState extends State<EmergencyCameraScreen> {
  bool _isCapturing = false;

  void _processCameraCapture() async {
    setState(() => _isCapturing = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isCapturing = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolutionsScreen(
            problemAnalysis: ProblemAnalysis(
              originalProblem: "Visual Scan Emergency Capture",
              problemType: "Medical Emergency",
              aiDiagnosis: "Visual triage assessment generated for captured camera image.",
              urgencyLevel: "HIGH",
              locationContext: "GPS Location Active",
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Camera Scan"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isCapturing ? null : _processCameraCapture,
                  icon: const Icon(Icons.center_focus_strong),
                  label: _isCapturing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Analyze Visual Emergency",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}