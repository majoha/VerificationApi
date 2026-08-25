import 'package:flutter/material.dart';

import 'pages/verification_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Verification Demo',
      theme: AppTheme.lightTheme,
      home: const VerificationPage(),
    );
  }
}
