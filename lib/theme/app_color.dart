import 'package:flutter/material.dart';

class AppColor extends ThemeExtension<AppColor> {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color primaryText;
  final Color base1;
  final Color base2;
  final Color base3;

  AppColor({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.primaryText,
    required this.base1,
    required this.base2,
    required this.base3,
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
        primary: Colors.blue,
        secondary: Colors.white,
        accent: Colors.green,
        primaryText: const Color.fromARGB(255, 222, 222, 222),
        base1: Colors.grey[900]!,
        base2: Colors.grey[800]!,
        base3: Colors.grey[700]!,
      );
}
