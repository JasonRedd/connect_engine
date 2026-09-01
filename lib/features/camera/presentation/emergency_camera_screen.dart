import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../analyze_problem/presentation/analysis_screen.dart';

class EmergencyCameraScreen extends StatefulWidget {
  const EmergencyCameraScreen({super.key});

  @override
  State<EmergencyCameraScreen> createState() => _EmergencyCameraScreenState();
}

class _EmergencyCameraScreenState extends State<EmergencyCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(_cameras![0], ResolutionPreset.medium);
        await _controller!.initialize();
      }
    } catch (_) {
      // Fallback if camera permission/hardware is unavailable
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final XFile image = await _controller!.takePicture();
      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      if (mounted) {
        // Pass the image context payload to the analysis engine
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AnalysisScreen(
              problem: '[VISUAL ANALYSIS REQUEST] Analyze attached image for hazards or medical symptoms.',
              base64Image: base64Image,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera Feed')),
        body: const Center(child: Text('Camera hardware unavailable or permission denied.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Align situation in frame',
                  style: TextStyle(color: Colors.white, backgroundColor: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 16),
                FloatingActionButton.large(
                  onPressed: _isProcessing ? null : _captureAndAnalyze,
                  backgroundColor: Colors.redAccent,
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.camera_alt, color: Colors.white, size: 36),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}