import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/offline_emergency_directory.dart';

class OfflineDirectoryScreen extends StatefulWidget {
  const OfflineDirectoryScreen({super.key});

  @override
  State<OfflineDirectoryScreen> createState() => _OfflineDirectoryScreenState();
}

class _OfflineDirectoryScreenState extends State<OfflineDirectoryScreen> {
  List<EmergencyContact> _filteredContacts = OfflineEmergencyDirectory.nationalHelplines;
  final TextEditingController _searchController = TextEditingController();

  void _filter(String query) {
    setState(() {
      _filteredContacts = OfflineEmergencyDirectory.search(query);
    });
  }

  Future<void> _makeCall(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Emergency Helplines'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Search ambulance, police, fire...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredContacts.length,
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(contact.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${contact.category}\n${contact.description}'),
                      trailing: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                        onPressed: () => _makeCall(contact.number),
                        icon: const Icon(Icons.phone, color: Colors.white, size: 16),
                        label: Text(contact.number, style: const TextStyle(color: Colors.white)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}