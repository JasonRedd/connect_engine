import 'package:shared_preferences/shared_preferences.dart';
import '../../models/medical_profile.dart';

class MedicalProfileService {
  static const String _key = 'connect_user_medical_profile';

  static Future<void> saveProfile(MedicalProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, profile.toJson());
  }

  static Future<MedicalProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null || data.isEmpty) return const MedicalProfile();
    return MedicalProfile.fromJson(data);
  }
}