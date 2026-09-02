import 'package:flutter/material.dart';
import '../../analyze_problem/presentation/analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _problemController = TextEditingController();

  void _submitProblem(String problemText) {
    if (problemText.trim().isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisScreen(
          problemText: problemText.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CONNECT"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on, color: Colors.amber),
            onPressed: () {},
            tooltip: 'SOS Quick Trigger',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            const Text(
              "What's happening?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Describe your issue or select a core crisis scenario.",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Dynamic Problem Input Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _problemController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "e.g. My car engine stopped on the highway...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16.0),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _submitProblem(_problemController.text),
                icon: const Icon(Icons.auto_awesome, size: 20),
                label: const Text(
                  "Analyze Problem with AI",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Section Label for Locked Scenarios
            Row(
              children: [
                const Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  "CORE DEMO SCENARIOS",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 1. Scenario: Vehicle Breakdown
            _buildScenarioCard(
              title: "Vehicle Breakdown",
              subtitle: "Engine failure, flat tire, towing, or road assistance",
              icon: Icons.directions_car_filled_rounded,
              iconBgColor: Colors.blue.shade50,
              iconColor: Colors.blue.shade700,
              onTap: () => _submitProblem("My car broke down and won't start on the road"),
            ),
            const SizedBox(height: 12),

            // 2. Scenario: Lost Wallet & Keys
            _buildScenarioCard(
              title: "Lost Wallet / Belongings",
              subtitle: "Card blocking, transit lost-and-found, & document support",
              icon: Icons.account_balance_wallet_rounded,
              iconBgColor: Colors.amber.shade50,
              iconColor: Colors.amber.shade800,
              onTap: () => _submitProblem("I lost my wallet and keys in a public area"),
            ),
            const SizedBox(height: 12),

            // 3. Scenario: Emergency Nearby Help
            _buildScenarioCard(
              title: "Emergency Medical & Safety",
              subtitle: "Urgent hospital routing, first aid, & immediate SOS",
              icon: Icons.health_and_safety_rounded,
              iconBgColor: Colors.red.shade50,
              iconColor: Colors.red.shade600,
              onTap: () => _submitProblem("Medical emergency needing urgent care hospital nearby"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenarioCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}