import 'package:flutter/material.dart';
import '../../../../models/problem_analysis.dart';

class SolutionGraphVisualizer extends StatelessWidget {
  const SolutionGraphVisualizer({super.key, required this.analysis});

  final ProblemAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency Solution Graph',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildNode(analysis.problem, Colors.redAccent, Icons.warning_amber),
          _buildConnector(),
          _buildNode(analysis.category, Colors.amber, Icons.category),
          _buildConnector(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: analysis.needs
                .map((need) => _buildNode(need, Colors.blueAccent, Icons.build_circle, isCompact: true))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(String text, Color color, IconData icon, {bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 10 : 14, vertical: isCompact ? 6 : 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isCompact ? 16 : 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(color: Colors.white, fontSize: isCompact ? 12 : 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      height: 20,
      width: 2,
      color: Colors.white30,
    );
  }
}