import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kiosk/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database factory for web if running on web
  if (kIsWeb) {
    // Import and initialize web database factory
    // This will be handled in database_web.dart
  }
  
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const CokoApp(),
    ),
  );
}
