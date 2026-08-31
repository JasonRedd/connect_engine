import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SosBroadcastService {
  static String buildSosMessage({
    required String problem,
    required String location,
    String? medicalNotes,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🚨 EMERGENCY SOS ALERT - SENT VIA CONNECT 🚨');
    buffer.writeln('Issue: $problem');
    buffer.writeln('Live Location: $location');
    if (medicalNotes != null && medicalNotes.isNotEmpty) {
      buffer.writeln('Medical Info: $medicalNotes');
    }
    buffer.writeln('Google Maps: https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}');
    return buffer.toString();
  }

  static Future<void> shareViaSystem(String message) async {
    // ignore: deprecated_member_use
    await Share.share(
      message,
      subject: '🚨 EMERGENCY SOS ALERT',
    );
  }

  static Future<void> sendDirectSms(String phoneNumber, String message) async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: <String, String>{'body': message},
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }
} 