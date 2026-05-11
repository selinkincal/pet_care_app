// main.dart
import 'package:flutter/material.dart';
import 'package:pet_care_app/core/theme/app_theme.dart';
import 'package:pet_care_app/screens/auth/login_screen.dart';
import 'package:pet_care_app/screens/common/main_navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Care Marketplace',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
