import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:kiosk/core/theme/app_theme.dart';
import 'package:kiosk/features/home/presentation/pages/home_page.dart';

class CokoApp extends StatelessWidget {
  const CokoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coko Drinks',
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}
