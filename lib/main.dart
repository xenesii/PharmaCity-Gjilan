import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'app_colors.dart';

void main() {
  runApp(const PharmaCityApp());
}

class PharmaCityApp extends StatelessWidget {
  const PharmaCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: false,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: Colors.white,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(primary: AppColors.primary),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharma City',
      theme: baseTheme,
      home: const LoginScreen(),
    );
  }
}

