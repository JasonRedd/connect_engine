import 'package:flutter/material.dart';
import '../../../models/medical_profile.dart';
import '../../../core/services/medical_profile_service.dart';

class MedicalProfileScreen extends StatefulWidget {
  const MedicalProfileScreen({super.key});

  @override
  State<MedicalProfileScreen> createState() => _MedicalProfileScreenState();
}

class _MedicalProfileScreenState extends State<MedicalProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _bloodController;
  late TextEditingController _allergiesController;
  late TextEditingController _conditionsController;
  late TextEditingController _contactNameController;
  late TextEditingController _contactPhoneController;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bloodController = TextEditingController();
    _allergiesController = TextEditingController();
    _conditionsController = TextEditingController();
    _contactNameController = TextEditingController();
    _contactPhoneController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await MedicalProfileService.getProfile();
    setState(() {
      _nameController.text = profile.fullName;
      _bloodController.text = profile.bloodGroup;
      _allergiesController.text = profile.allergies;
      _conditionsController.text = profile.medicalConditions;
      _contactNameController.text = profile.emergencyContactName;
      _contactPhoneController.text = profile.emergencyContactPhone;
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = MedicalProfile(
        fullName: _nameController.text.trim(),
        bloodGroup: _bloodController.text.trim(),
        allergies: _allergiesController.text.trim(),
        medicalConditions: _conditionsController.text.trim(),
        emergencyContactName: _contactNameController.text.trim(),
        emergencyContactPhone: _contactPhoneController.text.trim(),
      );

      await MedicalProfileService.saveProfile(updatedProfile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical profile saved successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Medical Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal & Medical Card',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bloodController,
                      decoration: const InputDecoration(labelText: 'Blood Group (e.g. O+, A-)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _allergiesController,
                      decoration: const InputDecoration(labelText: 'Known Allergies', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _conditionsController,
                      decoration: const InputDecoration(labelText: 'Medical Conditions / Medications', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Emergency Contact',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactNameController,
                      decoration: const InputDecoration(labelText: 'Contact Person Name', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contactPhoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        child: const Text('Save Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}