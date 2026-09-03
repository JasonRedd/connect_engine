import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/connect_brain_service.dart';

class SolutionGraphVisualizer extends StatelessWidget {
  final List<SolutionOption> solutionPaths;

  const SolutionGraphVisualizer({
    super.key,
    required this.solutionPaths,
  });

  Future<void> _openGoogleMaps(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$encodedQuery");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch Google Maps for query: $query");
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
    if (!await launchUrl(url)) {
      debugPrint("Could not dial $phoneNumber");
    }
  }

  Color _getBadgeColor(String badge) {
    if (badge.contains("Fastest") || badge.contains("⚡")) {
      return Colors.amber.shade800;
    } else if (badge.contains("Cheapest") || badge.contains("💰")) {
      return Colors.green.shade800;
    } else if (badge.contains("Reliable") || badge.contains("⭐")) {
      return Colors.purple.shade800;
    }
    return Colors.blue.shade800;
  }

  Color _getBadgeBgColor(String badge) {
    if (badge.contains("Fastest") || badge.contains("⚡")) {
      return Colors.amber.shade50;
    } else if (badge.contains("Cheapest") || badge.contains("💰")) {
      return Colors.green.shade50;
    } else if (badge.contains("Reliable") || badge.contains("⭐")) {
      return Colors.purple.shade50;
    }
    return Colors.blue.shade50;
  }

  @override
  Widget build(BuildContext context) {
    if (solutionPaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: solutionPaths.map((path) {
        final bool isEmergencyCall = path.category.toLowerCase().contains("emergency") ||
            path.title.toLowerCase().contains("call") ||
            path.searchQuery.toLowerCase().contains("ambulance");

        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Tradeoff Badge & Category Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Trade-Off Badge (⚡ Fastest / 💰 Cheapest / ⭐ Most Reliable)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getBadgeBgColor(path.tradeoffBadge),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _getBadgeColor(path.tradeoffBadge).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          path.tradeoffBadge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _getBadgeColor(path.tradeoffBadge),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isEmergencyCall ? Colors.red.shade50 : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          path.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isEmergencyCall ? Colors.red.shade700 : Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isEmergencyCall ? Icons.phone_in_talk : Icons.near_me,
                    color: isEmergencyCall ? Colors.red.shade600 : const Color(0xFF2563EB),
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                path.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                path.description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 14),

              // Real Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openGoogleMaps(path.searchQuery),
                      icon: const Icon(Icons.map, size: 16),
                      label: const Text("Open Maps"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _makePhoneCall(isEmergencyCall ? "112" : "108"),
                      icon: Icon(
                        Icons.call,
                        size: 16,
                        color: isEmergencyCall ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                      label: Text(
                        isEmergencyCall ? "Call 112" : "Call Helpline",
                        style: TextStyle(
                          color: isEmergencyCall ? Colors.red.shade700 : Colors.green.shade700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: isEmergencyCall ? Colors.red.shade300 : Colors.green.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}