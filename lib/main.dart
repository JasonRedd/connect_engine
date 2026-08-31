import 'package:flutter/material.dart';
import 'core/services/notification_service.dart';
import 'app/app.dart'; // Or wherever your ConnectApp widget is defined

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const ConnectApp());
}