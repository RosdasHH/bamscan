import 'package:flutter/material.dart';

class AppColor extends ThemeExtension<AppColor> {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color primaryText;
  final Color base1;
  final Color base2;
  final Color base3;
  final Color error;
  final Color success;

  AppColor({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.primaryText,
    required this.base1,
    required this.base2,
    required this.base3,
    required this.error,
    required this.success,
  });

  @override
  ThemeExtension<AppColor> copyWith() => this;

  @override
  ThemeExtension<AppColor> lerp(
    covariant ThemeExtension<AppColor>? other,
    double t,
  ) => this;
}

class DarkColor extends AppColor {
  DarkColor()
    : super(
        primary: const Color.fromARGB(255, 0, 190, 61),
        secondary: Colors.white,
        accent: Colors.green,
        primaryText: const Color.fromARGB(255, 222, 222, 222),
        base1: Colors.grey[900]!,
        base2: Colors.grey[800]!,
        base3: Colors.grey[700]!,
        error: Colors.red,
        success: Colors.green,
      );
}

class LightColor extends AppColor {
  LightColor()
    : super(
        primary: const Color.fromARGB(255, 0, 190, 61),
        secondary: Colors.white,
        accent: Colors.green,
        primaryText: Colors.grey[800]!,
        base1: Colors.grey[300]!,
        base2: Colors.grey[200]!,
        base3: Colors.grey[100]!,
        error: Colors.red,
        success: Colors.green,
      );
}
