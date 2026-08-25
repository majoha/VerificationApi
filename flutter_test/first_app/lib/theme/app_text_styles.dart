import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static const timer = TextStyle(
    color: AppColors.warning,
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  static const heading = TextStyle(
    color: AppColors.text,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const body = TextStyle(color: AppColors.text, fontSize: 16);

  static const code = TextStyle(
    color: AppColors.text,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 4,
  );
}
