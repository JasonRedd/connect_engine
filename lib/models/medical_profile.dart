import 'dart:convert';

class MedicalProfile {
  final String fullName;
  final String bloodGroup;
  final String allergies;
  final String medicalConditions;
  final String emergencyContactName;
  final String emergencyContactPhone;

  const MedicalProfile({
    this.fullName = '',
    this.bloodGroup = '',
    this.allergies = '',
    this.medicalConditions = '',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
  });

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'bloodGroup': bloodGroup,
        'allergies': allergies,
        'medicalConditions': medicalConditions,
        'emergencyContactName': emergencyContactName,
        'emergencyContactPhone': emergencyContactPhone,
      };

  factory MedicalProfile.fromMap(Map<String, dynamic> map) => MedicalProfile(
        fullName: map['fullName'] ?? '',
        bloodGroup: map['bloodGroup'] ?? '',
        allergies: map['allergies'] ?? '',
        medicalConditions: map['medicalConditions'] ?? '',
        emergencyContactName: map['emergencyContactName'] ?? '',
        emergencyContactPhone: map['emergencyContactPhone'] ?? '',
      );

  String toJson() => jsonEncode(toMap());
  factory MedicalProfile.fromJson(String source) => MedicalProfile.fromMap(jsonDecode(source));
}